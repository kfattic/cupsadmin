import AppKit
import CupsKit
import SwiftUI

/// Printer header (grouped Form) above the Jobs or Options tab.
struct PrinterDetailView: View {
    let model: PrinterDetailModel
    let options: OptionsModel
    let store: PrinterStore
    let tab: DetailTab

    var body: some View {
        VStack(spacing: 0) {
            if let printer = model.printer {
                PrinterHeaderView(printer: printer, ppdPath: model.ppdPath, driverFilters: model.driverFilters)
                Divider()
            } else if let error = model.loadError {
                ContentUnavailableView("Can’t Load \(model.queue)", systemImage: "exclamationmark.triangle",
                                       description: Text(error))
                    .frame(maxHeight: 220)
                Divider()
            }
            switch tab {
            case .jobs:
                JobsView(model: model, store: store)
            case .options:
                OptionsView(model: options)
            }
        }
        .task(id: model.queue) { await model.load() }
        .onChange(of: store.revision) { Task { await model.load() } }
    }
}

struct PrinterHeaderView: View {
    let printer: IPPGroup
    let ppdPath: String?
    let driverFilters: DriverFilterReport?

    private var state: Int? { printer.int("printer-state") }
    private var accepting: Bool { printer.bool("printer-is-accepting-jobs") ?? true }
    private var reasons: [String] { printer.strings("printer-state-reasons").filter { $0 != "none" } }
    private var stateColor: Color {
        if state == 5 || !accepting { return .red }
        return state == 4 ? .blue : .green
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Form {
                Section("Status") {
                    LabeledContent("State") {
                        HStack(spacing: 6) {
                            Circle().fill(stateColor).frame(width: 8, height: 8)
                            Text(Format.printerState(state).capitalized)
                        }
                    }
                    LabeledContent("Reasons") {
                        Text(reasons.isEmpty ? "None" : reasons.joined(separator: ", "))
                            .monospaced(!reasons.isEmpty)
                    }
                    LabeledContent("Message") {
                        Text(printer.string("printer-state-message").flatMap { $0.isEmpty ? nil : $0 } ?? "—")
                            .lineLimit(2)
                    }
                    LabeledContent("Accepting jobs", value: accepting ? "Yes" : "No")
                    LabeledContent("Shared", value: printer.bool("printer-is-shared") == true ? "Yes" : "No")
                    if let headline = driverFilters?.headline {
                        LabeledContent("Driver") {
                            Label(headline, systemImage: "exclamationmark.triangle.fill")
                                .symbolRenderingMode(.multicolor)
                        }
                        .help(driverFilters?.detail ?? headline)
                    }
                }
            }
            Form {
                Section("Queue") {
                    LabeledContent("Device URI") {
                        Text(printer.string("device-uri") ?? "—")
                            .monospaced()
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    LabeledContent {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(printer.string("printer-make-and-model") ?? "—")
                            Text(ppdPath ?? "No PPD (driverless or raw)")
                                .font(.caption)
                                .monospaced(ppdPath != nil)
                                .foregroundStyle(.secondary)
                        }
                    } label: {
                        Text("Model")
                    }
                    LabeledContent("Location", value: printer.string("printer-location").flatMap { $0.isEmpty ? nil : $0 } ?? "—")
                    LabeledContent("Description", value: printer.string("printer-info").flatMap { $0.isEmpty ? nil : $0 } ?? "—")
                }
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .textSelection(.enabled)
        .frame(height: driverFilters?.isFlagged == true ? 300 : 262)
    }
}

struct JobsView: View {
    @Bindable var model: PrinterDetailModel
    let store: PrinterStore
    @SceneStorage("JobsTableColumns") private var columns = TableColumnCustomization<JobSummary>()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Picker("Show", selection: $model.jobFilter) {
                    ForEach(JobFilter.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()

                Spacer(minLength: 12)

                if model.isWorking { ProgressView().controlSize(.small) }
                jobButtons(for: model.selection)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.bar)
            Divider()

            Table(model.sortedJobs, selection: $model.selection, sortOrder: $model.sortOrder,
                  columnCustomization: $columns) {
                TableColumn("ID", value: \.id) { Text(String($0.id)).monospacedDigit() }
                    .width(min: 40, ideal: 56, max: 80)
                    .customizationID("id")
                TableColumn("Name", value: \.name)
                    .width(min: 120, ideal: 220, max: 360)
                    .customizationID("name")
                TableColumn("User", value: \.user)
                    .width(min: 60, ideal: 110, max: 200)
                    .customizationID("user")
                TableColumn("Size", value: \.sizeK) { Text(Format.kilobytes($0.sizeK)).monospacedDigit() }
                    .width(min: 50, ideal: 64, max: 90)
                    .customizationID("size")
                TableColumn("Pages", value: \.pagesSortKey) { Text($0.pages.map(String.init) ?? "—").monospacedDigit() }
                    .width(min: 44, ideal: 54, max: 80)
                    .customizationID("pages")
                TableColumn("State", value: \.state) { Text($0.stateName.capitalized) }
                    .width(min: 70, ideal: 90, max: 120)
                    .customizationID("state")
                // Reasons takes the spare width; the other columns are capped.
                TableColumn("Reasons", value: \.reasonsText) { Text($0.reasonsText).monospaced() }
                    .width(min: 120, ideal: 320, max: .infinity)
                    .customizationID("reasons")
                TableColumn("Submitted", value: \.submittedSortKey) {
                    Text($0.submitted.map(Format.timestamp) ?? "—").monospacedDigit()
                }
                .width(150)
                .customizationID("submitted")
            }
            .alternatingRowBackgrounds(.disabled)
            .contextMenu(forSelectionType: Int.self) { ids in
                jobMenu(for: ids)
            }
            .onCopyCommand {
                [NSItemProvider(object: model.copyText(for: model.selection) as NSString)]
            }
            .overlay {
                if model.jobs.isEmpty {
                    ContentUnavailableView(emptyTitle, systemImage: "doc.text.magnifyingglass")
                }
            }
            .padding(.bottom, StatusBar.height)
        }
    }

