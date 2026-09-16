import CoreGraphics
import Foundation

/// One job as the Jobs table shows it.
public struct JobSummary: Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let user: String
    public let queue: String
    /// Size in kilobytes (job-k-octets).
    public let sizeK: Int
    /// Pages printed or counted so far, when cupsd knows.
    public let pages: Int?
    public let state: Int
    public let reasons: [String]
    public let submitted: Date?

    public static let requestedAttributes = [
        "job-id", "job-name", "job-originating-user-name", "job-printer-uri", "job-k-octets",
        "job-media-sheets-completed", "job-impressions-completed", "job-impressions",
        "job-state", "job-state-reasons", "time-at-creation",
    ]

    public init(_ job: IPPGroup) {
        id = job.int("job-id") ?? 0
        name = job.string("job-name") ?? ""
        user = job.string("job-originating-user-name") ?? ""
        queue = Self.queueName(fromPrinterURI: job.string("job-printer-uri")) ?? ""
        sizeK = job.int("job-k-octets") ?? 0
        pages = [job.int("job-impressions-completed"), job.int("job-media-sheets-completed"), job.int("job-impressions")]
            .compactMap { $0 }.first { $0 > 0 }
        state = job.int("job-state") ?? 0
        reasons = job.strings("job-state-reasons").filter { $0 != "none" }
        submitted = job.int("time-at-creation").flatMap { $0 > 0 ? Date(timeIntervalSince1970: TimeInterval($0)) : nil }
    }

    /// pending, held, processing, stopped, canceled, aborted, completed.
    public var stateName: String { Format.jobState(state) }
    public var isHeld: Bool { state == 4 }
    /// pending / held / processing / stopped: cancel, hold, release and move still make sense.
    public var isActive: Bool { state >= 3 && state <= 6 }

    /// ipp://host/printers/NAME -> NAME.
    public static func queueName(fromPrinterURI uri: String?) -> String? {
        guard let uri, let last = uri.split(separator: "/").last else { return nil }
        return last.removingPercentEncoding ?? String(last)
    }
}

public enum PrinterAction: CaseIterable {
    case pause, resume, accept, reject, cancelAllJobs

    public var title: String {
        switch self {
        case .pause: return "Pause"
        case .resume: return "Resume"
        case .accept: return "Accept Jobs"
        case .reject: return "Reject Jobs"
        case .cancelAllJobs: return "Cancel All Jobs"
        }
    }

    public var systemImage: String {
        switch self {
        case .pause: return "pause.circle"
        case .resume: return "play.circle"
        case .accept: return "checkmark.circle"
        case .reject: return "nosign"
        case .cancelAllJobs: return "xmark.circle"
        }
    }

    /// "Paused", "Resumed", ... for status lines.
    public var pastTense: String {
        switch self {
        case .pause: return "Paused"
        case .resume: return "Resumed"
        case .accept: return "Accepting jobs on"
        case .reject: return "Rejecting jobs on"
        case .cancelAllJobs: return "Canceled all jobs on"
        }
    }
}

public enum JobAction: Hashable {
    case cancel, hold, release
    case move(to: String)

    public var title: String {
        switch self {
        case .cancel: return "Cancel"
        case .hold: return "Hold"
        case .release: return "Release"
        case .move(let destination): return "Move to \(destination)"
        }
    }

    public var pastTense: String {
        switch self {
        case .cancel: return "Canceled"
        case .hold: return "Held"
        case .release: return "Released"
        case .move(let destination): return "Moved to \(destination):"
        }
    }
}

/// The outcome of an action after reading cupsd back.
public struct ActionOutcome: Hashable {
    public let succeeded: Bool
    /// The command that ran (shell-style), or the IPP operation.
    public let command: String
    /// Why it failed: tool output, IPP status, or what the read-back found.
    public let message: String?
}

