import Foundation

/// What `add` / `set` were asked to change. Maps 1:1 onto lpadmin flags.
public struct QueueSpec {
    public var deviceURI: String?
    public var model: String?
    public var ppdFile: String?
    public var description: String?
    public var location: String?
    public var options: [(key: String, value: String)] = []

    public init() {}

    public var isEmpty: Bool {
        deviceURI == nil && model == nil && ppdFile == nil && description == nil && location == nil && options.isEmpty
    }

    public func lpadminArguments(queue: String) -> [String] {
        var args = ["-p", queue]
        if let deviceURI { args += ["-v", deviceURI] }
        if let model { args += ["-m", model] }
        if let ppdFile { args += ["-P", ppdFile] }
        if let description { args += ["-D", description] }
        if let location { args += ["-L", location] }
        for option in options { args += ["-o", "\(option.key)=\(option.value)"] }
        return args
    }
}

/// One requested change and where it landed.
public struct SettingCheck {
    public let name: String
    public let source: String
    public let value: String?
    public let wanted: String

    public var applied: Bool { QueueSnapshot.matches(value, wanted) }
}

/// Queue state used to verify that lpadmin actually applied each change.
public struct QueueSnapshot {
    public let attributes: IPPGroup
    public let ppd: PPD?

    public static func load(client: CupsClient, queue: String) async throws -> QueueSnapshot {
        QueueSnapshot(attributes: try await client.getPrinterAttributes(queue: queue, requested: ["all"]),
                      ppd: try await client.getPPD(queue: queue).map(PPD.init(text:)))
    }

    /// Where an lpadmin `-o key=value` lands: an IPP attribute of that name, a PPD option, or key-default.
    public func lookup(option key: String) -> (value: String, source: String)? {
        if let attribute = attributes[key] { return (Self.join(attribute), "ipp") }
        if let option = ppd?.option(key) { return (option.defaultChoice ?? "?", "ppd") }
        if let attribute = attributes[key + "-default"] { return (Self.join(attribute), "ipp \(key)-default") }
        return nil
    }

    public func settings(for spec: QueueSpec) -> [SettingCheck] {
        var result: [SettingCheck] = []
        if let uri = spec.deviceURI {
            result.append(SettingCheck(name: "device-uri (-v)", source: "ipp", value: attributes.string("device-uri"), wanted: uri))
        }
        if let d = spec.description {
            result.append(SettingCheck(name: "printer-info (-D)", source: "ipp", value: attributes.string("printer-info"), wanted: d))
        }
        if let l = spec.location {
            result.append(SettingCheck(name: "printer-location (-L)", source: "ipp", value: attributes.string("printer-location"), wanted: l))
        }
        for option in spec.options {
            let found = lookup(option: option.key)
            result.append(SettingCheck(name: option.key, source: found?.source ?? "not found", value: found?.value, wanted: option.value))
        }
        return result
    }

    private static func join(_ attribute: IPPAttribute) -> String {
        attribute.values.map { Format.value($0, attribute: attribute.name) }.joined(separator: ",")
    }

    /// Loose equality: case-insensitive, yes/on/true style booleans, and "none" matching "none,none".
    public static func matches(_ actual: String?, _ wanted: String) -> Bool {
        guard let actual else { return false }
        func normalize(_ s: String) -> String {
            let lower = s.lowercased()
            return ["yes": "true", "on": "true", "no": "false", "off": "false"][lower] ?? lower
        }
        let a = normalize(actual), w = normalize(wanted)
        if a == w { return true }
        let parts = a.split(separator: ",").map(String.init)
        return !w.contains(",") && parts.count > 1 && parts.allSatisfy { $0 == w }
    }
}

/// Add/modify flows, split around the lpadmin run so a caller can show the command and its output in between.
public enum QueueAdmin {
    /// Validates an add request and applies the sharing default. Returns the spec to hand to lpadmin.
    public static func prepareAdd(client: CupsClient, queue: String, spec: QueueSpec, shared: Bool) async throws -> QueueSpec {
        try validateQueueName(queue)
        guard spec.deviceURI != nil else { throw CupsAdminError.usage("add needs -v <device-uri>") }

        // lpadmin creates queues shared by default; ours aren't unless asked (--shared or an explicit -o).
        var spec = spec
        if let explicit = spec.options.first(where: { $0.key == "printer-is-shared" }) {
            if shared, !QueueSnapshot.matches(explicit.value, "true") {
                throw CupsAdminError.usage("--shared conflicts with -o printer-is-shared=\(explicit.value)")
            }
        } else {
            spec.options.append(("printer-is-shared", shared ? "true" : "false"))
        }
        if try await client.queueExists(queue) {
            throw CupsAdminError.failed("queue \(queue) already exists (use set to change it)")
        }
        return spec
    }

    /// lpadmin arguments for add. -E after -p: enable and accept jobs, like the web UI's Add Printer did.
    public static func addArguments(queue: String, spec: QueueSpec) -> [String] {
        spec.lpadminArguments(queue: queue) + ["-E"]
    }

    /// After lpadmin ran for add: checks it worked and returns the new queue's state.
    public static func confirmAdded(client: CupsClient, queue: String, lpadminStatus: Int32) async throws -> QueueSnapshot {
        guard lpadminStatus == 0 else { throw CupsAdminError.failed("lpadmin exited \(lpadminStatus); queue not added") }
        guard try await client.queueExists(queue) else {
            throw CupsAdminError.failed("lpadmin exited 0 but \(queue) does not exist")
        }
        return try await QueueSnapshot.load(client: client, queue: queue)
    }

    /// Validates a set request and returns the current values of everything it will change.
    public static func prepareSet(client: CupsClient, queue: String, spec: QueueSpec) async throws -> [SettingCheck] {
        guard !spec.isEmpty else { throw CupsAdminError.usage("set needs at least one of -o, -v, -D, -L, -m, -P") }
        guard try await client.queueExists(queue) else { throw CupsAdminError.failed("no such queue \(queue)") }
        return try await QueueSnapshot.load(client: client, queue: queue).settings(for: spec)
    }

    /// After lpadmin ran for set: checks the exit status and returns the new values.
    public static func confirmSet(client: CupsClient, queue: String, spec: QueueSpec, lpadminStatus: Int32) async throws -> [SettingCheck] {
        guard lpadminStatus == 0 else { throw CupsAdminError.failed("lpadmin exited \(lpadminStatus); nothing verified") }
        return try await QueueSnapshot.load(client: client, queue: queue).settings(for: spec)
    }

    /// cupsd's rules: printable, no space / slash / backslash / quote / ? / #, at most 127 bytes.
    public static func validateQueueName(_ queue: String) throws {
        let forbidden = Set(" \t/\\?'\"#")
        guard !queue.isEmpty, queue.utf8.count <= 127,
              queue.unicodeScalars.allSatisfy({ $0.value > 0x20 && $0.value != 0x7F }),
              !queue.contains(where: forbidden.contains) else {
            throw CupsAdminError.usage("invalid queue name \(queue): no spaces, / \\ ? ' \" #, max 127 bytes")
        }
    }
}
