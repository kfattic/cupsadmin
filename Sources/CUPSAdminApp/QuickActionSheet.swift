import CupsKit
import Observation
import SwiftUI

/// One Quick Action on one printer: shows what will change, asks only for what's needed, runs lpadmin, reads back.
@MainActor
@Observable
final class QuickActionModel: Identifiable {
    enum Phase: Equatable {
        case loading, ready, running, finished(succeeded: Bool)
    }

    let id = UUID()
    let action: QuickAction
    let queue: String
    var code = ""
    var showCurrentCode = false
    private(set) var phase: Phase = .loading
    private(set) var state: OptionState?
    private(set) var currentDefault: String?
    private(set) var readBack: [String: OptionReadBack] = [:]
    private(set) var resultMessage: String?
    private let store: PrinterStore

    init(action: QuickAction, queue: String, store: PrinterStore) {
        self.action = action
        self.queue = queue
        self.store = store
    }

    func load() async {
        do {
            state = try await OptionState.load(client: store.client, queue: queue)
            currentDefault = try await store.client.getDefaultPrinter()
            phase = .ready
        } catch {
            resultMessage = String(describing: error)
            phase = .finished(succeeded: false)
        }
    }

    var context: DriverContext {
        DriverContext(ppd: state?.ppd, attributes: state?.snapshot.attributes)
    }

    var currentCode: String? { action.currentCode(context) }

    /// "Use Letter Paper" or "Use Letter Paper, Fit to Nearest Size", depending on the driver.
    var title: String { action.title(in: state == nil ? nil : context).replacingOccurrences(of: "…", with: "") }

    var validationError: String? { action.validationError(code, context: context) }

    /// What will be written, or why the action can't run here.
    func plannedChanges(clearing: Bool = false) -> Result<[OptionChange], QuickActionUnavailable> {
        action.resolve(context, value: clearing ? nil : code, clearing: clearing).map(\.changes)
    }

    /// "Ricoh", "Generic (…)" — which driver profile supplied the keywords.
    var profileName: String? {
        guard !action.isDefaultPrinter, case .success(let resolved) = action.resolve(context, value: code.isEmpty ? "0" : code) else { return nil }
        return resolved.profile.name
    }

    var command: String {
        if action.isDefaultPrinter { return CupsTools.commandLine(CupsTools.lpadminPath, ["-d", queue]) }
        guard case .success(let changes) = plannedChanges() else { return "" }
        return OptionApplier.displayCommand(queue: queue, changes: changes)
    }

    /// `lpstat` and apps use ~/.cups/lpoptions' Default line over the server default.
    var userDefaultNote: String? {
        guard action.isDefaultPrinter,
              let text = try? String(contentsOf: LpOptionsFile.userFileURL, encoding: .utf8),
              let line = text.split(whereSeparator: \.isNewline).first(where: { $0.hasPrefix("Default ") }) else { return nil }
        let name = line.split(separator: " ")[1].split(separator: "/")[0]
        guard name != queue else { return nil }
        let exists = store.printers.contains { $0.name == name }
        return "Your ~/.cups/lpoptions has “Default \(name)”, which overrides the server default for your account"
            + (exists ? "." : " — and there is no queue named \(name) on this Mac.")
    }

    func run(clearing: Bool = false) async {
        phase = .running
        let started = Date()
        do {
            let outcome = try await action.run(queue: queue, value: action.input == .userCode && !clearing ? code : nil,
                                               clearing: clearing, client: store.client)
            readBack = Dictionary(uniqueKeysWithValues: outcome.readBack.map { ($0.key, $0) })
            state = try? await OptionState.load(client: store.client, queue: queue)
            let seconds = elapsedText(since: started)
            let title = clearing ? "Cleared user code" : self.title
            if outcome.succeeded {
                resultMessage = nil
                store.report("\(title) on \(queue) in \(seconds)")
            } else {
                resultMessage = outcome.message ?? "Not applied"
                store.report("ERROR: \(title) on \(queue): \(resultMessage!)")
            }
            phase = .finished(succeeded: outcome.succeeded)
        } catch let unavailable as QuickActionUnavailable {
            resultMessage = unavailable.reason
            phase = .finished(succeeded: false)
        } catch {
            resultMessage = PrinterStore.explain(String(describing: error))
            store.report("ERROR: \(title) on \(queue): \(error)")
            phase = .finished(succeeded: false)
        }
        store.noteChange(queue: queue)
        await store.refreshQuietly()
    }
}

