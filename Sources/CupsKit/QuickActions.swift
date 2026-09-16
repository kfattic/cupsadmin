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
                    summary: "User/department code sent with every job (--clear to remove)"),
        QuickAction(id: "duplex", title: "Default to Duplex", systemImage: "doc.on.doc", input: .none,
                    summary: "Two-sided, long edge"),
        QuickAction(id: "simplex", title: "Default to Single-Sided", systemImage: "doc", input: .none,
                    summary: "One-sided"),
        QuickAction(id: "letter", title: "Use Letter Paper, Fit to Nearest Size", systemImage: "arrow.up.left.and.arrow.down.right",
                    input: .none, summary: "Letter paper, and fit to the nearest size where the driver can (never prompt at the printer)"),
        QuickAction(id: "default", title: "Make Default Printer", systemImage: "star", input: .none,
                    summary: "Server default printer (lpadmin -d)"),
    ]

    public static func named(_ id: String) -> QuickAction? {
        all.first { $0.id == id }
    }

    /// The profile and option changes this action would write on a queue, or why it can't.
    public func resolve(_ context: DriverContext, value: String? = nil, clearing: Bool = false,
                        profiles: [DriverProfile] = DriverProfiles.builtIn) -> Result<ResolvedQuickAction, QuickActionUnavailable> {
        let key = clearing ? id + "-clear" : id
        var firstMissing: String?
        for profile in DriverProfiles.matching(context, in: profiles) {
            guard let alternatives = profile.actions[key] else { continue }
            for pairs in alternatives {
                let parsed = pairs.compactMap(Self.parse)
                let filled = parsed.map { ($0.key, $0.value.replacingOccurrences(of: "{value}", with: value ?? "")) }
                if let missing = filled.first(where: { !context.supports(key: $0.0, value: $0.1) }) {
                    if firstMissing == nil { firstMissing = "\(missing.0)=\(parsed.first { $0.key == missing.0 }!.value)" }
                    continue
                }
                let changes = filled.map { OptionChange(key: $0.0, value: $0.1, isSecret: false) }
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

    /// For Set User Code: digits only, within the PPD's limit for the code option. nil when valid.
    public func validationError(_ value: String, context: DriverContext) -> String? {
        guard input == .userCode, !value.isEmpty else { return nil }
        guard value.allSatisfy({ ("0"..."9").contains($0) }) else { return "Digits only" }
        if let keyword = codeKeyword(context),
           let max = context.ppd?.option(keyword)?.customParameters.first.flatMap({ Int($0.maximum) }), value.count > max {
            return "At most \(max) digits"
        }
        return nil
    }

    /// The code currently set on the queue, without the Custom. prefix (nil when none).
    public func currentCode(_ context: DriverContext) -> String? {
        guard let keyword = codeKeyword(context),
              let value = context.ppd?.option(keyword)?.defaultChoice, value.hasPrefix("Custom.") else { return nil }
        return String(value.dropFirst("Custom.".count))
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
    public func run(queue: String, value: String? = nil, clearing: Bool = false, client: CupsClient) async throws -> QuickActionOutcome {
        if isDefaultPrinter {
            let outcome = try await QueueActions.setDefault(queue: queue, client: client)
            return QuickActionOutcome(command: outcome.command, succeeded: outcome.succeeded, profile: nil,
                                      readBack: [], changes: [], message: outcome.message)
        }
        let context = try await DriverContext.load(client: client, queue: queue)
        let resolved = try resolve(context, value: value, clearing: clearing).get()
        let (result, readBack, _) = try await OptionApplier.apply(client: client, queue: queue, changes: resolved.changes)
        let failed = readBack.filter { !$0.applied }
        return QuickActionOutcome(command: OptionApplier.displayCommand(queue: queue, changes: resolved.changes),
                                  succeeded: result.succeeded && failed.isEmpty, profile: resolved.profile,
                                  readBack: readBack, changes: resolved.changes, message: failed.first?.reason)
    }
}