/// Pause/resume/accept/reject/cancel-all and job cancel/hold/release/move, each verified against cupsd.
public enum QueueActions {
    public static func perform(_ action: PrinterAction, queue: String, client: CupsClient) async throws -> ActionOutcome {
        let result: ToolResult = try await Task.detached {
            switch action {
            case .pause: return try CupsTools.disable(queue: queue)
            case .resume: return try CupsTools.enable(queue: queue)
            case .accept: return try CupsTools.accept(queue: queue)
            case .reject: return try CupsTools.reject(queue: queue)
            case .cancelAllJobs: return try CupsTools.cancelAll(queue: queue)
            }
        }.value
        guard result.succeeded else {
            return ActionOutcome(succeeded: false, command: result.commandLine,
                                 message: result.message.isEmpty ? "exited \(result.status)" : result.message)
        }

        let problem: String?
        switch action {
        case .pause, .resume, .accept, .reject:
            let printer = try await client.getPrinterAttributes(queue: queue, requested: ["printer-state", "printer-is-accepting-jobs"])
            let stopped = printer.int("printer-state") == 5
            let accepting = printer.bool("printer-is-accepting-jobs") ?? true
            switch action {
            case .pause: problem = stopped ? nil : "still \(Format.printerState(printer.int("printer-state")))"
            case .resume: problem = stopped ? "still stopped" : nil
            case .accept: problem = accepting ? nil : "still rejecting jobs"
            default: problem = accepting ? "still accepting jobs" : nil
            }
        case .cancelAllJobs:
            let left = try await client.getJobs(queue: queue, which: "not-completed", requested: ["job-id"]).count
            problem = left == 0 ? nil : "\(left) job\(left == 1 ? "" : "s") still active"
        }
        return ActionOutcome(succeeded: problem == nil, command: result.commandLine, message: problem.map { "Not applied: \($0)" })
    }

    /// Runs the action on each job, then reads each job back. Returns one outcome per job id, in order.
    public static func perform(_ action: JobAction, jobIDs: [Int], client: CupsClient) async -> [Int: ActionOutcome] {
        var outcomes: [Int: ActionOutcome] = [:]
        for id in jobIDs {
            outcomes[id] = await perform(action, jobID: id, client: client)
        }
        return outcomes
    }

    static func perform(_ action: JobAction, jobID: Int, client: CupsClient) async -> ActionOutcome {
        var command = ""
        do {
            switch action {
            case .cancel:
                // Same IPP Cancel-Job the CLI's `cupsadmin cancel` uses.
                command = "IPP Cancel-Job \(jobID)"
                try await client.cancelJob(jobID: jobID)
            case .hold, .release, .move:
                let result: ToolResult = try await Task.detached {
                    switch action {
                    case .hold: return try CupsTools.hold(jobID: jobID)
                    case .release: return try CupsTools.release(jobID: jobID)
                    case .move(let destination): return try CupsTools.move(jobID: jobID, to: destination)
                    case .cancel: fatalError("handled above")
                    }
                }.value
                command = result.commandLine
                guard result.succeeded else {
                    return ActionOutcome(succeeded: false, command: command,
                                         message: result.message.isEmpty ? "exited \(result.status)" : result.message)
                }
            }
        } catch {
            return ActionOutcome(succeeded: false, command: command, message: String(describing: error))
        }

        do {
            let job = JobSummary(try await client.getJobAttributes(jobID: jobID, requested: JobSummary.requestedAttributes))
            let problem: String?
            switch action {
            case .cancel: problem = job.state == 7 ? nil : "still \(job.stateName)"
            case .hold: problem = job.isHeld ? nil : "still \(job.stateName)"
            case .release: problem = job.isHeld ? "still held" : nil
            case .move(let destination): problem = job.queue == destination ? nil : "still on \(job.queue)"
            }
            return ActionOutcome(succeeded: problem == nil, command: command, message: problem.map { "Not applied: \($0)" })
        } catch CupsAdminError.ipp(let status, _) where status == IPPStatus.notFound && action == .cancel {
            // Purged from history right away: canceled.
            return ActionOutcome(succeeded: true, command: command, message: nil)
        } catch {
            return ActionOutcome(succeeded: false, command: command, message: "Couldn’t read job \(jobID) back: \(error)")
        }
    }
}