struct QuickActionSheet: View {
    @Bindable var model: QuickActionModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Label(model.title, systemImage: model.action.systemImage)
                    .font(.title3.weight(.semibold))
                Text("\(model.queue) · saved as the queue default for every user on this Mac")
                    .foregroundStyle(.secondary)
                if let driver = model.state.map({ _ in model.context.driverName }), let profile = model.profileName {
                    Text("\(driver) · driver profile: \(profile)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            switch model.phase {
            case .loading:
                ProgressView().frame(maxWidth: .infinity)
            default:
                content
            }

            HStack {
                if model.action.input == .userCode, model.currentCode != nil, model.phase == .ready {
                    Button("Clear Code", role: .destructive) { Task { await model.run(clearing: true) } }
                }
                Spacer()
                switch model.phase {
                case .finished:
                    Button("Done") { dismiss() }
                        .keyboardShortcut(.defaultAction)
                default:
                    Button("Cancel", role: .cancel) { dismiss() }
                        .keyboardShortcut(.cancelAction)
                    Button("Apply") { Task { await model.run() } }
                        .keyboardShortcut(.defaultAction)
                        .disabled(!canApply)
                }
            }
        }
        .padding(20)
        .frame(width: 520)
        .task { await model.load() }
    }

    private var canApply: Bool {
        guard model.phase == .ready else { return false }
        if model.action.input == .userCode {
            return !model.code.isEmpty && model.validationError == nil
        }
        if case .failure = model.plannedChanges() { return false }
        return true
    }

    @ViewBuilder private var content: some View {
        if model.action.input == .userCode {
            Form {
                LabeledContent("Current code") {
                    HStack(spacing: 8) {
                        if let current = model.currentCode {
                            Text(model.showCurrentCode ? current : String(repeating: "•", count: current.count))
                                .monospaced()
                                .textSelection(.enabled)
                            Toggle("Show", isOn: $model.showCurrentCode)
                                .toggleStyle(.checkbox)
                        } else {
                            Text("None").foregroundStyle(.secondary)
                        }
                    }
                }
                LabeledContent {
                    TextField("User code", text: $model.code, prompt: Text("Digits"))
                        .labelsHidden()
                        .textFieldStyle(.roundedBorder)
                        .monospacedDigit()
                        .frame(width: 160)
                        .disabled(model.phase != .ready)
                } label: {
                    Text("New code")
                    if let error = model.validationError {
                        Text(error).foregroundStyle(.red)
                    }
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .frame(height: 130)
        }

        if model.action.isDefaultPrinter {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                GridRow {
                    Text("Server default").foregroundStyle(.secondary)
                    Text(model.currentDefault ?? "None")
                    Image(systemName: "arrow.right").foregroundStyle(.secondary)
                    Text(model.queue)
                    resultIcon(applied: model.phase == .finished(succeeded: true) ? true
                               : model.phase == .finished(succeeded: false) ? false : nil)
                }
            }
            if let note = model.userDefaultNote {
                Label(note, systemImage: "info.circle")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            switch model.plannedChanges() {
            case .failure(let unavailable) where model.action.input == .none:
                Label(unavailable.reason, systemImage: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)
            default:
                changeGrid
            }
        }

        if !model.command.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("Command").font(.callout.weight(.semibold)).foregroundStyle(.secondary)
                Text(model.command)
                    .font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }

        if let message = model.resultMessage {
            Label(message, systemImage: "xmark.circle.fill")
                .foregroundStyle(.red)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder private var changeGrid: some View {
        let changes = (try? model.plannedChanges().get()) ?? []
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
            GridRow {
                Text("Setting"); Text("Current"); Text(""); Text("New"); Text("")
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(.secondary)
            Divider()
            ForEach(changes, id: \.key) { change in
                GridRow {
                    Text(change.key).monospaced()
                    Text(model.state?.queueValue(change.key) ?? "—").foregroundStyle(.secondary).monospaced()
                    Image(systemName: "arrow.right").foregroundStyle(.secondary)
                    Text(model.action.input == .userCode && change.key == "RIUserCode" && !model.code.isEmpty
                         ? "Custom.\(model.code)" : change.value).monospaced()
                    resultIcon(applied: model.readBack[change.key]?.applied)
                        .help(model.readBack[change.key]?.reason ?? "")
                }
            }
        }
        .textSelection(.enabled)
    }

    @ViewBuilder private func resultIcon(applied: Bool?) -> some View {
        switch applied {
        case true?: Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case false?: Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
        case nil:
            if model.phase == .running { ProgressView().controlSize(.mini) } else { Color.clear.frame(width: 14, height: 14) }
        }
    }
}
