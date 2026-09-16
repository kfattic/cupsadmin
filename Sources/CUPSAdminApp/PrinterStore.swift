import AppKit
import CupsKit
import Foundation
import Observation
import OSLog
import SwiftUI

/// One sidebar row's worth of queue state, from CUPS-Get-Printers.
struct PrinterSummary: Identifiable, Hashable {
    enum Status {
        case idle, processing, stopped

        var color: Color {
            switch self {
            case .idle: return .green
            case .processing: return .blue
            case .stopped: return .red
            }
        }
    }

    let name: String
    let state: Int?
    let reasons: [String]
    let stateMessage: String?
    let accepting: Bool
    let info: String?
    let location: String?
    let deviceURI: String?
    let jobCount: Int

    var id: String { name }

    static let requestedAttributes = [
        "printer-name", "printer-state", "printer-state-reasons", "printer-state-message",
        "printer-is-accepting-jobs", "printer-info", "printer-location", "device-uri", "queued-job-count",
    ]

    init(_ attributes: IPPGroup) {
        name = attributes.string("printer-name") ?? "?"
        state = attributes.int("printer-state")
        reasons = attributes.strings("printer-state-reasons").filter { $0 != "none" }
        stateMessage = attributes.string("printer-state-message").flatMap { $0.isEmpty ? nil : $0 }
        accepting = attributes.bool("printer-is-accepting-jobs") ?? true
        info = attributes.string("printer-info").flatMap { $0.isEmpty ? nil : $0 }
        location = attributes.string("printer-location").flatMap { $0.isEmpty ? nil : $0 }
        deviceURI = attributes.string("device-uri").flatMap { $0.isEmpty ? nil : $0 }
        jobCount = attributes.int("queued-job-count") ?? 0
    }

    var isPaused: Bool { state == 5 }

    /// Red when stopped or rejecting jobs, blue while printing, green otherwise.
    var status: Status {
        if state == 5 || !accepting { return .stopped }
        return state == 4 ? .processing : .idle
    }

    /// Location, else description, else nothing — never text that just restates the name, an IP or a URI.
    var secondaryLine: String? {
        [location, info].compactMap { $0 }.first { !Self.restates($0, name: name) }
    }

    static func restates(_ text: String, name: String) -> Bool {
        func letters(_ s: String) -> String { s.lowercased().filter { $0.isLetter || $0.isNumber } }
        if letters(text) == letters(name) { return true }
        if text.contains("://") { return true }
        return text.range(of: #"^\d{1,3}(\.\d{1,3}){3}$"#, options: .regularExpression) != nil
    }

    /// "Idle", "Stopped — paused", "Idle, rejecting jobs".
    var stateSummary: String {
        var text = Format.printerState(state).capitalized
        if !reasons.isEmpty { text += " — " + reasons.joined(separator: ", ") }
        if !accepting { text += ", rejecting jobs" }
        return text
    }

    func matches(search: String) -> Bool {
        guard !search.isEmpty else { return true }
        return [name, location, info, deviceURI].compactMap { $0 }
            .contains { $0.localizedCaseInsensitiveContains(search) }
    }
}

@MainActor
@Observable
final class PrinterStore {
    struct Failure: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    private(set) var printers: [PrinterSummary] = []
    private(set) var isRefreshing = false
    private(set) var hasLoaded = false
    private(set) var errorMessage: String?
    private(set) var statusLine = ""
    /// Bumped after any write, so open detail views reload.
    private(set) var revision = 0
    /// The server default printer (CUPS-Get-Default), if any.
    private(set) var defaultPrinter: String?
    /// Parsed PPDs, for enabling Quick Actions per printer. A queue with no PPD maps to nil.
    private(set) var ppds: [String: PPD?] = [:]
    var failure: Failure?

    let client = CupsClient()
    private let log = Logger(subsystem: "edu.wku.cupsadmin.app", category: "store")

    /// `--only-queues a,b,c` limits the app to those queues (used by `build.sh --screenshots`).
    static let onlyQueues: Set<String>? = {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "--only-queues"), i + 1 < args.count else { return nil }
        return Set(args[i + 1].split(separator: ",").map(String.init))
    }()

    /// "21 printers · 0 active jobs" for the status bar.
    var summaryLine: String {
        guard hasLoaded, errorMessage == nil else { return "" }
        let jobs = printers.reduce(0) { $0 + $1.jobCount }
        return "\(printers.count) printer\(printers.count == 1 ? "" : "s") · \(jobs) active job\(jobs == 1 ? "" : "s")"
    }

    /// Last-action line for the status bar, from any view.
    func report(_ line: String) {
        statusLine = line
    }

    func fail(_ title: String, _ message: String) {
        failure = Failure(title: title, message: Self.explain(message))
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        let started = Date()
        log.info("refresh started")

        do {
            let groups = try await client.getPrinters(requested: PrinterSummary.requestedAttributes)
            printers = groups.map(PrinterSummary.init)
                .filter { Self.onlyQueues?.contains($0.name) ?? true }
                .sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
            errorMessage = nil
            defaultPrinter = try? await client.getDefaultPrinter()
            let seconds = Date().timeIntervalSince(started)
            statusLine = "Refreshed \(printers.count) printers in \(elapsedText(seconds))"
            log.info("refresh finished: \(self.printers.count) printers in \(seconds, format: .fixed(precision: 3)) s")
        } catch {
            errorMessage = String(describing: error)
            statusLine = "ERROR: \(error)"
            log.error("refresh failed: \(String(describing: error), privacy: .public)")
        }
        hasLoaded = true
    }

