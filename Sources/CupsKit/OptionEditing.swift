import Foundation

// MARK: - Controls

/// A typed custom value (`*ParamCustomX`) edited as text, stored as `Custom.<value>`.
public struct CustomField: Hashable {
    public enum Kind: String {
        case string, passcode, password, int, real
    }

    public let kind: Kind
    public let parameterName: String
    public let minimum: Double?
    public let maximum: Double?
    /// The PPD's own choices (e.g. `None`, `0`). An empty field means the first of them.
    public let choices: [String]

    /// Passcodes and passwords: masked in the UI and in displayed commands.
    public var isSecret: Bool { kind == .passcode || kind == .password }
    public var isNumeric: Bool { kind == .int || kind == .real }

    init?(parameter: PPD.CustomParameter, choices: [String]) {
        guard let kind = Kind(rawValue: parameter.type) else { return nil }
        self.kind = kind
        parameterName = parameter.name
        minimum = Double(parameter.minimum)
        maximum = Double(parameter.maximum)
        self.choices = choices
    }

    /// Stored option value -> field text. `Custom.1234` -> `1234`; a plain choice -> "" (or the choice for numbers).
    public func text(fromValue value: String?) -> String {
        guard let value else { return "" }
        if value.hasPrefix("Custom.") { return String(value.dropFirst("Custom.".count)) }
        if isNumeric, value != choices.first { return value }
        return ""
    }

    /// Field text -> option value. "" -> the PPD's placeholder choice; text matching a choice -> that choice.
    public func value(fromText text: String) -> String {
        if text.isEmpty { return choices.first ?? "None" }
        if choices.contains(text) { return text }
        return "Custom." + text
    }

    /// nil when valid.
    public func validationError(_ text: String) -> String? {
        guard !text.isEmpty, !choices.contains(text) else { return nil }
        switch kind {
        case .string, .password, .passcode:
            if kind == .passcode, !text.allSatisfy(\.isASCIIDigit) { return "Digits only" }
            if let minimum, Double(text.count) < minimum { return "At least \(Int(minimum)) characters" }
            if let maximum, Double(text.count) > maximum { return "At most \(Int(maximum)) characters" }
        case .int:
            guard let number = Int(text) else { return "Whole number" }
            return rangeError(Double(number))
        case .real:
            guard let number = Double(text) else { return "Number" }
            return rangeError(number)
        }
        return nil
    }

    private func rangeError(_ number: Double) -> String? {
        if let minimum, number < minimum { return "\(format(minimum)) to \(format(maximum))" }
        if let maximum, number > maximum { return "\(format(minimum)) to \(format(maximum))" }
        return nil
    }

    private func format(_ n: Double?) -> String {
        guard let n else { return "…" }
        return n == n.rounded() ? String(Int(n)) : String(n)
    }

    /// "8 characters max", "4–8 digits", "0 to 23".
    public var hint: String {
        switch kind {
        case .string, .password:
            return maximum.map { "Up to \(Int($0)) characters" } ?? "Text"
        case .passcode:
            if let minimum, let maximum { return "\(Int(minimum))–\(Int(maximum)) digits" }
            return "Digits"
        case .int, .real:
            return "\(format(minimum)) to \(format(maximum))"
        }
    }
}

public enum OptionControl: Hashable {
    /// Menu of choices. `(keyword, label)` pairs.
    case picker([PPD.Choice])
    /// Boolean with exactly a true and a false choice; the keywords to write for each state.
    case toggle(on: String, off: String)
    /// Custom value typed as text; the PPD's choices are only a placeholder.
    case field(CustomField)
    /// Read-only, with the reason (e.g. "Set by PPD option PageSize").
    case readOnly(String)
}

