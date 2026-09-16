import Foundation

/// PPD parsing for what `lpoptions -l` and the CUPS web UI's "Set Default Options" page showed:
/// UI options with their groups, UI types, choices, defaults and custom-value parameters.
public struct PPD {
    public enum UIType: String {
        case pickOne = "PickOne"
        case pickMany = "PickMany"
        case boolean = "Boolean"
        case unknown
    }

    public struct Choice: Hashable {
        public let keyword: String
        /// Translation text after the slash, or the keyword when there is none.
        public let text: String

        public init(keyword: String, text: String) {
            self.keyword = keyword
            self.text = text
        }
    }

    /// One `*ParamCustomX Name/Text: order type min max` line.
    public struct CustomParameter: Hashable {
        public let name: String
        public let text: String
        public let order: Int
        /// PPD type as written: string, passcode, password, int, real, points, curve, invcurve.
        public let type: String
        public let minimum: String
        public let maximum: String
    }

    public struct Option {
        public let keyword: String
        public let text: String
        public var choices: [String] = []
        public var defaultChoice: String?
        /// "Custom.INTEGER", "Custom.WIDTHxHEIGHT", ... when the PPD allows a custom value.
        public var customChoice: String?

        /// `*OpenGroup` label (with " / subgroup" when nested); "General" for ungrouped options.
        public var group: String = PPD.generalGroup
        public var uiType: UIType = .unknown
        public var choiceList: [Choice] = []
        /// Parameters from `*ParamCustomX`, in order; empty unless the PPD has `*CustomX True`.
        public var customParameters: [CustomParameter] = []
        public var isJCL = false
    }

    /// Where libcups and the CUPS web UI put options that aren't inside an `*OpenGroup`.
    public static let generalGroup = "General"

    public private(set) var options: [Option] = []
    /// Group names in first-appearance order ("General" where the first ungrouped option appears).
    public private(set) var groups: [String] = []
    /// Top-level `*Key: value` attributes (NickName, Manufacturer, ...), first occurrence wins.
    public private(set) var attributes: [String: String] = [:]
    /// Every `*cupsFilter` / `*cupsFilter2` line, in order, with the quotes removed.
    public private(set) var filterLines: [(keyword: String, value: String)] = []

