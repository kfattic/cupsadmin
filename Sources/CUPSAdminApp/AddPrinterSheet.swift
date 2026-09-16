import AppKit
import CupsKit
import Observation
import SwiftUI

/// Add Printer (manual) and Modify Printer: name, device URI, driver, description, location, shared.
@MainActor
@Observable
final class AddPrinterModel: Identifiable {
    enum Driver: String, CaseIterable, Identifiable {
        case keep, everywhere, list, file
        var id: String { rawValue }
        var title: String {
            switch self {
            case .keep: return "Keep Current"
            case .everywhere: return "IPP Everywhere"
            case .list: return "Driver List"
            case .file: return "PPD File"
            }
        }
    }

    struct Model: Identifiable, Hashable {
        let model: String
        let name: String
        var id: String { model }
    }

    let id = UUID()
    /// nil when adding.
    let original: PrinterOriginal?
    var name = ""
    var deviceURI = ""
    var driver: Driver
    var modelSearch = ""
    var selectedModel: String?
    var ppdFile: String?
    var descriptionText = ""
    var location = ""
    var shared = false
    private(set) var models: [Model] = []
    private(set) var modelsError: String?
    private(set) var isRunning = false
    private(set) var errorText: String?
    private(set) var checks: [SettingCheck] = []
    private let store: PrinterStore

    struct PrinterOriginal {
        let name: String
        let deviceURI: String
        let description: String
        let location: String
        let shared: Bool
    }

    var isModify: Bool { original != nil }

    init(store: PrinterStore, modifying printer: IPPGroup? = nil) {
        self.store = store
        if let printer {
            let original = PrinterOriginal(name: printer.string("printer-name") ?? "",
                                           deviceURI: printer.string("device-uri") ?? "",
                                           description: printer.string("printer-info") ?? "",
                                           location: printer.string("printer-location") ?? "",
                                           shared: printer.bool("printer-is-shared") ?? false)
            self.original = original
            name = original.name
            deviceURI = original.deviceURI
            descriptionText = original.description
            location = original.location
            shared = original.shared
            driver = .keep
        } else {
            original = nil
            driver = .everywhere
        }
    }

    var drivers: [Driver] { isModify ? Driver.allCases : Driver.allCases.filter { $0 != .keep } }

    var filteredModels: [Model] {
        let terms = modelSearch.split(separator: " ")
        guard !terms.isEmpty else { return models }
        return models.filter { m in terms.allSatisfy { m.name.localizedCaseInsensitiveContains($0) || m.model.localizedCaseInsensitiveContains($0) } }
    }

    var nameError: String? {
        guard !isModify, !name.isEmpty else { return nil }
        do { try QueueAdmin.validateQueueName(name) } catch { return "No spaces, / \\ ? ' \" #; up to 127 bytes" }
        if store.printers.contains(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
            return "A queue named \(name) already exists"
        }
        return nil
    }

    /// Only what changed, for Modify (so the PPD isn't regenerated needlessly); everything for Add.
    var spec: QueueSpec {
        var spec = QueueSpec()
        let uri = deviceURI.trimmingCharacters(in: .whitespaces)
        if original?.deviceURI != uri { spec.deviceURI = uri.isEmpty ? "<device-uri>" : uri }
        switch driver {
        case .keep: break
        case .everywhere: spec.model = "everywhere"
        case .list: spec.model = selectedModel
        case .file: spec.ppdFile = ppdFile
        }
        if original?.description != descriptionText, !(original == nil && descriptionText.isEmpty) { spec.description = descriptionText }
        if original?.location != location, !(original == nil && location.isEmpty) { spec.location = location }
        if let original, original.shared != shared {
            spec.options.append((key: "printer-is-shared", value: shared ? "true" : "false"))
        }
        return spec
    }

    var canSubmit: Bool {
        guard !isRunning, !deviceURI.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        if !isModify, name.isEmpty || nameError != nil { return false }
        if driver == .list, selectedModel == nil { return false }
        if driver == .file, ppdFile == nil { return false }
        if isModify, spec.isEmpty { return false }
        return true
    }

    var command: String {
        let args: [String]
        if isModify {
            args = spec.lpadminArguments(queue: name)
        } else {
            var addSpec = spec
            addSpec.options.append((key: "printer-is-shared", value: shared ? "true" : "false"))
            args = QueueAdmin.addArguments(queue: name.isEmpty ? "<name>" : name, spec: addSpec)
        }
        return CupsTools.commandLine(CupsTools.lpadminPath, args)
    }

    func loadModels() async {
        guard models.isEmpty else { return }
        do {
            let list = try await Task.detached { try CupsTools.models() }.value
            models = list.map { Model(model: $0.model, name: $0.name) }
                .filter { $0.model != "everywhere" && $0.model != "raw" }
                .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        } catch {
            modelsError = String(describing: error)
        }
    }