extension PPD.Option {
    public var control: OptionControl {
        // A true Boolean has exactly a True and a False choice; some PPDs mislabel PickOnes as Boolean.
        if uiType == .boolean,
           let on = choices.first(where: { $0.caseInsensitiveCompare("True") == .orderedSame }),
           let off = choices.first(where: { $0.caseInsensitiveCompare("False") == .orderedSame }),
           choices.count == 2 {
            return .toggle(on: on, off: off)
        }
        // Ricoh codes/passwords: a placeholder choice plus one typed custom parameter.
        if customParameters.count == 1, choices.count <= 1,
           let field = CustomField(parameter: customParameters[0], choices: choices) {
            return .field(field)
        }
        return .picker(choiceList)
    }
}

// MARK: - Encoding

public enum OptionEncoding {
    /// `key=value` for lpadmin/lpoptions `-o`, quoting values cupsParseOptions would otherwise split.
    /// (Unquoted, `Custom.John Smith` is silently stored as `Custom.John`.)
    public static func argument(key: String, value: String) -> String {
        "\(key)=\(quoted(value))"
    }

    public static func quoted(_ value: String) -> String {
        guard value.contains(where: { $0.isWhitespace || "\"'\\{}".contains($0) }) else { return value }
        let escaped = value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }

    /// Masks the value part of a custom secret (`Custom.1234` -> `Custom.••••`).
    public static func masked(_ value: String) -> String {
        if value.hasPrefix("Custom.") { return "Custom." + String(repeating: "•", count: max(4, value.count - 7)) }
        return value
    }
}

// MARK: - lpoptions

/// Per-user option defaults from `~/.cups/lpoptions` (read only, to show where a user overrides a queue default).
public enum LpOptionsFile {
    public static var userFileURL: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".cups/lpoptions")
    }

    /// Options on the `Dest`/`Default` line for `queue` (no instance). Empty if none or no file.
    public static func options(for queue: String, fileURL: URL = userFileURL) -> [String: String] {
        guard let text = try? String(contentsOf: fileURL, encoding: .utf8) else { return [:] }
        return options(for: queue, in: text)
    }

    public static func options(for queue: String, in text: String) -> [String: String] {
        for line in text.split(whereSeparator: \.isNewline) {
            let fields = line.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
            guard fields.count >= 2, fields[0] == "Dest" || fields[0] == "Default",
                  fields[1].caseInsensitiveCompare(queue) == .orderedSame else { continue }
            return fields.count > 2 ? parse(String(fields[2])) : [:]
        }
        return [:]
    }

    /// cupsParseOptions-style: `a=b c="d e" f={g=h i=j}`.
    public static func parse(_ string: String) -> [String: String] {
        var result: [String: String] = [:]
        var chars = Array(string)
        var i = 0
        func skipSpaces() { while i < chars.count, chars[i].isWhitespace { i += 1 } }
        while true {
            skipSpaces()
            guard i < chars.count else { break }
            var name = ""
            while i < chars.count, !chars[i].isWhitespace, chars[i] != "=" { name.append(chars[i]); i += 1 }
            guard i < chars.count, chars[i] == "=" else {
                if !name.isEmpty { result[name] = "true" }
                continue
            }
            i += 1
            var value = ""
            var quote: Character?
            var braces = 0
            while i < chars.count {
                let c = chars[i]
                if c == "\\", i + 1 < chars.count {
                    value.append(chars[i + 1]); i += 2; continue
                }
                if let q = quote {
                    if c == q { quote = nil } else { value.append(c) }
                } else if c == "\"" || c == "'" {
                    quote = c
                } else if c == "{" {
                    braces += 1; value.append(c)
                } else if c == "}" {
                    braces -= 1; value.append(c)
                } else if c.isWhitespace, braces == 0 {
                    break
                } else {
                    value.append(c)
                }
                i += 1
            }
            result[name] = value
        }
        chars.removeAll()
        return result
    }
}

// MARK: - Catalog

public struct OptionRow: Identifiable, Hashable {
    public enum Source: Hashable {
        case ppd, ipp, policy
    }

