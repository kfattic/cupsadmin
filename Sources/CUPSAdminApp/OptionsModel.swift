import CupsKit
import Foundation
import Observation
import OSLog

/// Options tab state for one queue: queue defaults, pending edits, and per-row apply results.
/// Apply always writes queue defaults with `lpadmin -p queue -o` (never lpoptions).
@MainActor
@Observable
final class OptionsModel {
    enum RowStatus: Equatable {
        case applying
        case applied(note: String?)
        case failed(reason: String)
    }

    struct CustomPair: Identifiable, Equatable {
        let id = UUID()
        let key: String
        let value: String
        var status: RowStatus?
    }

    struct Failure: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    let queue: String

    private(set) var state: OptionState?
    private(set) var sections: [OptionSection] = []
    private(set) var loadError: String?
    private(set) var isApplying = false
    /// Row key -> new raw value.
    private(set) var pending: [String: String] = [:]
    /// Field text as typed, so invalid input stays visible with its error.
    private(set) var fieldText: [String: String] = [:]
    private(set) var rowStatus: [String: RowStatus] = [:]
    private(set) var customPairs: [CustomPair] = []
    var customEntry = ""
    private(set) var customEntryError: String?
    var failure: Failure?

    private let report: (String) -> Void
    private let client = CupsClient()
    private let log = Logger(subsystem: "edu.wku.cupsadmin.app", category: "options")

    init(queue: String, report: @escaping (String) -> Void) {
        self.queue = queue
        self.report = report
    }

    // MARK: loading

    func load() async {
        let started = Date()
        do {
            state = try await OptionState.load(client: client, queue: queue)
            loadError = nil
            rebuild()
            let count = sections.reduce(0) { $0 + $1.rows.count }
            report("Loaded \(count) options for \(queue) in \(elapsedText(since: started))")
            log.info("loaded \(count) options for \(self.queue, privacy: .public) in \(Date().timeIntervalSince(started), format: .fixed(precision: 3)) s")
        } catch {
            loadError = String(describing: error)
            report("ERROR: \(error)")
            log.error("load failed for \(self.queue, privacy: .public): \(String(describing: error), privacy: .public)")
        }
    }

    private func rebuild() {
        sections = state?.sections() ?? []
    }

    // MARK: values

    var hasChanges: Bool { !pending.isEmpty || customPairs.contains { $0.status == nil } }
    var changeCount: Int { pending.count + customPairs.filter { $0.status == nil }.count }
    var hasErrors: Bool { sections.flatMap(\.rows).contains { validationError($0) != nil } }

    /// The queue default before pending edits.
    func currentValue(_ row: OptionRow) -> String? {
        state?.queueValue(row.key)
    }

    /// The value shown in the control: pending edit, else current.
    func value(_ row: OptionRow) -> String? {
        pending[row.key] ?? currentValue(row)
    }

    func set(_ row: OptionRow, to newValue: String) {
        rowStatus[row.key] = nil
        pending[row.key] = newValue == currentValue(row) ? nil : newValue
    }

    func fieldText(_ row: OptionRow, field: CustomField) -> String {
        fieldText[row.key] ?? field.text(fromValue: value(row))
    }

    func setFieldText(_ text: String, row: OptionRow, field: CustomField) {
        fieldText[row.key] = text
        set(row, to: field.value(fromText: text))
        if pending[row.key] == nil { fieldText[row.key] = nil }
    }

    func validationError(_ row: OptionRow) -> String? {
        guard case .field(let field) = row.control, let text = fieldText[row.key] else { return nil }
        return field.validationError(text)
    }

    func isPending(_ row: OptionRow) -> Bool { pending[row.key] != nil }

    /// Your own ~/.cups/lpoptions value wins over the queue default for your jobs; say so.
    func overrideNote(_ row: OptionRow) -> String? {
        guard let state, let mine = state.userOverride(row.key) else { return nil }
        return "Your ~/.cups/lpoptions overrides this for your jobs: \(state.display(mine, row: row))"
    }

    // MARK: custom option row

    func addCustomEntry() {
        let entry = customEntry.trimmingCharacters(in: .whitespaces)
        guard let eq = entry.firstIndex(of: "="), eq != entry.startIndex else {
            customEntryError = "Use keyword=value"
            return
        }
        let key = String(entry[..<eq])
        guard !key.contains(where: \.isWhitespace) else {
            customEntryError = "Keyword can't contain spaces"
            return
        }
        customPairs.append(CustomPair(key: key, value: String(entry[entry.index(after: eq)...])))
        customEntry = ""
        customEntryError = nil
    }

    func removeCustomPair(_ pair: CustomPair) {
        customPairs.removeAll { $0.id == pair.id }
    }

    // MARK: apply

