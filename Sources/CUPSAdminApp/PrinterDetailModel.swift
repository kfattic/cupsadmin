import CupsKit
import Foundation
import Observation
import OSLog

enum DetailTab: String, CaseIterable, Identifiable {
    case jobs, options
    var id: String { rawValue }
    var title: String { self == .jobs ? "Jobs" : "Options" }
}

enum JobFilter: String, CaseIterable, Identifiable {
    case active, completed, all
    var id: String { rawValue }

    var title: String {
        switch self {
        case .active: return "Active"
        case .completed: return "Completed"
        case .all: return "All"
        }
    }

    /// Get-Jobs which-jobs.
    var whichJobs: String {
        switch self {
        case .active: return "not-completed"
        case .completed: return "completed"
        case .all: return "all"
        }
    }
}

/// Header attributes and the Jobs table for one printer.
@MainActor
@Observable
final class PrinterDetailModel {
    let queue: String
    private(set) var printer: IPPGroup?
    /// Intel-only or missing driver filters, from the queue's PPD.
    private(set) var driverFilters: DriverFilterReport?
    private(set) var jobs: [JobSummary] = []
    private(set) var loadError: String?
    private(set) var isWorking = false
    var selection = Set<Int>()
    var sortOrder = [KeyPathComparator(\JobSummary.id, order: .reverse)]
    var jobFilter: JobFilter = .active {
        didSet { if jobFilter != oldValue { Task { await loadJobs() } } }
    }

    private let store: PrinterStore
    private let log = Logger(subsystem: "edu.wku.cupsadmin.app", category: "jobs")

    init(queue: String, store: PrinterStore) {
        self.queue = queue
        self.store = store
    }

    static let headerAttributes = [
        "printer-name", "printer-state", "printer-state-reasons", "printer-state-message",
        "printer-is-accepting-jobs", "printer-is-shared", "device-uri", "printer-make-and-model",
        "printer-info", "printer-location", "queued-job-count",
    ]

    var sortedJobs: [JobSummary] { jobs.sorted(using: sortOrder) }
    var selectedJobs: [JobSummary] { jobs.filter { selection.contains($0.id) } }

    /// The queue's PPD, if it has one (driverless and raw queues don't).
    var ppdPath: String? {
        let path = "/private/etc/cups/ppd/\(queue).ppd"
        return FileManager.default.fileExists(atPath: path) ? path : nil
    }

    func load() async {
        do {
            printer = try await store.client.getPrinterAttributes(queue: queue, requested: Self.headerAttributes)
            loadError = nil
            if let text = try await store.client.getPPD(queue: queue) {
                driverFilters = await Task.detached { DriverFilterCheck.check(PPD(text: text)) }.value
            } else {
                driverFilters = nil
            }
        } catch {
            loadError = String(describing: error)
            store.report("ERROR: \(queue): \(error)")
        }
        await loadJobs()
    }

    func loadJobs() async {
        do {
            let groups = try await store.client.getJobs(queue: queue, which: jobFilter.whichJobs,
                                                        requested: JobSummary.requestedAttributes)
            jobs = groups.map(JobSummary.init)
            selection = selection.intersection(jobs.map(\.id))
        } catch {
            store.report("ERROR: jobs on \(queue): \(error)")
        }
    }

    // MARK: job actions

    func canPerform(_ action: JobAction, on ids: Set<Int>) -> Bool {
        let targets = jobs.filter { ids.contains($0.id) }
        guard !targets.isEmpty, !isWorking else { return false }
        switch action {
        case .cancel, .move: return targets.allSatisfy(\.isActive)
        case .hold: return targets.allSatisfy { $0.isActive && !$0.isHeld }
        case .release: return targets.allSatisfy(\.isHeld)
        }
    }

    func perform(_ action: JobAction, on ids: Set<Int>) async {
        let ordered = ids.sorted()
        guard !ordered.isEmpty else { return }
        isWorking = true
        defer { isWorking = false }
        let started = Date()
        log.info("\(action.title, privacy: .public) jobs \(ordered.map(String.init).joined(separator: ","), privacy: .public) on \(self.queue, privacy: .public)")

        let outcomes = await QueueActions.perform(action, jobIDs: ordered, client: store.client)
        let failed = ordered.filter { outcomes[$0]?.succeeded != true }
        let seconds = Date().timeIntervalSince(started)
        let noun = ordered.count == 1 ? "job \(ordered[0])" : "\(ordered.count) jobs"
        if failed.isEmpty {
            store.report("\(action.pastTense) \(noun) in \(elapsedText(seconds))")
        } else {
            let details = failed.map { "job \($0): \(outcomes[$0]?.message ?? "failed")" }
            store.report("ERROR: \(failed.count) of \(ordered.count) not applied — \(details[0])")
            store.fail("\(action.title) didn’t apply to \(failed.count) job\(failed.count == 1 ? "" : "s")",
                       (details + failed.compactMap { outcomes[$0]?.command }.prefix(1)).joined(separator: "\n"))
        }
        log.info("\(action.title, privacy: .public): \(ordered.count - failed.count) ok, \(failed.count) failed in \(seconds, format: .fixed(precision: 3)) s")

        store.noteChange()
        await loadJobs()
        await store.refreshQuietly()
    }

    /// Tab-separated rows for the clipboard, for pasting into tickets.
    func copyText(for ids: Set<Int>) -> String {
        let header = ["ID", "Name", "User", "Size", "Pages", "State", "Reasons", "Submitted"].joined(separator: "\t")
        let rows = sortedJobs.filter { ids.contains($0.id) }.map { job in
            [String(job.id), job.name, job.user, Format.kilobytes(job.sizeK), job.pages.map(String.init) ?? "",
             job.stateName, job.reasons.joined(separator: ","), job.submitted.map(Format.timestamp) ?? ""]
                .joined(separator: "\t")
        }
        return ([header] + rows).joined(separator: "\n")
    }
}

extension JobSummary {
    var pagesSortKey: Int { pages ?? -1 }
    var reasonsText: String { reasons.joined(separator: ", ") }
    var submittedSortKey: Date { submitted ?? .distantPast }
}