    /// The key written with `lpadmin -p queue -o key=value` (PPD keyword, `sides-default`, `job-quota-period`).
    public let key: String
    public let label: String
    public let group: String
    public let control: OptionControl
    public let source: Source

    public var id: String { key }
    public var isSecret: Bool {
        if case .field(let field) = control { return field.isSecret }
        return false
    }
}

public struct OptionSection: Identifiable, Hashable {
    public let title: String
    public let rows: [OptionRow]
    public var id: String { title }
}

/// Queue defaults for one queue: IPP attributes and PPD (what lpadmin changes), plus the user's
/// ~/.cups/lpoptions, read only to point out per-user overrides.
public struct OptionState {
    public let queue: String
    public let snapshot: QueueSnapshot
    public let userOptions: [String: String]

    public static func load(client: CupsClient, queue: String) async throws -> OptionState {
        OptionState(queue: queue, snapshot: try await QueueSnapshot.load(client: client, queue: queue),
                    userOptions: LpOptionsFile.options(for: queue))
    }

    public var ppd: PPD? { snapshot.ppd }

    /// IPP job-template defaults an admin can set with `lpadmin -o name-default=value`.
    public static let ippDefaults = ["copies", "media", "sides", "print-color-mode", "print-quality", "output-bin",
                                     "printer-resolution", "number-up", "orientation-requested", "job-hold-until",
                                     "job-priority", "job-cancel-after"]
    /// On PPD queues cupsd derives these IPP defaults from a PPD option, and setting both makes duplicates.
    public static let ppdControlled = ["media": "PageSize", "sides": "Duplex", "output-bin": "OutputBin",
                                       "printer-resolution": "Resolution", "print-color-mode": "ColorModel",
                                       "print-quality": "cupsPrintQuality"]
    public static let integerPolicies = ["job-quota-period", "job-page-limit", "job-k-limit"]

    /// PPD groups shown first, in this order; "Installable Options" goes last (hardware, rarely changed).
    public static let leadingGroups = [PPD.generalGroup, "Basic", "Paper"]
    public static let trailingGroup = "Installable Options"

    /// General, Basic, Paper, other PPD groups in file order, IPP, Policies, Installable Options.
    public func sections() -> [OptionSection] {
        var ppdSections: [OptionSection] = []
        if let ppd {
            let ordered = Self.leadingGroups.filter(ppd.groups.contains)
                + ppd.groups.filter { !Self.leadingGroups.contains($0) && $0 != Self.trailingGroup }
            for group in ordered {
                let rows = ppd.options.filter { $0.group == group }.map {
                    OptionRow(key: $0.keyword, label: $0.text, group: group, control: $0.control, source: .ppd)
                }
                ppdSections.append(OptionSection(title: group, rows: rows))
            }
        }
        var sections = ppdSections

        var ipp: [OptionRow] = []
        for base in Self.ippDefaults {
            let name = base + "-default"
            guard snapshot.attributes[name] != nil || snapshot.attributes[base + "-supported"] != nil else { continue }
            var control = ippControl(base: base)
            if let keyword = Self.ppdControlled[base], ppd?.option(keyword) != nil {
                control = .readOnly("Set by PPD option \(keyword)")
            }
            ipp.append(OptionRow(key: name, label: Self.label(base), group: "IPP", control: control, source: .ipp))
        }
        if !ipp.isEmpty { sections.append(OptionSection(title: "IPP", rows: ipp)) }

        var policies: [OptionRow] = []
        for name in ["printer-error-policy", "printer-op-policy"] where snapshot.attributes[name] != nil {
            let choices = supportedChoices(name + "-supported")
            policies.append(OptionRow(key: name, label: Self.label(name), group: "Policies",
                                      control: .picker(choices), source: .policy))
        }
        if snapshot.attributes["job-sheets-default"] != nil {
            let sheets = supportedChoices("job-sheets-supported").map(\.keyword)
            var pairs: [PPD.Choice] = []
            for start in sheets {
                for end in sheets { pairs.append(PPD.Choice(keyword: "\(start),\(end)", text: "\(start), \(end)")) }
            }
            policies.append(OptionRow(key: "job-sheets-default", label: "Banner pages (start, end)",
                                      group: "Policies", control: .picker(pairs), source: .policy))
        }
        for name in Self.integerPolicies where snapshot.attributes[name] != nil {
            let field = CustomField(parameter: PPD.CustomParameter(name: name, text: name, order: 1, type: "int",
                                                                   minimum: "0", maximum: "2147483647"),
                                    choices: ["0"])!
            policies.append(OptionRow(key: name, label: Self.label(name), group: "Policies", control: .field(field), source: .policy))
        }
        if !policies.isEmpty { sections.append(OptionSection(title: "Policies", rows: policies)) }

        if let ppd, ppd.groups.contains(Self.trailingGroup) {
            let rows = ppd.options.filter { $0.group == Self.trailingGroup }.map {
                OptionRow(key: $0.keyword, label: $0.text, group: Self.trailingGroup, control: $0.control, source: .ppd)
            }
            sections.append(OptionSection(title: Self.trailingGroup, rows: rows))
        }
        return sections
    }

