import CupsKit
import SwiftUI

/// The web UI's "Set Default Options" page: every PPD option by group, IPP defaults, and queue policies.
struct OptionsView: View {
    @Bindable var model: OptionsModel
    @State private var showingApplySheet = false

    var body: some View {
        Group {
            if model.state == nil, let error = model.loadError {
                ContentUnavailableView("Can’t Load Options", systemImage: "exclamationmark.triangle",
                                       description: Text(error))
            } else if model.state == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                form
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) { actionBar }
        .sheet(isPresented: $showingApplySheet) {
            ApplyOptionsSheet(model: model) {
                showingApplySheet = false
                Task { await model.apply() }
            }
        }
        .alert(item: $model.failure) { failure in
            Alert(title: Text(failure.title), message: Text(failure.message))
        }
        .task(id: model.queue) { await model.load() }
    }

    private var actionBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(model.scopeDescription)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer(minLength: 12)

                if model.isApplying {
                    ProgressView().controlSize(.small)
                } else if model.hasChanges {
                    Text("\(model.changeCount) unsaved change\(model.changeCount == 1 ? "" : "s")")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .accessibilityIdentifier("options.changeCount")
                }
                Button("Revert") { model.revert() }
                    .disabled(!model.hasChanges || model.isApplying)
                    .accessibilityIdentifier("options.revert")
                Button("Apply…") { showingApplySheet = true }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!model.hasChanges || model.hasErrors || model.isApplying)
                    .accessibilityIdentifier("options.apply")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            Divider()
        }
        .background(.bar)
    }

    private var form: some View {
        Form {
            ForEach(model.sections) { section in
                Section {
                    ForEach(section.rows) { row in
                        OptionRowView(model: model, row: row)
                    }
                } header: {
                    Text(section.title)
                } footer: {
                    if section.title == "IPP" {
                        Text("Queue-wide IPP defaults. On PPD queues, media, sides, output bin, resolution and color follow their PPD option.")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                ForEach(model.customPairs) { pair in
                    LabeledContent {
                        HStack(spacing: 8) {
                            StatusIndicator(status: pair.status, pending: pair.status == nil)
                            Button {
                                model.removeCustomPair(pair)
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            .buttonStyle(.borderless)
                            .help("Remove")
                            .disabled(model.isApplying)
                        }
                    } label: {
                        Text("\(pair.key)=\(pair.value)")
                            .monospaced()
                            .textSelection(.enabled)
                            .accessibilityIdentifier("options.custom.\(pair.key)")
                        if case .failed(let reason) = pair.status {
                            Text(reason).foregroundStyle(.red)
                        } else if case .applied(let note?) = pair.status {
                            Text(note)
                        }
                    }
                }
                LabeledContent {
                    HStack {
                        TextField("Add option manually", text: $model.customEntry, prompt: Text("keyword=value"))
                            .labelsHidden()
                            .textFieldStyle(.roundedBorder)
                            .monospaced()
                            .frame(minWidth: 260)
                            .onSubmit { model.addCustomEntry() }
                            .accessibilityIdentifier("options.customEntry")
                        Button("Add") { model.addCustomEntry() }
                            .disabled(model.customEntry.isEmpty || model.isApplying)
                            .accessibilityIdentifier("options.customAdd")
                    }
                } label: {
                    Text("Add option manually")
                    Text(model.customEntryError ?? "Any lpadmin -o pair, e.g. RIUserCode=Custom.1234")
                        .foregroundStyle(model.customEntryError == nil ? AnyShapeStyle(.secondary) : AnyShapeStyle(.red))
                }
            } header: {
                Text("Advanced")
            }
        }
        .formStyle(.grouped)
        // Keep the last row clear of the window's status bar.
        .contentMargins(.bottom, StatusBar.height, for: .scrollContent)
    }
}

struct OptionRowView: View {
    let model: OptionsModel
    let row: OptionRow

    var body: some View {
        LabeledContent {
            HStack(spacing: 8) {
                control
                    .accessibilityIdentifier("option.\(row.key)")
                StatusIndicator(status: model.rowStatus[row.key], pending: model.isPending(row))
            }
            .disabled(model.isApplying)
        } label: {
            Text(row.label)
            Text(keywordLine)
                .monospaced()
                .textSelection(.enabled)
            if let error = model.validationError(row) {
                Text(error).foregroundStyle(.red)
            } else if case .failed(let reason) = model.rowStatus[row.key] {
                Text(reason).foregroundStyle(.red)
            } else if case .applied(let note?) = model.rowStatus[row.key] {
                Text(note)
            } else if case .readOnly(let reason) = row.control {
                Text(reason)
            } else if let note = model.overrideNote(row) {
                Text(note)
            }
        }
    }

    private var keywordLine: String {
        if case .field(let field) = row.control { return "\(row.key) · \(field.hint)" }
        return row.key
    }

    @ViewBuilder private var control: some View {
        switch row.control {
        case .picker(let choices):
            Picker(row.label, selection: Binding(
                get: { model.value(row) ?? "" },
                set: { model.set(row, to: $0) }
            )) {
                let current = model.value(row) ?? ""
                if !choices.contains(where: { $0.keyword == current }) {
                    Text(current.isEmpty ? "Not set" : current).tag(current)
                }
                ForEach(choices, id: \.keyword) { choice in
                    Text(choice.text).tag(choice.keyword)
                }
            }
            .labelsHidden()
            .fixedSize()

        case .toggle(let on, let off):
            Toggle(row.label, isOn: Binding(
                get: { model.value(row) == on },
                set: { model.set(row, to: $0 ? on : off) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)

        case .field(let field):
            let text = Binding(
                get: { model.fieldText(row, field: field) },
                set: { model.setFieldText($0, row: row, field: field) }
            )
            let prompt = Text(field.choices.first ?? "")
            Group {
                if field.isSecret {
                    SecureField(row.label, text: text, prompt: prompt)
                } else {
                    TextField(row.label, text: text, prompt: prompt)
                }
            }
            .labelsHidden()
            .textFieldStyle(.roundedBorder)
            .monospacedDigit()
            .frame(width: field.isNumeric ? 110 : 200)

        case .readOnly:
            Text(model.state?.display(model.value(row), row: row) ?? "—")
                .foregroundStyle(.secondary)
                .monospaced()
                .textSelection(.enabled)
        }
    }
}

/// Unsaved dot, spinner while applying, then a green check or red X after read-back.
struct StatusIndicator: View {
    let status: OptionsModel.RowStatus?
    let pending: Bool

    var body: some View {
        Group {
            switch status {
            case .applying:
                ProgressView().controlSize(.mini)
            case .applied:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .help("Applied and verified")
            case .failed(let reason):
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .help(reason)
            case nil:
                if pending {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(.tint)
                        .help("Unsaved change")
                } else {
                    Color.clear
                }
            }
        }
        .frame(width: 16, height: 16)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        switch status {
        case .applying: return "Applying"
        case .applied: return "Applied"
        case .failed(let reason): return "Not applied: \(reason)"
        case nil: return pending ? "Unsaved change" : ""
        }
    }
}

struct ApplyOptionsSheet: View {
    let model: OptionsModel
    let apply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Apply \(model.changeCount) Change\(model.changeCount == 1 ? "" : "s") to \(model.queue)?")
                    .font(.title3.weight(.semibold))
                Text("Changes the queue default for every user on this Mac.")
                    .foregroundStyle(.secondary)
            }

            if let warning = model.secretWarning {
                Label {
                    Text(warning)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                }
                .fixedSize(horizontal: false, vertical: true)
            }

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                GridRow {
                    Text("Setting")
                    Text("Current")
                    Text("New")
                }
                .font(.callout.weight(.semibold))
                .foregroundStyle(.secondary)
                Divider()
                ForEach(model.changeSummaries) { change in
                    GridRow {
                        Text(change.label)
                        Text(change.from).foregroundStyle(.secondary)
                        Text(change.to)
                    }
                }
            }
            .textSelection(.enabled)

            VStack(alignment: .leading, spacing: 6) {
                Text("Command")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(model.command)
                    .font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                    .accessibilityIdentifier("applySheet.cancel")
                Button("Apply") { apply() }
                    .keyboardShortcut(.defaultAction)
                    .accessibilityIdentifier("applySheet.apply")
            }
        }
        .padding(20)
        .frame(width: 560)
    }
}
