import CupsKit
import SwiftUI

struct ContentView: View {
    @State private var store = PrinterStore()
    // Remembered across launches.
    @AppStorage("selectedQueue") private var selection: String?
    @AppStorage("detailTab") private var tab: DetailTab = .jobs
    @State private var search = ""
    @State private var detail: PrinterDetailModel?
    @State private var options: OptionsModel?
    @State private var proposedSelection: String?
    @State private var confirmingDiscard = false
    @State private var cancelAllTarget: PrinterSummary?
    @State private var deleteTarget: PrinterSummary?
    @State private var quickAction: QuickActionModel?
    @State private var addPrinter: AddPrinterModel?

    private var selectedPrinter: PrinterSummary? {
        store.printers.first { $0.name == selection }
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(store: store, selection: guardedSelection, search: $search, actions: sidebarActions)
            .navigationSplitViewColumnWidth(min: 220, ideal: 270, max: 400)
        } detail: {
            if let detail, let options, selectedPrinter != nil {
                PrinterDetailView(model: detail, options: options, store: store, tab: tab)
                    .id(detail.queue)
            } else {
                ContentUnavailableView("Select a Printer", systemImage: "printer",
                                       description: Text("Choose a queue in the sidebar."))
                    .padding(.bottom, StatusBar.height)
            }
        }
        // Whole-window status bar, under both columns.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            StatusBar(action: store.statusLine, summary: store.summaryLine)
        }
        .navigationTitle(selection ?? "CUPS Admin")
        .toolbar { toolbar }
        .task {
            await store.refresh()
            await store.loadPPDs()
        }
        .onChange(of: store.revision) { Task { await store.loadPPDs() } }
        .onChange(of: selection, initial: true) { _, queue in
            detail = queue.map { PrinterDetailModel(queue: $0, store: store) }
            options = queue.map { queue in
                OptionsModel(queue: queue) { [store] line in store.report(line) }
            }
        }
        .confirmationDialog("Discard unsaved option changes for \(selection ?? "")?",
                            isPresented: $confirmingDiscard) {
            Button("Discard Changes", role: .destructive) { selection = proposedSelection }
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("\(options?.changeCount ?? 0) change(s) haven’t been applied.")
        }
        .confirmationDialog("Cancel all jobs on \(cancelAllTarget?.name ?? "")?",
                            isPresented: Binding(get: { cancelAllTarget != nil }, set: { if !$0 { cancelAllTarget = nil } }),
                            presenting: cancelAllTarget) { printer in
            Button("Cancel \(printer.jobCount) Job\(printer.jobCount == 1 ? "" : "s")", role: .destructive) {
                Task { await store.perform(.cancelAllJobs, on: printer.name) }
            }
            Button("Keep Jobs", role: .cancel) {}
        } message: { printer in
            Text("Runs cancel -a \(printer.name). This can’t be undone.")
        }
        .confirmationDialog("Delete printer \(deleteTarget?.name ?? "")?",
                            isPresented: Binding(get: { deleteTarget != nil }, set: { if !$0 { deleteTarget = nil } }),
                            presenting: deleteTarget) { printer in
            Button("Delete \(printer.name)", role: .destructive) {
                Task {
                    if await store.delete(printer.name), selection == printer.name { selection = nil }
                }
            }
            Button("Keep Printer", role: .cancel) {}
        } message: { printer in
            Text(printer.jobCount > 0
                 ? "Runs lpadmin -x \(printer.name). Its \(printer.jobCount) active job\(printer.jobCount == 1 ? "" : "s") will be canceled. This can’t be undone."
                 : "Runs lpadmin -x \(printer.name). This can’t be undone.")
        }
        .sheet(item: $quickAction) { model in
            QuickActionSheet(model: model)
        }
        .sheet(item: $addPrinter) { model in
            AddPrinterSheet(model: model) { name in
                if !model.isModify { selection = name }
            }
        }
        .alert(item: $store.failure) { failure in
            Alert(title: Text(failure.title), message: Text(failure.message))
        }
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        if selectedPrinter != nil {
            ToolbarItem(placement: .principal) {
                Picker("View", selection: $tab) {
                    ForEach(DetailTab.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
            }
        }
        ToolbarItemGroup(placement: .primaryAction) {
            Menu {
                if let printer = selectedPrinter {
                    QuickActionItems(store: store, queue: printer.name) { action in
                        quickAction = QuickActionModel(action: action, queue: printer.name, store: store)
                    }
                } else {
                    Text("Select a printer first")
                }
            } label: {
                Label("Quick Actions", systemImage: "bolt")
            }
            .help("Quick Actions for the selected printer")

            if let printer = selectedPrinter {
                let pause: PrinterAction = printer.isPaused ? .resume : .pause
                Button { Task { await store.perform(pause, on: printer.name) } } label: {
                    Label(pause.title, systemImage: pause.systemImage)
                }
                .help(printer.isPaused ? "Resume printing (cupsenable)" : "Pause printing (cupsdisable)")

                let accept: PrinterAction = printer.accepting ? .reject : .accept
                Button { Task { await store.perform(accept, on: printer.name) } } label: {
                    Label(accept.title, systemImage: accept.systemImage)
                }
                .help(printer.accepting ? "Stop accepting new jobs (cupsreject)" : "Accept new jobs (cupsaccept)")
            }
            Button {
                addPrinter = AddPrinterModel(store: store)
            } label: {
                Label("Add Printer", systemImage: "plus")
            }
            .help("Add a printer (lpadmin -p … -E)")

            Button {
                Task {
                    await store.refresh()
                    store.noteChange()
                }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .help("Refresh printers and jobs")
            .keyboardShortcut("r", modifiers: .command)
            .disabled(store.isRefreshing)
        }
    }

    private var sidebarActions: SidebarActions {
        SidebarActions(
            cancelAll: { cancelAllTarget = $0 },
            delete: { deleteTarget = $0 },
            modify: { printer in
                Task {
                    if let attributes = try? await store.client.getPrinterAttributes(queue: printer.name,
                                                                                     requested: PrinterDetailModel.headerAttributes) {
                        addPrinter = AddPrinterModel(store: store, modifying: attributes)
                    }
                }
            },
            quick: { action, printer in
                quickAction = QuickActionModel(action: action, queue: printer.name, store: store)
            }
        )
    }

    /// Selection that asks before leaving a printer with unapplied option edits.
    private var guardedSelection: Binding<String?> {
        Binding(
            get: { selection },
            set: { newValue in
                guard newValue != selection else { return }
                if options?.hasChanges == true {
                    proposedSelection = newValue
                    confirmingDiscard = true
                } else {
                    selection = newValue
                }
            }
        )
    }
}

struct SidebarActions {
    let cancelAll: (PrinterSummary) -> Void
    let delete: (PrinterSummary) -> Void
    let modify: (PrinterSummary) -> Void
    let quick: (QuickAction, PrinterSummary) -> Void
}

struct SidebarView: View {
    let store: PrinterStore
    @Binding var selection: String?
    @Binding var search: String
    let actions: SidebarActions

    private var filtered: [PrinterSummary] {
        store.printers.filter { $0.matches(search: search) }
    }

    var body: some View {
        List(selection: $selection) {
            Section("Printers") {
                ForEach(filtered) { printer in
                    PrinterRow(printer: printer, isDefault: store.defaultPrinter == printer.name)
                        .tag(printer.name)
                        .contextMenu { menu(for: printer) }
                }
            }
        }
        .listStyle(.sidebar)
        .searchable(text: $search, placement: .sidebar, prompt: "Search printers")
        .contentMargins(.bottom, StatusBar.height, for: .scrollContent)
        .overlay {
            if store.printers.isEmpty {
                if let error = store.errorMessage {
                    ContentUnavailableView("Can’t Reach CUPS", systemImage: "exclamationmark.triangle",
                                           description: Text(error))
                } else if store.hasLoaded {
                    ContentUnavailableView("No Printers", systemImage: "printer",
                                           description: Text("No queues are set up on this Mac."))
                } else {
                    ProgressView()
                }
            } else if filtered.isEmpty {
                ContentUnavailableView.search(text: search)
            }
        }
    }

    @ViewBuilder private func menu(for printer: PrinterSummary) -> some View {
        Group {
            let pause: PrinterAction = printer.isPaused ? .resume : .pause
            Button { Task { await store.perform(pause, on: printer.name) } } label: {
                Label(pause.title, systemImage: pause.systemImage)
            }
            let accept: PrinterAction = printer.accepting ? .reject : .accept
            Button { Task { await store.perform(accept, on: printer.name) } } label: {
                Label(accept.title, systemImage: accept.systemImage)
            }
            Button { Task { await store.printTestPage(printer.name) } } label: {
                Label("Print Test Page", systemImage: "doc.text")
            }
            Button(role: .destructive) { actions.cancelAll(printer) } label: {
                Label("Cancel All Jobs…", systemImage: "xmark.circle")
            }
            .disabled(printer.jobCount == 0)

            Divider()
            Button {
                if let action = QuickAction.named("default") { actions.quick(action, printer) }
            } label: {
                Label("Set as Default Printer", systemImage: "star")
            }
            .disabled(store.defaultPrinter == printer.name)
            Button { actions.modify(printer) } label: {
                Label("Modify Printer…", systemImage: "slider.horizontal.3")
            }
            Button(role: .destructive) { actions.delete(printer) } label: {
                Label("Delete Printer…", systemImage: "trash")
            }

            Divider()
            Menu {
                QuickActionItems(store: store, queue: printer.name) { actions.quick($0, printer) }
            } label: {
                Label("Quick Actions", systemImage: "bolt")
            }

            Divider()
            Button { store.copyDeviceURI(printer) } label: {
                Label("Copy Device URI", systemImage: "doc.on.doc")
            }
            .disabled(printer.deviceURI == nil)
            Button { store.showPPDInFinder(printer.name) } label: {
                Label("Show PPD in Finder", systemImage: "folder")
            }
            .disabled(!store.hasPPDFile(printer.name))
        }
        .labelStyle(.titleAndIcon)
    }
}

/// Quick Action menu items for one queue; unavailable ones are disabled with the reason as tooltip.
struct QuickActionItems: View {
    let store: PrinterStore
    let queue: String
    let choose: (QuickAction) -> Void

    var body: some View {
        ForEach(QuickAction.all) { action in
            let reason = store.unavailableReason(action, queue: queue)
            Button { choose(action) } label: {
                Label(action.title, systemImage: action.systemImage)
            }
            .disabled(reason != nil)
            .help(reason ?? action.summary)
        }
        .labelStyle(.titleAndIcon)
    }
}

struct PrinterRow: View {
    let printer: PrinterSummary
    var isDefault = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(printer.status.color)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(printer.name)
                        .lineLimit(1)
                    if isDefault {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .help("Server default printer")
                            .accessibilityLabel("Default printer")
                    }
                }
                if let secondary = printer.secondaryLine {
                    Text(secondary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .badge(printer.jobCount)
        .help(printer.stateSummary)
        .accessibilityElement(children: .combine)
        .accessibilityValue(printer.stateSummary)
    }
}

struct StatusBar: View {
    /// Content above the bar adds this much bottom margin so its last row isn't hidden.
    static let height: CGFloat = 30

    /// Last action with its timing, e.g. "Refreshed 21 printers in 42 ms" or "ERROR: ...".
    let action: String
    /// Totals, e.g. "21 printers · 0 active jobs".
    let summary: String

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                Text(action)
                    .foregroundStyle(action.hasPrefix("ERROR") ? AnyShapeStyle(.red) : AnyShapeStyle(.secondary))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer(minLength: 0)
                Text(summary)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .font(.callout)
            .monospacedDigit()
            .textSelection(.enabled)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .background(.regularMaterial)
    }
}
