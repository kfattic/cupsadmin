import Foundation

/// Minimal HTTP/1.1 client (POST for IPP, GET for PPDs) over a Unix domain socket.
///
/// Why not URLSession to localhost:631: on macOS 27 launchd only socket-activates cupsd on
/// /private/var/run/cupsd. TCP 631 is bound by cupsd itself and disappears when cupsd idle-exits,
/// so connecting over TCP fails whenever the scheduler is asleep. URLSession can't do AF_UNIX.
enum UnixSocketHTTP {
    struct Response {
        let status: Int
        let body: Data
    }

    static func post(socketPath: String, resource: String, contentType: String, body: Data) throws -> Response {
        try request(method: "POST", socketPath: socketPath, resource: resource, contentType: contentType, body: body)
    }

    static func get(socketPath: String, resource: String) throws -> Response {
        try request(method: "GET", socketPath: socketPath, resource: resource, contentType: nil, body: Data())
    }

    private static func request(method: String, socketPath: String, resource: String, contentType: String?,
                                body: Data, timeoutSeconds: Int = 15) throws -> Response {
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw failure("socket()") }
        defer { close(fd) }

        var timeout = timeval(tv_sec: timeoutSeconds, tv_usec: 0)
        let timevalSize = socklen_t(MemoryLayout<timeval>.size)
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, timevalSize)
        setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &timeout, timevalSize)
        var noSigPipe: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &noSigPipe, socklen_t(MemoryLayout<Int32>.size))

        var address = sockaddr_un()
        address.sun_family = sa_family_t(AF_UNIX)
        let path = Array(socketPath.utf8) + [0]
        let capacity = MemoryLayout.size(ofValue: address.sun_path)
        guard path.count <= capacity else { throw CupsAdminError.transport("socket path too long: \(socketPath)") }
        withUnsafeMutableBytes(of: &address.sun_path) { $0.copyBytes(from: path) }
        address.sun_len = UInt8(MemoryLayout<sockaddr_un>.size)

        let connected = withUnsafePointer(to: &address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(fd, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard connected == 0 else { throw failure("connect to \(socketPath)") }

        var head = "\(method) \(resource) HTTP/1.1\r\nHost: localhost\r\n"
        if let contentType {
            head += "Content-Type: \(contentType)\r\nContent-Length: \(body.count)\r\n"
        }
        head += "Connection: close\r\n\r\n"
        try writeAll(fd, [UInt8](Data(head.utf8) + body))

        var reader = Reader(fd: fd)
        let statusLine = try reader.readLine()
        let statusParts = statusLine.split(separator: " ", maxSplits: 2)
        guard statusParts.count >= 2, statusParts[0].hasPrefix("HTTP/"), let status = Int(statusParts[1]) else {
            throw CupsAdminError.transport("bad HTTP status line from cupsd: \(statusLine)")
        }

        var headers: [String: String] = [:]
        while true {
            let line = try reader.readLine()
            if line.isEmpty { break }
            guard let colon = line.firstIndex(of: ":") else { continue }
            let name = line[..<colon].lowercased()
            headers[name] = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        }

        let payload: [UInt8]
        if headers["transfer-encoding"]?.lowercased().contains("chunked") == true {
            var chunks: [UInt8] = []
            while true {
                let sizeLine = try reader.readLine()
                let hex = sizeLine.split(separator: ";").first.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? ""
                guard let size = Int(hex, radix: 16) else {
                    throw CupsAdminError.transport("bad chunk size from cupsd: \(sizeLine)")
                }
                if size == 0 {
                    while try !reader.readLine().isEmpty {}  // trailers
                    break
                }
                chunks += try reader.readBytes(size)
                _ = try reader.readLine()
            }
            payload = chunks
        } else if let length = headers["content-length"].flatMap(Int.init) {
            payload = try reader.readBytes(length)
        } else {
            payload = try reader.readToEnd()
        }
        return Response(status: status, body: Data(payload))
    }

    private static func writeAll(_ fd: Int32, _ bytes: [UInt8]) throws {
        var sent = 0
        while sent < bytes.count {
            let n = bytes[sent...].withUnsafeBytes { write(fd, $0.baseAddress, $0.count) }
            if n < 0 {
                if errno == EINTR { continue }
                throw failure("write to cupsd")
            }
            sent += n
        }
    }

    fileprivate static func failure(_ what: String) -> CupsAdminError {
        let code = errno
        let reason: String
        switch code {
        case ENOENT: reason = "socket not found (is CUPS installed?)"
        case ECONNREFUSED: reason = "connection refused (cupsd not running?)"
        case EAGAIN: reason = "timed out"
        default: reason = String(cString: strerror(code))
        }
        return CupsAdminError.transport("\(what): \(reason)")
    }

    private struct Reader {
        let fd: Int32
        private var buffer: [UInt8] = []
        private var position = 0

        init(fd: Int32) { self.fd = fd }

        /// Returns false at EOF.
        private mutating func fill() throws -> Bool {
            if position > 0 {
                buffer.removeFirst(position)
                position = 0
            }
            var chunk = [UInt8](repeating: 0, count: 65_536)
            while true {
                let n = chunk.withUnsafeMutableBytes { read(fd, $0.baseAddress, $0.count) }
                if n < 0 {
                    if errno == EINTR { continue }
                    throw UnixSocketHTTP.failure("read from cupsd")
                }
                if n == 0 { return false }
                buffer += chunk[0 ..< n]
                return true
            }
        }

        mutating func readLine() throws -> String {
            while true {
                if let lf = buffer[position...].firstIndex(of: UInt8(ascii: "\n")) {
                    var end = lf
                    if end > position, buffer[end - 1] == UInt8(ascii: "\r") { end -= 1 }
                    let line = String(decoding: buffer[position ..< end], as: UTF8.self)
                    position = lf + 1
                    return line
                }
                guard try fill() else { throw CupsAdminError.transport("cupsd closed the connection mid-response") }
            }
        }

        mutating func readBytes(_ count: Int) throws -> [UInt8] {
            while buffer.count - position < count {
                guard try fill() else { throw CupsAdminError.transport("cupsd closed the connection mid-response") }
            }
            defer { position += count }
            return Array(buffer[position ..< position + count])
        }

        mutating func readToEnd() throws -> [UInt8] {
            while try fill() {}
            defer { position = buffer.count }
            return Array(buffer[position...])
        }
    }
}
