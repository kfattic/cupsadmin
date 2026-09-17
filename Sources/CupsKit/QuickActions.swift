import Foundation

/// Task-named shortcuts that set queue defaults without knowing option keywords.
/// What each one writes comes from the driver profiles in Resources/driver-profiles.json.
public struct QuickAction: Identifiable, Hashable {
    public enum Input: Hashable {
        case none
        /// Digits, up to the PPD's own limit.
        case userCode
    }

    /// CLI name (`cupsadmin quick <id> <queue>`) and the key in driver-profiles.json.
    public let id: String
    public let title: String
    public let systemImage: String
    public let input: Input
    /// One line for the CLI list and tooltips.
    public let summary: String

    public var isDefaultPrinter: Bool { id == "default" }

    public static let all: [QuickAction] = [
        QuickAction(id: "color", title: "Always Print in Color", systemImage: "paintpalette", input: .none,
                    summary: "Color by default"),
        QuickAction(id: "bw", title: "Always Print Black & White", systemImage: "circle.lefthalf.filled", input: .none,
                    summary: "Black & white by default"),
        QuickAction(id: "usercode", title: "Set User Code…", systemImage: "person.badge.key", input: .userCode,
                    summary: "User/department code sent with every job; Xerox also takes an optional account ID (--clear to remove)"),
        QuickAction(id: "duplex", title: "Default to Duplex", systemImage: "doc.on.doc", input: .none,
                    summary: "Two-sided, long edge"),
        QuickAction(id: "simplex", title: "Default to Single-Sided", systemImage: "doc", input: .none,
                    summary: "One-sided"),
        QuickAction(id: "letter", title: "Use Letter Paper", systemImage: "arrow.up.left.and.arrow.down.right",
                    input: .none, summary: "Letter paper, and fit to the nearest size where the driver has that option (never prompt at the printer)"),
        QuickAction(id: "default", title: "Make Default Printer", systemImage: "star", input: .none,
                    summary: "Server default printer (lpadmin -d)"),
    ]

    public static func named(_ id: String) -> QuickAction? {
        all.first { $0.id == id }
    }

    /// The title for a queue: Use Letter Paper gains ", Fit to Nearest Size" only when its driver
    /// profile also sets a fit-to-paper option (e.g. Ricoh RIPaperPolicy), not just the page size.
    public func title(in context: DriverContext?) -> String {
        guard id == "letter", let context, case .success(let resolved) = resolve(context),
              resolved.changes.contains(where: { !Self.paperSizeKeys.contains($0.key) }) else { return title }
        return title + ", Fit to Nearest Size"
    }

    static let paperSizeKeys: Set<String> = ["PageSize", "media-default"]

    /// The profile and option changes this action would write on a queue, or why it can't.
    public func resolve(_ context: DriverContext, value: String? = nil, secondValue: String? = nil, clearing: Bool = false,
                        profiles: [DriverProfile] = DriverProfiles.builtIn) -> Result<ResolvedQuickAction, QuickActionUnavailable> {
        let key = clearing ? id + "-clear" : id
        var firstMissing: String?
        for profile in DriverProfiles.matching(context, in: profiles) {
            if profile.actions[key] == nil, let reason = profile.unavailable[id] {
                return .failure(QuickActionUnavailable(reason: reason))
            }
            guard let alternatives = profile.actions[key] else { continue }
            for pairs in alternatives {
                let parsed = pairs.compactMap(Self.parse)
                let filled = parsed.map { ($0.key, $0.value.replacingOccurrences(of: "{value}", with: value ?? "")) }
                if let missing = filled.first(where: { !context.supports(key: $0.0, value: $0.1) }) {
                    if firstMissing == nil { firstMissing = "\(missing.0)=\(parsed.first { $0.key == missing.0 }!.value)" }
                    continue
                }
                var changes = filled.map { OptionChange(key: $0.0, value: $0.1, isSecret: false) }
                if !clearing, let secondValue, !secondValue.isEmpty {
                    guard let second = profile.inputs[id]?.second else {
                        return .failure(QuickActionUnavailable(reason: "\(profile.name) takes one value for \(id), not two"))
                    }
                    for pair in second.pairs.compactMap(Self.parse) {
                        let value = pair.value.replacingOccurrences(of: "{value2}", with: secondValue)
                        guard context.supports(key: pair.key, value: value) else {
                            return .failure(QuickActionUnavailable(reason: "Not available for \(context.driverName) (no \(pair.key)=\(pair.value))"))
                        }
                        changes.append(OptionChange(key: pair.key, value: value, isSecret: false))
                    }
                }
                return .success(ResolvedQuickAction(profile: profile, changes: changes))
            }
        }
        let detail = firstMissing.map { " (no \($0))" } ?? " (no driver profile maps \(key))"
        return .failure(QuickActionUnavailable(reason: "Not available for \(context.driverName)\(detail)"))
    }

    /// nil when the action can run on this queue; otherwise the reason (for tooltips and CLI errors).
    public func unavailableReason(in context: DriverContext) -> String? {
        if isDefaultPrinter { return nil }
        switch resolve(context, value: input == .userCode ? "0" : nil) {
        case .success: return nil
        case .failure(let unavailable): return unavailable.reason
        }
    }

    public func isAvailable(in context: DriverContext) -> Bool { unavailableReason(in: context) == nil }