    public init(text: String) {
        var defaults: [String: String] = [:]
        var customKeywords: Set<String> = []
        var customParams: [String: [CustomParameter]] = [:]
        var groupStack: [String] = []
        var current: Option?
        var inQuotedValue = false

        for rawLine in text.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline) {
            let line = String(rawLine)
            // Multi-line quoted values (invocation code, etc.) — skip until the closing quote.
            if inQuotedValue {
                if line.contains("\"") { inQuotedValue = false }
                continue
            }
            guard line.hasPrefix("*"), !line.hasPrefix("*%"), let colon = line.firstIndex(of: ":") else { continue }

            let key = line[line.index(after: line.startIndex) ..< colon]   // "PageSize Letter/US Letter"
            let value = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
            if value.hasPrefix("\""), value.filter({ $0 == "\"" }).count == 1 { inQuotedValue = true }

            let parts = key.split(separator: " ", maxSplits: 1)
            let mainKey = String(parts[0])

            switch mainKey {
            case "OpenGroup", "OpenSubGroup":
                // *OpenGroup: InstallableOptions/Installable Options
                let (name, label) = Self.splitText(value)
                groupStack.append(label ?? name)
            case "CloseGroup", "CloseSubGroup":
                _ = groupStack.popLast()
            case "OpenUI", "JCLOpenUI":
                // *OpenUI *PageSize/Media Size: PickOne
                guard parts.count == 2 else { continue }
                let spec = parts[1].trimmingCharacters(in: .whitespaces).drop { $0 == "*" }
                let nameAndText = spec.split(separator: "/", maxSplits: 1)
                let keyword = String(nameAndText[0])
                let text = nameAndText.count > 1 ? String(nameAndText[1]) : Self.standardText[keyword] ?? keyword
                current = Option(keyword: keyword, text: text)
                current!.group = groupStack.isEmpty ? Self.generalGroup : groupStack.joined(separator: " / ")
                current!.uiType = UIType(rawValue: value) ?? .unknown
                current!.isJCL = mainKey == "JCLOpenUI"
            case "CloseUI", "JCLCloseUI":
                if let option = current { options.append(option) }
                current = nil
            default:
                if mainKey.hasPrefix("ParamCustom"), parts.count == 2 {
                    // *ParamCustomRIAngel Angel/Text: 1 int 0 359
                    let fields = value.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
                    let (name, label) = Self.splitText(String(parts[1]))
                    if fields.count >= 2, let order = Int(fields[0]) {
                        customParams[String(mainKey.dropFirst("ParamCustom".count)), default: []].append(
                            CustomParameter(name: name, text: label ?? name, order: order, type: fields[1],
                                            minimum: fields.count > 2 ? fields[2] : "",
                                            maximum: fields.count > 3 ? fields[3] : ""))
                    }
                } else if mainKey.hasPrefix("Custom"), parts.count == 2, Self.splitText(String(parts[1])).name == "True" {
                    customKeywords.insert(String(mainKey.dropFirst("Custom".count)))
                } else if mainKey.hasPrefix("Default"), parts.count == 1 {
                    defaults[String(mainKey.dropFirst("Default".count))] = value
                } else if parts.count == 2, let option = current, mainKey == option.keyword {
                    let (choice, label) = Self.splitText(String(parts[1]))
                    current!.choices.append(choice)
                    current!.choiceList.append(Choice(keyword: choice, text: label ?? choice))
                } else if parts.count == 1, mainKey == "cupsFilter" || mainKey == "cupsFilter2" {
                    filterLines.append((mainKey, value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))))
                    if attributes[mainKey] == nil { attributes[mainKey] = filterLines.last!.value }
                } else if parts.count == 1, attributes[mainKey] == nil {
                    attributes[mainKey] = value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                }
            }
        }
        if let option = current { options.append(option) }

        // lpoptions hides PageRegion (it mirrors PageSize).
        options.removeAll { $0.keyword == "PageRegion" }
        for i in options.indices {
            let keyword = options[i].keyword
            options[i].defaultChoice = defaults[keyword]
            if !groups.contains(options[i].group) { groups.append(options[i].group) }
            guard customKeywords.contains(keyword) else { continue }
            let params = (customParams[keyword] ?? []).sorted { $0.order < $1.order }
            options[i].customParameters = params
            if keyword == "PageSize" {
                options[i].customChoice = "Custom.WIDTHxHEIGHT"
            } else if params.count == 1 {
                options[i].customChoice = "Custom.\(Self.lpoptionsTypeName(params[0].type))"
            } else if params.count > 1 {
                options[i].customChoice = "{" + params.map { "\($0.name)=\(Self.lpoptionsTypeName($0.type))" }
                    .joined(separator: " ") + "}"
            }
        }
    }

    /// Labels libcups gives options whose *OpenUI line has no translation text.
    private static let standardText = ["PageSize": "Media Size", "MediaType": "Media Type",
                                       "InputSlot": "Media Source", "ColorModel": "Output Mode",
                                       "Resolution": "Resolution"]

    /// How `lpoptions -l` spells a custom parameter type.
    private static func lpoptionsTypeName(_ type: String) -> String {
        type == "int" ? "INTEGER" : type.uppercased()
    }

    /// "Letter/US Letter" -> ("Letter", "US Letter"); "Letter" -> ("Letter", nil).
    private static func splitText(_ s: String) -> (name: String, text: String?) {
        let pieces = s.split(separator: "/", maxSplits: 1)
        let name = pieces.first.map { $0.trimmingCharacters(in: .whitespaces) } ?? ""
        let text = pieces.count > 1 ? pieces[1].trimmingCharacters(in: .whitespaces) : nil
        return (name, text)
    }

    public func option(_ keyword: String) -> Option? {
        options.first { $0.keyword == keyword }
    }
}
