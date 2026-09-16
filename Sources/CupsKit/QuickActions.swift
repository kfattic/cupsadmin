import Foundation

/// Task-named shortcuts that set queue defaults without knowing option keywords.
/// Each one is data: which PPD keyword/value pairs to write (first variant the PPD supports wins).
/// Keywords and values come from docs/ricoh-ppd-options.md — never guessed.
public struct QuickAction: Identifiable, Hashable {
    public enum Input: Hashable {
        case none
        /// Digits, up to the PPD's own limit. An empty value clears the code.
        case userCode
    }

    public enum Effect: Hashable {
        /// `lpadmin -p queue -o ...` with the first variant whose keywords and values this PPD has.
        /// `{value}` in a value is replaced with the input.
        case options(variants: [[String: String]], clearVariants: [[String: String]])
        /// `lpadmin -d queue`.
        case defaultPrinter
    }

    /// CLI name: `cupsadmin quick <id> <queue>`.
    public let id: String
    public let title: String
    public let systemImage: String
    public let input: Input
    public let effect: Effect
    /// One line for the CLI list and tooltips.
    public let summary: String

    public static let all: [QuickAction] = [
        QuickAction(id: "color", title: "Always Print in Color", systemImage: "paintpalette", input: .none,
                    effect: .options(variants: [["ColorModel": "CMYK"], ["HQColorMode": "COLOR"]], clearVariants: []),
                    summary: "Color by default (ColorModel=CMYK, or HQColorMode=COLOR)"),
        QuickAction(id: "bw", title: "Always Print Black & White", systemImage: "circle.lefthalf.filled", input: .none,
                    effect: .options(variants: [["ColorModel": "Gray"], ["HQColorMode": "BW"]], clearVariants: []),
                    summary: "Black & white by default (ColorModel=Gray, or HQColorMode=BW)"),
        QuickAction(id: "usercode", title: "Set User Code…", systemImage: "person.badge.key", input: .userCode,
                    effect: .options(variants: [["RIEnableUserCode": "True", "RIUserCode": "Custom.{value}"]],
                                     clearVariants: [["RIEnableUserCode": "False", "RIUserCode": "None"]]),
                    summary: "Ricoh user code for every job (RIEnableUserCode=True, RIUserCode=Custom.<code>)"),
        QuickAction(id: "duplex", title: "Default to Duplex", systemImage: "doc.on.doc", input: .none,
                    effect: .options(variants: [["Duplex": "DuplexNoTumble"]], clearVariants: []),
                    summary: "Two-sided, long edge (Duplex=DuplexNoTumble)"),
        QuickAction(id: "simplex", title: "Default to Single-Sided", systemImage: "doc", input: .none,
                    effect: .options(variants: [["Duplex": "None"]], clearVariants: []),
                    summary: "One-sided (Duplex=None)"),
        QuickAction(id: "letter", title: "Use Letter Paper, Fit to Nearest Size", systemImage: "arrow.up.left.and.arrow.down.right",
                    input: .none,
                    effect: .options(variants: [["PageSize": "Letter", "RIPaperPolicy": "NearestSizeAdjust"]], clearVariants: []),
                    summary: "Letter, never prompt at the printer (PageSize=Letter, RIPaperPolicy=NearestSizeAdjust)"),
        QuickAction(id: "default", title: "Make Default Printer", systemImage: "star", input: .none,
                    effect: .defaultPrinter, summary: "Server default printer (lpadmin -d)"),
    ]

    public static func named(_ id: String) -> QuickAction? {
        all.first { $0.id == id }
    }

    /// The option changes for this PPD, or why the action isn't available on it.
    public func changes(for ppd: PPD?, value: String? = nil) -> Result<[OptionChange], QuickActionUnavailable> {
        guard case .options(let variants, let clearVariants) = effect else { return .success([]) }
        let clearing = input == .userCode && (value ?? "").isEmpty
        let candidates = clearing ? clearVariants : variants
        guard let ppd else { return .failure(QuickActionUnavailable(reason: "\(title) needs a PPD; this queue has none")) }

        for variant in candidates {
            var changes: [OptionChange] = []
            for key in variant.keys.sorted() {
                guard let option = ppd.option(key) else { changes = []; break }
                let raw = variant[key]!
                if raw.contains("{value}") {
                    guard !option.customParameters.isEmpty else { changes = []; break }
                    changes.append(OptionChange(key: key, value: raw.replacingOccurrences(of: "{value}", with: value ?? ""), isSecret: false))
                } else {
                    guard option.choices.contains(raw) else { changes = []; break }
                    changes.append(OptionChange(key: key, value: raw, isSecret: false))
                }
            }
            if !changes.isEmpty { return .success(changes) }
        }
        let needed = Set(candidates.flatMap { $0.keys }).sorted().joined(separator: " / ")
        return .failure(QuickActionUnavailable(reason: "This printer’s PPD has no \(needed) with the needed choice"))
    }

    public func isAvailable(for ppd: PPD?) -> Bool {
        if case .defaultPrinter = effect { return true }
        if case .success = changes(for: ppd, value: input == .userCode ? "0" : nil) { return true }
        return false
    }

    /// For Set User Code: digits only, within the PPD's RIUserCode length. nil when valid.
    public func validationError(_ value: String, ppd: PPD?) -> String? {
        guard input == .userCode, !value.isEmpty else { return nil }
        guard value.allSatisfy({ ("0"..."9").contains($0) }) else { return "Digits only" }
        if let max = ppd?.option("RIUserCode")?.customParameters.first.flatMap({ Int($0.maximum) }), value.count > max {
            return "At most \(max) digits"
        }
        return nil
    }

    /// The current user code on the queue, without the Custom. prefix (nil when none is set).
    public static func currentUserCode(_ ppd: PPD?) -> String? {
        guard let value = ppd?.option("RIUserCode")?.defaultChoice, value.hasPrefix("Custom.") else { return nil }
        return String(value.dropFirst("Custom.".count))
    }
}

public struct QuickActionUnavailable: Error, Hashable {
    public let reason: String
}

public struct QuickActionOutcome {
    public let command: String
    public let succeeded: Bool
    /// Per-option read-back; empty for Make Default Printer.
    public let readBack: [OptionReadBack]
    public let changes: [OptionChange]
    public let message: String?
}

extension QuickAction {
    /// Runs the action on a queue with read-back. Throws QuickActionUnavailable when the PPD lacks the options.
    public func run(queue: String, value: String? = nil, client: CupsClient) async throws -> QuickActionOutcome {
        switch effect {
        case .defaultPrinter:
            let outcome = try await QueueActions.setDefault(queue: queue, client: client)
            return QuickActionOutcome(command: outcome.command, succeeded: outcome.succeeded, readBack: [],
                                      changes: [], message: outcome.message)
        case .options:
            let ppd = try await client.getPPD(queue: queue).map(PPD.init(text:))
            let changes = try self.changes(for: ppd, value: value).get()
            let (result, readBack, _) = try await OptionApplier.apply(client: client, queue: queue, changes: changes)
            let failed = readBack.filter { !$0.applied }
            return QuickActionOutcome(command: OptionApplier.displayCommand(queue: queue, changes: changes),
                                      succeeded: result.succeeded && failed.isEmpty, readBack: readBack, changes: changes,
                                      message: failed.first?.reason)
        }
    }
}
