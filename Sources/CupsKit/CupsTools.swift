import Foundation

/// Output of one CUPS command-line tool run.
public struct ToolResult {
    public let executable: String
    public let arguments: [String]
    public let status: Int32
    public let standardOutput: Data
    public let standardError: Data

    public var commandLine: String { CupsTools.commandLine(executable, arguments) }
    public var succeeded: Bool { status == 0 }
    /// stderr then stdout as text, trimmed — what to show a user when a tool fails.
    public var message: String {
        (String(decoding: standardError, as: UTF8.self) + String(decoding: standardOutput, as: UTF8.self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Writes go through the CUPS tools (lpadmin handles _lpadmin auth and IPP Everywhere PPD generation).
/// Nothing here prints; callers decide what to show.
public enum CupsTools {
    public static let lpadminPath = "/usr/sbin/lpadmin"
    public static let cupsenablePath = "/usr/sbin/cupsenable"
    public static let cupsdisablePath = "/usr/sbin/cupsdisable"
    public static let cupsacceptPath = "/usr/sbin/cupsaccept"
    public static let cupsrejectPath = "/usr/sbin/cupsreject"
    public static let cancelPath = "/usr/bin/cancel"
    public static let lpPath = "/usr/bin/lp"
    public static let lpmovePath = "/usr/sbin/lpmove"
    public static let lpinfoPath = "/usr/sbin/lpinfo"
    /// The CUPS standard test page (what the web UI's Print Test Page sent).
    public static let testPagePath = "/usr/share/cups/data/testprint"

    public static func lpadmin(_ arguments: [String]) throws -> ToolResult {
        try run(lpadminPath, arguments)
    }

    public static func enable(queue: String) throws -> ToolResult {
        try run(cupsenablePath, [queue])
    }

    public static func disable(queue: String, reason: String? = nil) throws -> ToolResult {
        try run(cupsdisablePath, (reason.map { ["-r", $0] } ?? []) + [queue])
    }

    public static func accept(queue: String) throws -> ToolResult {
        try run(cupsacceptPath, [queue])
    }

    public static func reject(queue: String, reason: String? = nil) throws -> ToolResult {
        try run(cupsrejectPath, (reason.map { ["-r", $0] } ?? []) + [queue])
    }

    /// `cancel -a queue`: every job on the queue.
    public static func cancelAll(queue: String) throws -> ToolResult {
        try run(cancelPath, ["-a", queue])
    }

    /// `lp -i id -H hold`.
    public static func hold(jobID: Int) throws -> ToolResult {
        try run(lpPath, ["-i", String(jobID), "-H", "hold"])
    }

    /// `lp -i id -H resume`.
    public static func release(jobID: Int) throws -> ToolResult {
        try run(lpPath, ["-i", String(jobID), "-H", "resume"])
    }

    /// `lpmove id destination`.
    public static func move(jobID: Int, to destination: String) throws -> ToolResult {
        try run(lpmovePath, [String(jobID), destination])
    }

    /// `lpadmin -d queue`: the server default printer.
    public static func setDefault(queue: String) throws -> ToolResult {
        try run(lpadminPath, ["-d", queue])
    }

    /// `lpadmin -x queue`.
    public static func delete(queue: String) throws -> ToolResult {
        try run(lpadminPath, ["-x", queue])
    }

    /// `lp -d queue -t "Test Page" file`; the job id is in stdout ("request id is Q-12 (1 file(s))").
    public static func printTestPage(queue: String, file: String) throws -> ToolResult {
        try run(lpPath, ["-d", queue, "-t", "Test Page", file])
    }

    /// `lpinfo -m`: every driver cupsd knows, as (model, name).
    public static func models() throws -> [(model: String, name: String)] {
        let result = try run(lpinfoPath, ["-m"])
        guard result.succeeded else { throw CupsAdminError.failed("lpinfo -m: \(result.message)") }
        return String(decoding: result.standardOutput, as: UTF8.self).split(whereSeparator: \.isNewline).compactMap { line in
            let parts = line.split(separator: " ", maxSplits: 1)
            guard parts.count == 2 else { return nil }
            return (String(parts[0]), String(parts[1]))
        }
    }

    /// Runs a tool and captures stdout/stderr. stdin is inherited; libcups password prompts use /dev/tty.
    public static func run(_ executable: String, _ arguments: [String]) throws -> ToolResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe
        try process.run()

        // Drain both pipes concurrently so a chatty tool can't block on a full pipe buffer.
        final class Box: @unchecked Sendable { var data = Data() }
        let out = Box(), err = Box()
        let group = DispatchGroup()
        for (pipe, box) in [(outPipe, out), (errPipe, err)] {
            group.enter()
            DispatchQueue.global().async {
                box.data = pipe.fileHandleForReading.readDataToEndOfFile()
                group.leave()
            }
        }
        process.waitUntilExit()
        group.wait()

        return ToolResult(executable: executable, arguments: arguments, status: process.terminationStatus,
                          standardOutput: out.data, standardError: err.data)
    }

    /// Shell-style display of a command, quoting arguments that contain spaces or quotes.
    public static func commandLine(_ executable: String, _ arguments: [String]) -> String {
        ([executable] + arguments).map { $0.contains(where: { " '\"$".contains($0) }) ? "'\($0)'" : $0 }
            .joined(separator: " ")
    }
}