    private var emptyTitle: String {
        switch model.jobFilter {
        case .active: return "No Active Jobs"
        case .completed: return "No Completed Jobs"
        case .all: return "No Jobs"
        }
    }

    private var otherQueues: [String] {
        store.printers.map(\.name).filter { $0 != model.queue }
    }

    @ViewBuilder private func jobButtons(for ids: Set<Int>) -> some View {
        Button { run(.cancel, ids) } label: { Label("Cancel", systemImage: "xmark.circle") }
            .disabled(!model.canPerform(.cancel, on: ids))
            .help("Cancel the selected jobs")
        Button { run(.hold, ids) } label: { Label("Hold", systemImage: "pause.circle") }
            .disabled(!model.canPerform(.hold, on: ids))
            .help("Hold the selected jobs (lp -H hold)")
        Button { run(.release, ids) } label: { Label("Release", systemImage: "play.circle") }
            .disabled(!model.canPerform(.release, on: ids))
            .help("Release held jobs (lp -H resume)")
        Menu {
            ForEach(otherQueues, id: \.self) { queue in
                Button(queue) { run(.move(to: queue), ids) }
            }
        } label: {
            Label("Move To", systemImage: "arrow.right.circle")
        }
        .fixedSize()
        .disabled(!model.canPerform(.move(to: ""), on: ids) || otherQueues.isEmpty)
        .help("Move the selected jobs to another queue (lpmove)")
    }

    @ViewBuilder private func jobMenu(for ids: Set<Int>) -> some View {
        Group {
            Button { run(.cancel, ids) } label: { Label("Cancel", systemImage: "xmark.circle") }
                .disabled(!model.canPerform(.cancel, on: ids))
            Button { run(.hold, ids) } label: { Label("Hold", systemImage: "pause.circle") }
                .disabled(!model.canPerform(.hold, on: ids))
            Button { run(.release, ids) } label: { Label("Release", systemImage: "play.circle") }
                .disabled(!model.canPerform(.release, on: ids))
            Menu {
                ForEach(otherQueues, id: \.self) { queue in
                    Button(queue) { run(.move(to: queue), ids) }
                }
            } label: {
                Label("Move To", systemImage: "arrow.right.circle")
            }
            .disabled(!model.canPerform(.move(to: ""), on: ids))
            Divider()
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(model.copyText(for: ids), forType: .string)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            .disabled(ids.isEmpty)
        }
        .labelStyle(.titleAndIcon)
    }

    private func run(_ action: JobAction, _ ids: Set<Int>) {
        Task { await model.perform(action, on: ids) }
    }
}