// MARK: - Default, delete, test page

extension QueueActions {
    /// `lpadmin -d queue`, verified with CUPS-Get-Default.
    public static func setDefault(queue: String, client: CupsClient) async throws -> ActionOutcome {
        let result = try await Task.detached { try CupsTools.setDefault(queue: queue) }.value
        guard result.succeeded else {
            return ActionOutcome(succeeded: false, command: result.commandLine, message: result.message.isEmpty ? "exited \(result.status)" : result.message)
        }
        let current = try await client.getDefaultPrinter()
        return ActionOutcome(succeeded: current == queue, command: result.commandLine,
                             message: current == queue ? nil : "Not applied: server default is \(current ?? "none")")
    }

    /// `lpadmin -x queue`, verified by the queue being gone.
    public static func delete(queue: String, client: CupsClient) async throws -> ActionOutcome {
        let result = try await Task.detached { try CupsTools.delete(queue: queue) }.value
        guard result.succeeded else {
            return ActionOutcome(succeeded: false, command: result.commandLine, message: result.message.isEmpty ? "exited \(result.status)" : result.message)
        }
        let stillThere = try await client.queueExists(queue)
        return ActionOutcome(succeeded: !stillThere, command: result.commandLine,
                             message: stillThere ? "Not applied: \(queue) still exists" : nil)
    }

    /// Sends the CUPS test page (or a generated one-page PDF when it's missing). Returns the job id when verified.
    public static func printTestPage(queue: String, client: CupsClient) async throws -> (outcome: ActionOutcome, jobID: Int?) {
        let file = FileManager.default.fileExists(atPath: CupsTools.testPagePath)
            ? CupsTools.testPagePath : try generatedTestPage(queue: queue)
        let result = try await Task.detached { try CupsTools.printTestPage(queue: queue, file: file) }.value
        guard result.succeeded else {
            return (ActionOutcome(succeeded: false, command: result.commandLine, message: result.message.isEmpty ? "exited \(result.status)" : result.message), nil)
        }
        // "request id is Q-12 (1 file(s))"
        let text = String(decoding: result.standardOutput, as: UTF8.self)
        guard let token = text.split(separator: " ").first(where: { $0.hasPrefix(queue + "-") }),
              let id = Int(token.dropFirst(queue.count + 1)) else {
            return (ActionOutcome(succeeded: false, command: result.commandLine, message: "lp didn’t report a job id: \(text)"), nil)
        }
        let job = JobSummary(try await client.getJobAttributes(jobID: id, requested: JobSummary.requestedAttributes))
        let ok = job.queue == queue
        return (ActionOutcome(succeeded: ok, command: result.commandLine, message: ok ? nil : "Job \(id) isn’t on \(queue)"), id)
    }

    private static func generatedTestPage(queue: String) throws -> String {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("cupsadmin-testpage.pdf")
        var box = CGRect(x: 0, y: 0, width: 612, height: 792)
        guard let context = CGContext(url as CFURL, mediaBox: &box, nil) else {
            throw CupsAdminError.failed("couldn’t create a test page PDF")
        }
        context.beginPDFPage(nil)
        context.setLineWidth(4)
        context.stroke(box.insetBy(dx: 36, dy: 36))
        context.move(to: CGPoint(x: 36, y: 36)); context.addLine(to: CGPoint(x: 576, y: 756))
        context.move(to: CGPoint(x: 36, y: 756)); context.addLine(to: CGPoint(x: 576, y: 36))
        context.strokePath()
        context.endPDFPage()
        context.closePDF()
        return url.path
    }
}