    /// "print-color-mode" -> "Print color mode".
    static func label(_ name: String) -> String {
        let words = name.replacingOccurrences(of: "-", with: " ")
        return words.prefix(1).uppercased() + words.dropFirst()
    }

    private func ippControl(base: String) -> OptionControl {
        let supported = snapshot.attributes[base + "-supported"]
        if let supported, case .range(let lower, let upper)? = supported.values.first, supported.values.count == 1 {
            return .field(integerField(base, lower: Int(lower), upper: Int(upper)))
        }
        if base == "job-priority" {
            return .field(integerField(base, lower: 1, upper: 100))
        }
        let choices = supportedChoices(base + "-supported")
        return choices.isEmpty ? .readOnly("No \(base)-supported values") : .picker(choices)
    }

    private func integerField(_ name: String, lower: Int, upper: Int) -> CustomField {
        CustomField(parameter: PPD.CustomParameter(name: name, text: name, order: 1, type: "int",
                                                   minimum: String(lower), maximum: String(upper)), choices: [])!
    }

    /// `*-supported` values as choices: raw value to write, human text to show.
    private func supportedChoices(_ name: String) -> [PPD.Choice] {
        guard let attribute = snapshot.attributes[name] else { return [] }
        let base = String(name.dropLast("-supported".count))
        return attribute.values.compactMap { value in
            guard let raw = Self.rawValue(value) else { return nil }
            let shown = Format.value(value, attribute: base + "-default")
            return PPD.Choice(keyword: raw, text: shown == raw ? raw : "\(shown) (\(raw))")
        }
    }

    /// What lpadmin accepts for an IPP value: enums and integers as numbers, resolutions as 600dpi.
    static func rawValue(_ value: IPPValue) -> String? {
        switch value {
        case .integer(let i), .enumeration(let i): return String(i)
        case .string(_, let s), .stringWithLanguage(_, _, let s): return s
        case .resolution(let x, let y, let units):
            let unit = units == 4 ? "dpcm" : "dpi"
            return x == y ? "\(x)\(unit)" : "\(x)x\(y)\(unit)"
        case .range(let lower, let upper): return "\(lower)-\(upper)"
        case .boolean(let b): return b ? "true" : "false"
        default: return nil
        }
    }

    // MARK: values

    /// The queue default for a row key (PPD default, or the first IPP attribute of that name), in raw form.
    public func queueValue(_ key: String) -> String? {
        if let option = ppd?.option(key) { return option.defaultChoice }
        guard let attribute = snapshot.attributes[key] else { return nil }
        let raw = attribute.values.compactMap(Self.rawValue)
        return raw.isEmpty ? nil : raw.joined(separator: ",")
    }