    struct ChangeSummary: Identifiable {
        let id: String
        let label: String
        let from: String
        let to: String
    }

    var changes: [OptionChange] {
        let rows = Dictionary(uniqueKeysWithValues: sections.flatMap(\.rows).map { ($0.key, $0) })
        let edits = pending.keys.sorted().map { key in
            OptionChange(key: key, value: pending[key]!, isSecret: rows[key]?.isSecret ?? false)
        }
        let raw = customPairs.filter { $0.status == nil }.map {
            OptionChange(key: $0.key, value: $0.value, isSecret: rows[$0.key]?.isSecret ?? false)
        }
        return edits + raw
    }

    var changeSummaries: [ChangeSummary] {
        guard let state else { return [] }
        let rows = Dictionary(uniqueKeysWithValues: sections.flatMap(\.rows).map { ($0.key, $0) })
        return changes.map { change in
            guard let row = rows[change.key] else {
                return ChangeSummary(id: change.key, label: change.key, from: state.queueValue(change.key) ?? "—",
                                     to: change.value)
            }
            return ChangeSummary(id: change.key, label: "\(row.label) (\(row.key))",
                                 from: state.display(currentValue(row), row: row), to: state.display(change.value, row: row))
        }
    }

    var command: String {
        OptionApplier.displayCommand(queue: queue, changes: changes)
    }

    /// Shown in the apply sheet when passwords would land in a world-readable file.
    var secretWarning: String? {
        let secrets = changes.filter(\.isSecret)
        guard !secrets.isEmpty else { return nil }
        let names = secrets.map(\.key).joined(separator: ", ")
        return "\(names) will be saved in plain text in /etc/cups/ppd/\(queue).ppd as the queue default. "
            + "Every user on this Mac can read that file, and every job on this queue will send it."
    }

    let scopeDescription = "Every user on this Mac · lpadmin"

    func revert() {
        pending = [:]
        fieldText = [:]
        customPairs.removeAll { $0.status == nil }
        rowStatus = [:]
    }

    func apply() async {
        let changes = self.changes
        guard !changes.isEmpty, !isApplying else { return }
        isApplying = true
        defer { isApplying = false }
        let started = Date()
        for change in changes { rowStatus[change.key] = .applying }
        for i in customPairs.indices where customPairs[i].status == nil { customPairs[i].status = .applying }
        log.info("apply \(changes.count) options on \(self.queue, privacy: .public) with lpadmin")

        do {
            let (result, readBack, newState) = try await OptionApplier.apply(client: client, queue: queue, changes: changes)
            state = newState
            rebuild()
            pending = [:]
            fieldText = [:]
            for check in readBack {
                let status: RowStatus = check.applied ? .applied(note: check.reason) : .failed(reason: check.reason ?? "Not applied")
                rowStatus[check.key] = status
                if let i = customPairs.firstIndex(where: { $0.key == check.key && $0.status == .applying }) {
                    customPairs[i].status = status
                }
            }

            let failed = readBack.filter { !$0.applied }
            let seconds = Date().timeIntervalSince(started)
            if failed.isEmpty {
                report("Set \(changes.count) option\(changes.count == 1 ? "" : "s") on \(queue) in \(elapsedText(seconds))")
            } else {
                report("ERROR: \(failed.count) of \(changes.count) not applied on \(queue): "
                       + failed.map(\.key).joined(separator: ", ") + " — \(failed[0].reason ?? "")")
            }
            log.info("apply finished on \(self.queue, privacy: .public): \(changes.count - failed.count) applied, \(failed.count) failed in \(seconds, format: .fixed(precision: 3)) s")

            if !result.succeeded {
                failure = Failure(title: "Couldn’t Change Options on \(queue)", message: Self.explain(result))
            }
        } catch {
            for change in changes { rowStatus[change.key] = .failed(reason: String(describing: error)) }
            for i in customPairs.indices where customPairs[i].status == .applying {
                customPairs[i].status = .failed(reason: String(describing: error))
            }
            report("ERROR: \(error)")
            failure = Failure(title: "Couldn’t Change Options on \(queue)", message: String(describing: error))
            log.error("apply failed on \(self.queue, privacy: .public): \(String(describing: error), privacy: .public)")
        }
    }

    /// Tool output plus the fix when it's a permissions problem.
    private static func explain(_ result: ToolResult) -> String {
        let message = result.message.isEmpty ? "\(result.commandLine) exited \(result.status)" : result.message
        let lower = message.lowercased()
        if lower.contains("forbidden") || lower.contains("not authorized") || lower.contains("unauthorized")
            || lower.contains("authentication") {
            return message + "\n\nChanging queue defaults needs an admin account or membership in _lpadmin:\n"
                + "sudo dseditgroup -o edit -a \(NSUserName()) -t user _lpadmin"
        }
        return message
    }
}