    func choosePPDFile() {
        let panel = NSOpenPanel()
        panel.title = "Choose a PPD"
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: "/Library/Printers/PPDs/Contents/Resources")
        if panel.runModal() == .OK, let url = panel.url { ppdFile = url.path }
    }

    /// Returns true when every setting read back correctly.
    func submit() async -> Bool {
        isRunning = true
        defer { isRunning = false }
        errorText = nil
        checks = []
        let started = Date()
        let client = store.client
        do {
            if isModify {
                let spec = self.spec
                _ = try await QueueAdmin.prepareSet(client: client, queue: name, spec: spec)
                let result = try await Task.detached { [name] in try CupsTools.lpadmin(spec.lpadminArguments(queue: name)) }.value
                checks = try await QueueAdmin.confirmSet(client: client, queue: name, spec: spec, lpadminStatus: result.status)
                if !result.succeeded { errorText = result.message }
            } else {
                let prepared = try await QueueAdmin.prepareAdd(client: client, queue: name, spec: spec, shared: shared)
                let result = try await Task.detached { [name] in try CupsTools.lpadmin(QueueAdmin.addArguments(queue: name, spec: prepared)) }.value
                if !result.succeeded {
                    errorText = PrinterStore.explain(result.message.isEmpty ? "lpadmin exited \(result.status)" : result.message)
                } else {
                    let snapshot = try await QueueAdmin.confirmAdded(client: client, queue: name, lpadminStatus: result.status)
                    checks = snapshot.settings(for: prepared)
                }
            }
        } catch {
            errorText = PrinterStore.explain(String(describing: error))
        }

        let failed = checks.filter { !$0.applied }
        let verb = isModify ? "Modified" : "Added"
        let ok = errorText == nil && failed.isEmpty
        if ok {
            store.report("\(verb) \(name) in \(elapsedText(since: started)), \(checks.count) setting\(checks.count == 1 ? "" : "s") verified")
        } else {
            if errorText == nil {
                errorText = "Not applied: " + failed.map { "\($0.name) (wanted \($0.wanted), is \($0.value ?? "nothing"))" }.joined(separator: "; ")
            }
            store.report("ERROR: \(isModify ? "modify" : "add") \(name): \(errorText!)")
        }
        store.noteChange(queue: name)
        await store.refreshQuietly()
        return ok
    }
}

struct AddPrinterSheet: View {
    @Bindable var model: AddPrinterModel
    let onFinished: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(model.isModify ? "Modify \(model.name)" : "Add Printer")
                .font(.title3.weight(.semibold))
                .padding([.horizontal, .top], 20)

            Form {
                Section {
                    LabeledContent {
                        if model.isModify {
                            Text(model.name).monospaced()
                        } else {
                            TextField("Name", text: $model.name, prompt: Text("Queue name"))
                                .labelsHidden()
                                .textFieldStyle(.roundedBorder)
                        }
                    } label: {
                        Text("Name")
                        if let error = model.nameError { Text(error).foregroundStyle(.red) }
                    }
                    LabeledContent("Device URI") {
                        TextField("Device URI", text: $model.deviceURI, prompt: Text("ipp://printer.example.edu/ipp/print"))
                            .labelsHidden()
                            .textFieldStyle(.roundedBorder)
                            .monospaced()
                    }
                }

                Section("Driver") {
                    Picker("Driver", selection: $model.driver) {
                        ForEach(model.drivers) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()

                    switch model.driver {
                    case .keep:
                        Text("The queue keeps its PPD and all option defaults.")
                            .foregroundStyle(.secondary)
                    case .everywhere:
                        Text("cupsd builds the PPD from the printer (lpadmin -m everywhere). The printer must be reachable.")
                            .foregroundStyle(.secondary)
                    case .list:
                        TextField("Search drivers", text: $model.modelSearch, prompt: Text("Search \(model.models.count) drivers"))
                            .textFieldStyle(.roundedBorder)
                        List(model.filteredModels, selection: $model.selectedModel) { item in
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.name)
                                Text(item.model).font(.caption).monospaced().foregroundStyle(.secondary)
                            }
                            .tag(item.model)
                        }
                        .frame(height: 170)
                        .overlay {
                            if let error = model.modelsError {
                                ContentUnavailableView("Can’t List Drivers", systemImage: "exclamationmark.triangle",
                                                       description: Text(error))
                            } else if model.models.isEmpty {
                                ProgressView()
                            }
                        }
                        .task { await model.loadModels() }
                    case .file:
                        LabeledContent {
                            Button("Choose PPD File…") { model.choosePPDFile() }
                        } label: {
                            Text(model.ppdFile ?? "No file chosen")
                                .monospaced(model.ppdFile != nil)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                }

                Section {
                    LabeledContent("Description") {
                        TextField("Description", text: $model.descriptionText, prompt: Text("Optional"))
                            .labelsHidden()
                            .textFieldStyle(.roundedBorder)
                    }
                    LabeledContent("Location") {
                        TextField("Location", text: $model.location, prompt: Text("Optional"))
                            .labelsHidden()
                            .textFieldStyle(.roundedBorder)
                    }
                    Toggle("Share this printer on the network", isOn: $model.shared)
                }

                Section("Command") {
                    Text(model.command)
                        .font(.system(.callout, design: .monospaced))
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                    if let error = model.errorText {
                        Label(error, systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                if model.isRunning { ProgressView().controlSize(.small) }
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(model.isModify ? "Save" : "Add Printer") {
                    Task {
                        if await model.submit() {
                            onFinished(model.name)
                            dismiss()
                        }
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!model.canSubmit)
            }
            .padding([.horizontal, .bottom], 20)
            .padding(.top, 8)
        }
        .frame(width: 600, height: model.driver == .list ? 760 : 600)
    }
}