    /// This user's own lpoptions value for a row (`sides-default` is `sides` there), if they have one.
    public func userOverride(_ key: String) -> String? {
        let base = key.hasSuffix("-default") ? String(key.dropLast("-default".count)) : key
        return userOptions[Self.ippDefaults.contains(base) ? base : key]
    }

    /// Human form of a raw value for a row, e.g. `Custom.1234` -> `1234`, `5` -> `high`, `DuplexNoTumble` -> `Long Edge`.
    public func display(_ value: String?, row: OptionRow) -> String {
        guard let value else { return "—" }
        switch row.control {
        case .picker(let choices):
            return choices.first { $0.keyword == value }?.text ?? value
        case .toggle(let on, _):
            return value == on ? "On" : "Off"
        case .field(let field):
            let text = field.text(fromValue: value)
            if text.isEmpty { return value }
            return field.isSecret ? String(repeating: "•", count: text.count) : text
        case .readOnly:
            return value
        }
    }
}

// MARK: - Apply

public struct OptionChange: Hashable {
    public let key: String
    public let value: String
    public let isSecret: Bool

    public init(key: String, value: String, isSecret: Bool) {
        self.key = key
        self.value = value
        self.isSecret = isSecret
    }
}

public struct OptionReadBack: Hashable {
    public let key: String
    public let applied: Bool
    /// Why it didn't apply.
    public let reason: String?
}

/// Writes queue defaults with `lpadmin -p queue -o ...` (the PPD in /etc/cups/ppd and printers.conf),
/// the same thing the CUPS web UI's Set Default Options page did. Never lpoptions.
public enum OptionApplier {
    public static func command(queue: String, changes: [OptionChange]) -> (executable: String, arguments: [String]) {
        var args = ["-p", queue]
        for change in changes {
            args += ["-o", OptionEncoding.argument(key: change.key, value: change.value)]
        }
        return (CupsTools.lpadminPath, args)
    }

    /// The command as shown to the user, with secret values masked.
    public static func displayCommand(queue: String, changes: [OptionChange]) -> String {
        let masked = changes.map {
            OptionChange(key: $0.key, value: $0.isSecret ? OptionEncoding.masked($0.value) : $0.value, isSecret: $0.isSecret)
        }
        let (executable, args) = command(queue: queue, changes: masked)
        return CupsTools.commandLine(executable, args)
    }

    /// Runs one lpadmin call for all changes, then re-reads the queue and checks each change.
    public static func apply(client: CupsClient, queue: String,
                             changes: [OptionChange]) async throws -> (result: ToolResult, readBack: [OptionReadBack], state: OptionState) {
        let (executable, args) = command(queue: queue, changes: changes)
        let result = try await Task.detached { try CupsTools.run(executable, args) }.value
        let state = try await OptionState.load(client: client, queue: queue)
        guard result.succeeded else {
            let message = result.message.isEmpty ? "lpadmin exited \(result.status)" : result.message
            return (result, changes.map { OptionReadBack(key: $0.key, applied: false, reason: message) }, state)
        }
        return (result, changes.map { verify($0, state: state) }, state)
    }

    public static func verify(_ change: OptionChange, state: OptionState) -> OptionReadBack {
        let actual = state.queueValue(change.key)
        // PPD choices are written verbatim; IPP values read back in their own spelling (none,none / true).
        let exact = state.ppd?.option(change.key) != nil
        if let actual, exact ? actual == change.value : QueueSnapshot.matches(actual, change.value) {
            return OptionReadBack(key: change.key, applied: true, reason: nil)
        }
        guard let actual else {
            return OptionReadBack(key: change.key, applied: false, reason: "Not applied: \(state.queue) has no option \(change.key)")
        }
        return OptionReadBack(key: change.key, applied: false,
                              reason: "Not applied: still \(change.isSecret ? OptionEncoding.masked(actual) : actual)")
    }
}

private extension Character {
    var isASCIIDigit: Bool { ("0"..."9").contains(self) }
}
