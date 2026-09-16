import Foundation

public enum CupsAdminError: Error, CustomStringConvertible {
    case usage(String)
    case transport(String)
    case ipp(status: UInt16, message: String?)
    case failed(String)

    public var description: String {
        switch self {
        case .usage(let m): return m
        case .transport(let m), .failed(let m): return m
        case .ipp(let status, let message):
            let name = IPPStatus.name(status)
            if let message, !message.isEmpty { return "\(name): \(message)" }
            return name
        }
    }
}

public enum IPPStatus {
    public static let notFound: UInt16 = 0x0406

    public static func name(_ code: UInt16) -> String {
        let known: [UInt16: String] = [
            0x0400: "client-error-bad-request",
            0x0401: "client-error-forbidden",
            0x0402: "client-error-not-authenticated",
            0x0403: "client-error-not-authorized",
            0x0404: "client-error-not-possible",
            0x0405: "client-error-timeout",
            0x0406: "client-error-not-found",
            0x0407: "client-error-gone",
            0x040B: "client-error-attributes-or-values-not-supported",
            0x0500: "server-error-internal-error",
            0x0501: "server-error-operation-not-supported",
            0x0502: "server-error-service-unavailable",
            0x0503: "server-error-version-not-supported",
        ]
        return known[code] ?? String(format: "ipp-status-0x%04x", code)
    }
}

/// Talks IPP to the local cupsd over its Unix domain socket (see UnixSocketHTTP for why not TCP 631).
public final class CupsClient {
    public let socketPath = "/private/var/run/cupsd"
    private var nextRequestID: Int32 = 1

    public init() {}

    // MARK: operations

    /// CUPS-Get-Printers: one printer-attributes group per queue (printers and classes).
    public func getPrinters(requested: [String]) async throws -> [IPPGroup] {
        let request = makeRequest(IPPOperation.cupsGetPrinters, target: serverURI, requested: requested)
        return try await send(request, resource: "/").groups(.printerAttributes)
    }

    public func getPrinterAttributes(queue: String, requested: [String]) async throws -> IPPGroup {
        let request = makeRequest(IPPOperation.getPrinterAttributes, target: printerURI(queue), requested: requested)
        let response = try await send(request, resource: printerResource(queue))
        guard let group = response.groups(.printerAttributes).first else {
            throw CupsAdminError.transport("cupsd returned no printer attributes for \(queue)")
        }
        return group
    }

    public func queueExists(_ queue: String) async throws -> Bool {
        do {
            _ = try await getPrinterAttributes(queue: queue, requested: ["printer-name"])
            return true
        } catch CupsAdminError.ipp(let status, _) where status == IPPStatus.notFound {
            return false
        }
    }

    /// CUPS-Get-Default: the server default printer's name, or nil when there is none.
    public func getDefaultPrinter() async throws -> String? {
        let request = makeRequest(IPPOperation.cupsGetDefault, target: serverURI, requested: ["printer-name"])
        do {
            return try await send(request, resource: "/").groups(.printerAttributes).first?.string("printer-name")
        } catch CupsAdminError.ipp(let status, _) where status == IPPStatus.notFound {
            return nil
        }
    }

    /// Get-Jobs. `queue` nil means all queues. `which` is "not-completed", "completed" or "all".
    public func getJobs(queue: String?, which: String, requested: [String]) async throws -> [IPPGroup] {
        let extra = [
            IPPAttribute.string("which-jobs", .keyword, [which]),
            IPPAttribute.boolean("my-jobs", false),
        ]
        let request = makeRequest(IPPOperation.getJobs, target: queue.map(printerURI) ?? serverURI,
                                  extra: extra, requested: requested)
        return try await send(request, resource: queue.map(printerResource) ?? "/").groups(.jobAttributes)
    }

    public func getJobAttributes(jobID: Int, requested: [String]) async throws -> IPPGroup {
        let request = makeRequest(IPPOperation.getJobAttributes, target: jobURI(jobID), requested: requested)
        guard let group = try await send(request, resource: "/jobs/").groups(.jobAttributes).first else {
            throw CupsAdminError.transport("cupsd returned no attributes for job \(jobID)")
        }
        return group
    }

    public func cancelJob(jobID: Int) async throws {
        let request = makeRequest(IPPOperation.cancelJob, target: jobURI(jobID), requested: [])
        _ = try await send(request, resource: "/jobs/")
    }

    /// The queue's PPD text (GET /printers/<queue>.ppd), or nil if the queue has no PPD.
    public func getPPD(queue: String) async throws -> String? {
        let response = try UnixSocketHTTP.get(socketPath: socketPath, resource: printerResource(queue) + ".ppd")
        switch response.status {
        case 200: return String(decoding: response.body, as: UTF8.self)
        case 404: return nil
        default: throw CupsAdminError.transport("HTTP \(response.status) fetching PPD for \(queue)")
        }
    }

    // MARK: plumbing

    private typealias Target = (name: String, uri: String)

    private var serverURI: Target { ("printer-uri", "ipp://localhost/") }

    private func printerURI(_ queue: String) -> Target {
        ("printer-uri", "ipp://localhost\(printerResource(queue))")
    }

    private func jobURI(_ jobID: Int) -> Target {
        ("job-uri", "ipp://localhost/jobs/\(jobID)")
    }

    private func printerResource(_ queue: String) -> String {
        let escaped = queue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed.subtracting(["/"])) ?? queue
        return "/printers/\(escaped)"
    }

    private func makeRequest(_ operation: UInt16, target: Target, extra: [IPPAttribute] = [],
                             requested: [String]) -> IPPMessage {
        // Order matters: charset, natural-language, target, then the rest (RFC 8011 §4.1.4).
        var attributes: [IPPAttribute] = [
            .string("attributes-charset", .charset, ["utf-8"]),
            .string("attributes-natural-language", .naturalLanguage, ["en"]),
            .string(target.name, .uri, [target.uri]),
            .string("requesting-user-name", .nameWithoutLanguage, [NSUserName()]),
        ]
        attributes += extra
        if !requested.isEmpty {
            attributes.append(.string("requested-attributes", .keyword, requested))
        }
        return IPPMessage(code: operation, groups: [IPPGroup(tag: .operationAttributes, attributes: attributes)])
    }

    private func send(_ message: IPPMessage, resource: String) async throws -> IPPMessage {
        var message = message
        message.requestID = nextRequestID
        nextRequestID += 1

        let response = try UnixSocketHTTP.post(socketPath: socketPath, resource: resource,
                                               contentType: "application/ipp", body: IPPEncoder.encode(message))
        guard response.status == 200 else {
            throw CupsAdminError.transport("HTTP \(response.status) from cupsd for POST \(resource)")
        }

        let reply = try IPPDecoder.decode(response.body)
        guard reply.isSuccess else {
            throw CupsAdminError.ipp(status: reply.code, message: reply.operationGroup?.string("status-message"))
        }
        return reply
    }
}