    /// The profile's input settings for this action on this queue (label, digits, second value).
    public func inputSpec(_ context: DriverContext) -> DriverProfile.Input? {
        guard input == .userCode, case .success(let resolved) = resolve(context, value: "0") else { return nil }
        return resolved.profile.inputs[id]
    }

    /// "User code" (Ricoh) or the profile's label ("User ID" for Xerox).
    public func inputLabel(_ context: DriverContext) -> String { inputSpec(context)?.label ?? "User code" }

    /// The optional second value's label ("Account ID (optional)"), or nil when the profile has none.
    public func secondInputLabel(_ context: DriverContext) -> String? { inputSpec(context)?.second?.label }

    public func digitsOnly(_ context: DriverContext) -> Bool { inputSpec(context)?.digitsOnly ?? true }

    /// For Set User Code: digits only unless the profile allows text, within the PPD's limit. nil when valid.
    public func validationError(_ value: String, context: DriverContext) -> String? {
        guard input == .userCode, !value.isEmpty else { return nil }
        return Self.valueError(value, digitsOnly: digitsOnly(context), keyword: codeKeyword(context), context: context)
    }

    /// For the optional second value (text, within the PPD's limit). nil when valid.
    public func secondValidationError(_ value: String, context: DriverContext) -> String? {
        guard input == .userCode, !value.isEmpty else { return nil }
        return Self.valueError(value, digitsOnly: false, keyword: secondKeyword(context), context: context)
    }

    private static func valueError(_ value: String, digitsOnly: Bool, keyword: String?, context: DriverContext) -> String? {
        if digitsOnly {
            guard value.allSatisfy({ ("0"..."9").contains($0) }) else { return "Digits only" }
        } else if value.contains(where: { $0 == "\"" || $0 == "'" || $0 == "\\" || $0.isNewline }) {
            return "No quotes, backslashes or line breaks"
        }
        if let keyword, let max = context.ppd?.option(keyword)?.customParameters.first.flatMap({ Int($0.maximum) }), value.count > max {
            return "At most \(max) \(digitsOnly ? "digits" : "characters")"
        }
        return nil
    }

    /// The code currently set on the queue, without the Custom. prefix (nil when none).
    public func currentCode(_ context: DriverContext) -> String? {
        guard let keyword = codeKeyword(context),
              let value = context.ppd?.option(keyword)?.defaultChoice, value.hasPrefix("Custom.") else { return nil }
        return String(value.dropFirst("Custom.".count))
    }

    /// The second value currently set on the queue (e.g. the Xerox account ID), without Custom.
    public func currentSecondValue(_ context: DriverContext) -> String? {
        guard let keyword = secondKeyword(context),
              let value = context.ppd?.option(keyword)?.defaultChoice, value.hasPrefix("Custom.") else { return nil }
        return String(value.dropFirst("Custom.".count))
    }

    private func secondKeyword(_ context: DriverContext) -> String? {
        inputSpec(context)?.second?.pairs.compactMap(Self.parse).first { $0.value.contains("{value2}") }?.key
    }

    /// The option that receives `{value}` for this queue's profile (e.g. RIUserCode).
    private func codeKeyword(_ context: DriverContext) -> String? {
        guard input == .userCode, case .success(let resolved) = resolve(context, value: "0") else { return nil }
        let profilePairs = resolved.profile.actions[id]?.first ?? []
        return profilePairs.compactMap(Self.parse).first { $0.value.contains("{value}") }?.key
    }

    static func parse(_ pair: String) -> (key: String, value: String)? {
        guard let eq = pair.firstIndex(of: "="), eq != pair.startIndex else { return nil }
        return (String(pair[..<eq]), String(pair[pair.index(after: eq)...]))
    }
}

public struct ResolvedQuickAction {
    public let profile: DriverProfile
    public let changes: [OptionChange]
}

public struct QuickActionUnavailable: Error, Hashable {
    public let reason: String
}

public struct QuickActionOutcome {
    public let command: String
    public let succeeded: Bool
    /// The driver profile used; nil for Make Default Printer.
    public let profile: DriverProfile?
    /// Per-option read-back; empty for Make Default Printer.
    public let readBack: [OptionReadBack]
    public let changes: [OptionChange]
    public let message: String?
}

extension QuickAction {
    /// Runs the action on a queue with read-back. Throws QuickActionUnavailable when no profile fits.
    public func run(queue: String, value: String? = nil, secondValue: String? = nil, clearing: Bool = false,
                    client: CupsClient) async throws -> QuickActionOutcome {
        if isDefaultPrinter {
            let outcome = try await QueueActions.setDefault(queue: queue, client: client)
            return QuickActionOutcome(command: outcome.command, succeeded: outcome.succeeded, profile: nil,
                                      readBack: [], changes: [], message: outcome.message)
        }
        let context = try await DriverContext.load(client: client, queue: queue)
        let resolved = try resolve(context, value: value, secondValue: secondValue, clearing: clearing).get()
        let (result, readBack, _) = try await OptionApplier.apply(client: client, queue: queue, changes: resolved.changes)
        let failed = readBack.filter { !$0.applied }
        return QuickActionOutcome(command: OptionApplier.displayCommand(queue: queue, changes: resolved.changes),
                                  succeeded: result.succeeded && failed.isEmpty, profile: resolved.profile,
                                  readBack: readBack, changes: resolved.changes, message: failed.first?.reason)
    }
}
