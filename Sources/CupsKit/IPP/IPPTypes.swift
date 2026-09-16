import Foundation

/// IPP tag byte (RFC 8010 §3.5). A struct rather than an enum so unknown tags survive decoding.
public struct IPPTag: RawRepresentable, Hashable {
    public let rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }

    // Delimiter tags
    public static let operationAttributes = IPPTag(rawValue: 0x01)
    public static let jobAttributes = IPPTag(rawValue: 0x02)
    public static let endOfAttributes = IPPTag(rawValue: 0x03)
    public static let printerAttributes = IPPTag(rawValue: 0x04)
    public static let unsupportedAttributes = IPPTag(rawValue: 0x05)

    // Out-of-band values
    public static let unsupported = IPPTag(rawValue: 0x10)
    public static let unknown = IPPTag(rawValue: 0x12)
    public static let noValue = IPPTag(rawValue: 0x13)

    // Integer values
    public static let integer = IPPTag(rawValue: 0x21)
    public static let boolean = IPPTag(rawValue: 0x22)
    public static let enumeration = IPPTag(rawValue: 0x23)

    // Octet-string values
    public static let octetString = IPPTag(rawValue: 0x30)
    public static let dateTime = IPPTag(rawValue: 0x31)
    public static let resolution = IPPTag(rawValue: 0x32)
    public static let rangeOfInteger = IPPTag(rawValue: 0x33)
    public static let begCollection = IPPTag(rawValue: 0x34)
    public static let textWithLanguage = IPPTag(rawValue: 0x35)
    public static let nameWithLanguage = IPPTag(rawValue: 0x36)
    public static let endCollection = IPPTag(rawValue: 0x37)

    // Character-string values
    public static let textWithoutLanguage = IPPTag(rawValue: 0x41)
    public static let nameWithoutLanguage = IPPTag(rawValue: 0x42)
    public static let keyword = IPPTag(rawValue: 0x44)
    public static let uri = IPPTag(rawValue: 0x45)
    public static let uriScheme = IPPTag(rawValue: 0x46)
    public static let charset = IPPTag(rawValue: 0x47)
    public static let naturalLanguage = IPPTag(rawValue: 0x48)
    public static let mimeMediaType = IPPTag(rawValue: 0x49)
    public static let memberAttrName = IPPTag(rawValue: 0x4A)

    public static let extensionTag = IPPTag(rawValue: 0x7F)

    public var isDelimiter: Bool { rawValue < 0x10 }
    public var isOutOfBand: Bool { (0x10...0x1F).contains(rawValue) }
    public var isCharacterString: Bool { (0x40...0x5F).contains(rawValue) }
}

public enum IPPValue {
    case integer(Int32)
    case boolean(Bool)
    case enumeration(Int32)
    /// textWithoutLanguage, nameWithoutLanguage, keyword, uri, charset, mimeMediaType, ...
    case string(IPPTag, String)
    /// textWithLanguage / nameWithLanguage
    case stringWithLanguage(IPPTag, language: String, String)
    case octetString(Data)
    case dateTime(Date)
    case resolution(x: Int32, y: Int32, units: UInt8)
    case range(Int32, Int32)
    case collection([IPPAttribute])
    case outOfBand(IPPTag)
    case other(IPPTag, Data)

    public var tag: IPPTag {
        switch self {
        case .integer: return .integer
        case .boolean: return .boolean
        case .enumeration: return .enumeration
        case .string(let t, _): return t
        case .stringWithLanguage(let t, _, _): return t
        case .octetString: return .octetString
        case .dateTime: return .dateTime
        case .resolution: return .resolution
        case .range: return .rangeOfInteger
        case .collection: return .begCollection
        case .outOfBand(let t): return t
        case .other(let t, _): return t
        }
    }

    public var stringValue: String? {
        switch self {
        case .string(_, let s), .stringWithLanguage(_, _, let s): return s
        case .octetString(let d): return String(data: d, encoding: .utf8)
        default: return nil
        }
    }

    public var intValue: Int? {
        switch self {
        case .integer(let i), .enumeration(let i): return Int(i)
        default: return nil
        }
    }

    public var boolValue: Bool? {
        if case .boolean(let b) = self { return b }
        return nil
    }
}

public struct IPPAttribute {
    public var name: String
    public var values: [IPPValue]

    public init(name: String, values: [IPPValue]) {
        self.name = name
        self.values = values
    }

    public static func string(_ name: String, _ tag: IPPTag, _ values: [String]) -> IPPAttribute {
        IPPAttribute(name: name, values: values.map { .string(tag, $0) })
    }

    public static func boolean(_ name: String, _ value: Bool) -> IPPAttribute {
        IPPAttribute(name: name, values: [.boolean(value)])
    }
}

/// One attribute group (operation, printer, job, ...) in a message.
public struct IPPGroup {
    public var tag: IPPTag
    public var attributes: [IPPAttribute]

    public subscript(name: String) -> IPPAttribute? {
        attributes.first { $0.name == name }
    }

    public func string(_ name: String) -> String? { self[name]?.values.first?.stringValue }
    public func strings(_ name: String) -> [String] { self[name]?.values.compactMap(\.stringValue) ?? [] }
    public func int(_ name: String) -> Int? { self[name]?.values.first?.intValue }
    public func ints(_ name: String) -> [Int] { self[name]?.values.compactMap(\.intValue) ?? [] }
    public func bool(_ name: String) -> Bool? { self[name]?.values.first?.boolValue }
}

public struct IPPMessage {
    public var versionMajor: UInt8 = 2
    public var versionMinor: UInt8 = 0
    /// operation-id in a request, status-code in a response
    public var code: UInt16
    public var requestID: Int32 = 1
    public var groups: [IPPGroup] = []
    public var data = Data()

    /// Status codes 0x0000-0x00FF are successful-ok-*.
    public var isSuccess: Bool { code < 0x0100 }

    public func groups(_ tag: IPPTag) -> [IPPGroup] { groups.filter { $0.tag == tag } }
    public var operationGroup: IPPGroup? { groups.first { $0.tag == .operationAttributes } }
}

public enum IPPOperation {
    public static let cancelJob: UInt16 = 0x0008
    public static let getJobAttributes: UInt16 = 0x0009
    public static let getJobs: UInt16 = 0x000A
    public static let getPrinterAttributes: UInt16 = 0x000B
    public static let cupsGetDefault: UInt16 = 0x4001
    public static let cupsGetPrinters: UInt16 = 0x4002
}