    /// Pause/Resume/Accept/Reject/Cancel All, verified against cupsd, reported in the status bar.
    func perform(_ action: PrinterAction, on queue: String) async {
        let started = Date()
        log.info("\(action.title, privacy: .public) \(queue, privacy: .public)")
        do {
            let outcome = try await QueueActions.perform(action, queue: queue, client: client)
            let seconds = Date().timeIntervalSince(started)
            if outcome.succeeded {
                report("\(action.pastTense) \(queue) in \(elapsedText(seconds))")
                log.info("\(action.title, privacy: .public) \(queue, privacy: .public) ok in \(seconds, format: .fixed(precision: 3)) s")
            } else {
                let message = outcome.message ?? "failed"
                report("ERROR: \(action.title) \(queue): \(message)")
                fail("Couldn’t \(action.title.lowercased()) \(queue)", "\(message)\n\n\(outcome.command)")
                log.error("\(action.title, privacy: .public) \(queue, privacy: .public) failed: \(message, privacy: .public)")
            }
        } catch {
            report("ERROR: \(action.title) \(queue): \(error)")
            fail("Couldn’t \(action.title.lowercased()) \(queue)", String(describing: error))
        }
        revision += 1
        await refreshQuietly()
    }

    /// Refresh the sidebar without replacing the last action's status line.
    func refreshQuietly() async {
        let line = statusLine
        await refresh()
        statusLine = line
    }

    func noteChange(queue: String? = nil) {
        if let queue { ppds[queue] = nil }
        revision += 1
    }

    // MARK: PPDs for Quick Actions

    /// Fetches PPDs not yet cached, in the background of a refresh.
    func loadPPDs() async {
        for printer in printers where ppds[printer.name] == nil {
            let text = try? await client.getPPD(queue: printer.name)
            ppds[printer.name] = .some(text.map(PPD.init(text:)))
        }
    }

    /// nil when the action can run on the queue, else why not (shown as the menu item's tooltip).
    func unavailableReason(_ action: QuickAction, queue: String) -> String? {
        if case .defaultPrinter = action.effect {
            return defaultPrinter == queue ? "\(queue) is already the default printer" : nil
        }
        guard let cached = ppds[queue] else { return "Checking \(queue)’s PPD…" }
        if action.isAvailable(for: cached) { return nil }
        if case .failure(let unavailable) = action.changes(for: cached, value: action.input == .userCode ? "0" : nil) {
            return unavailable.reason
        }
        return "Not available on \(queue)"
    }

    // MARK: per-printer actions

    func printTestPage(_ queue: String) async {
        let started = Date()
        do {
            let (outcome, jobID) = try await QueueActions.printTestPage(queue: queue, client: client)
            if outcome.succeeded, let jobID {
                report("Sent test page to \(queue) as job \(jobID) in \(elapsedText(since: started))")
                log.info("test page \(queue, privacy: .public) job \(jobID)")
            } else {
                report("ERROR: test page on \(queue): \(outcome.message ?? "failed")")
                fail("Couldn’t print a test page on \(queue)", "\(outcome.message ?? "failed")\n\n\(outcome.command)")
            }
        } catch {
            report("ERROR: test page on \(queue): \(error)")
            fail("Couldn’t print a test page on \(queue)", String(describing: error))
        }
        noteChange()
        await refreshQuietly()
    }

    /// Returns true when the queue is gone.
    func delete(_ queue: String) async -> Bool {
        let started = Date()
        var deleted = false
        do {
            let outcome = try await QueueActions.delete(queue: queue, client: client)
            deleted = outcome.succeeded
            if deleted {
                report("Deleted \(queue) in \(elapsedText(since: started))")
                log.info("deleted \(queue, privacy: .public)")
            } else {
                report("ERROR: delete \(queue): \(outcome.message ?? "failed")")
                fail("Couldn’t delete \(queue)", "\(outcome.message ?? "failed")\n\n\(outcome.command)")
            }
        } catch {
            report("ERROR: delete \(queue): \(error)")
            fail("Couldn’t delete \(queue)", String(describing: error))
        }
        ppds[queue] = nil
        noteChange()
        await refreshQuietly()
        return deleted
    }

    func showPPDInFinder(_ queue: String) {
        let url = URL(fileURLWithPath: "/private/etc/cups/ppd/\(queue).ppd")
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    func hasPPDFile(_ queue: String) -> Bool {
        FileManager.default.fileExists(atPath: "/private/etc/cups/ppd/\(queue).ppd")
    }

    func copyDeviceURI(_ printer: PrinterSummary) {
        guard let uri = printer.deviceURI else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(uri, forType: .string)
        report("Copied device URI for \(printer.name)")
    }

    /// Tool/IPP output plus the fix when it's a permissions problem.
    static func explain(_ message: String) -> String {
        let lower = message.lowercased()
        if lower.contains("forbidden") || lower.contains("not authorized") || lower.contains("unauthorized")
            || lower.contains("authentication") || lower.contains("not-authorized") {
            return message + "\n\nThis needs an admin account or membership in _lpadmin:\n"
                + "sudo dseditgroup -o edit -a \(NSUserName()) -t user _lpadmin"
        }
        return message
    }
}

/// "42 ms" under a tenth of a second, else "0.4 s".
func elapsedText(_ seconds: TimeInterval) -> String {
    seconds < 0.1 ? "\(max(1, Int((seconds * 1000).rounded()))) ms" : String(format: "%.1f s", seconds)
}

func elapsedText(since start: Date) -> String {
    elapsedText(Date().timeIntervalSince(start))
}
