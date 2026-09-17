import Foundation

/// What Quick Actions need to know about a queue's driver: its PPD (if any) and IPP attributes.
public struct DriverContext {
    public let ppd: PPD?
    /// Printer attributes, including `*-supported` values for IPP Everywhere pairs.
    public let attributes: IPPGroup?

    public init(ppd: PPD?, attributes: IPPGroup?) {
        self.ppd = ppd
        self.attributes = attributes
    }

    static let requestedAttributes = [
        "printer-make-and-model", "print-color-mode-supported", "print-color-mode-default",
        "sides-supported", "sides-default", "media-supported", "media-default",
    ]

    public static func load(client: CupsClient, queue: String) async throws -> DriverContext {
        let attributes = try await client.getPrinterAttributes(queue: queue, requested: requestedAttributes)
        let ppd = try await client.getPPD(queue: queue).map(PPD.init(text:))
        return DriverContext(ppd: ppd, attributes: attributes)
    }

    public var manufacturer: String? { ppd?.attributes["Manufacturer"] }
    public var nickName: String? { ppd?.attributes["NickName"] ?? attributes?.string("printer-make-and-model") }
    /// For messages: "RICOH SP 3710DN".
    public var driverName: String { nickName ?? manufacturer ?? "this driver" }

    /// Whether this queue can take `key=value`: a PPD option with that choice (or a custom value for
    /// `Custom.` values), or an IPP `name-default` whose `name-supported` lists the value.
    public func supports(key: String, value: String) -> Bool {
        if let option = ppd?.option(key) {
            if value.hasPrefix("Custom.") { return !option.customParameters.isEmpty }
            return option.choices.contains(value)
        }
        guard key.hasSuffix("-default"), let attributes else { return false }
        let supported = String(key.dropLast("-default".count)) + "-supported"
        return attributes.strings(supported).contains(value)
    }
}

public struct DriverProfile: Decodable, Identifiable {
    public struct Match: Decodable {
        /// Regular expressions (case-insensitive) on the PPD's `*Manufacturer` / `*NickName`; all given must match.
        public let manufacturer: String?
        public let nickname: String?
    }

    public let id: String
    public let name: String
    public let match: Match
    /// Action id -> alternatives, each a list of `keyword=value` pairs applied together.
    public let actions: [String: [[String]]]
    /// Action id -> why this driver can't do it (e.g. accounting codes set outside the PPD).
    public let unavailable: [String: String]
    /// Action id -> how its typed value is labeled and checked, plus an optional second value.
    public let inputs: [String: Input]

    public struct Input: Decodable {
        /// "User ID"; nil keeps the default "User code".
        public let label: String?
        /// Default true (Ricoh user codes). Xerox user IDs are strings.
        public let digitsOnly: Bool?
        public let second: SecondInput?
    }

    /// An optional extra value, e.g. Xerox Standard Accounting's account ID. Its pairs use `{value2}`
    /// and are added only when the user fills it in.
    public struct SecondInput: Decodable {
        public let label: String
        public let pairs: [String]
    }

    enum CodingKeys: String, CodingKey { case id, name, match, actions, unavailable, inputs }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        match = try c.decode(Match.self, forKey: .match)
        // Accept one list of pairs or a list of alternative lists.
        var actions: [String: [[String]]] = [:]
        let raw = try c.decode([String: FlexiblePairs].self, forKey: .actions)
        for (action, pairs) in raw { actions[action] = pairs.alternatives }
        self.actions = actions
        unavailable = try c.decodeIfPresent([String: String].self, forKey: .unavailable) ?? [:]
        inputs = try c.decodeIfPresent([String: Input].self, forKey: .inputs) ?? [:]
    }

    private struct FlexiblePairs: Decodable {
        let alternatives: [[String]]
        init(from decoder: Decoder) throws {
            if let nested = try? [[String]](from: decoder) {
                alternatives = nested
            } else {
                alternatives = [try [String](from: decoder)]
            }
        }
    }

    public var isGeneric: Bool { match.manufacturer == nil && match.nickname == nil }

    public func matches(_ context: DriverContext) -> Bool {
        func test(_ pattern: String?, _ value: String?) -> Bool {
            guard let pattern else { return true }
            guard let value else { return false }
            return value.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
        }
        return test(match.manufacturer, context.manufacturer) && test(match.nickname, context.nickName)
    }
}

public enum DriverProfiles {
    private struct File: Decodable { let profiles: [DriverProfile] }

    /// The profiles compiled in from Resources/driver-profiles.json, in match order.
    public static let builtIn: [DriverProfile] = {
        do {
            return try JSONDecoder().decode(File.self, from: Data(PackageResources.driver_profiles_json)).profiles
        } catch {
            fatalError("driver-profiles.json is invalid: \(error)")
        }
    }()

    /// Matching profiles in order: vendor profiles first, generic last.
    public static func matching(_ context: DriverContext, in profiles: [DriverProfile] = builtIn) -> [DriverProfile] {
        profiles.filter { $0.matches(context) }
    }
}
