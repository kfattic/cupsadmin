import Foundation

/// RFC 8010 wire-format encoder.
enum IPPEncoder {
    static func encode(_ message: IPPMessage) -> Data {
        var out: [UInt8] = [message.versionMajor, message.versionMinor]
        out.appendUInt16(message.code)
        out.appendInt32(message.requestID)
        for group in message.groups {
            out.append(group.tag.rawValue)
            for attribute in group.attributes {
                for (index, value) in attribute.values.enumerated() {
                    // Additional values of a 1setOf carry an empty name.
                    write(value, name: index == 0 ? attribute.name : "", into: &out)
                }
            }
        }
        out.append(IPPTag.endOfAttributes.rawValue)
        return Data(out) + message.data
    }

    private static func write(_ value: IPPValue, name: String, into out: inout [UInt8]) {
        out.append(value.tag.rawValue)
        out.appendLengthPrefixed(Array(name.utf8))

        switch value {
        case .integer(let i), .enumeration(let i):
            out.appendUInt16(4)
            out.appendInt32(i)
        case .boolean(let b):
            out.appendUInt16(1)
            out.append(b ? 1 : 0)
        case .string(_, let s):
            out.appendLengthPrefixed(Array(s.utf8))
        case .stringWithLanguage(_, let language, let s):
            var payload: [UInt8] = []
            payload.appendLengthPrefixed(Array(language.utf8))
            payload.appendLengthPrefixed(Array(s.utf8))
            out.appendLengthPrefixed(payload)
        case .octetString(let d), .other(_, let d):
            out.appendLengthPrefixed([UInt8](d))
        case .dateTime(let date):
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(secondsFromGMT: 0)!
            let c = cal.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
            var payload: [UInt8] = []
            payload.appendUInt16(UInt16(c.year ?? 1970))
            payload += [c.month, c.day, c.hour, c.minute, c.second].map { UInt8($0 ?? 0) }
            payload += [UInt8((c.nanosecond ?? 0) / 100_000_000), UInt8(ascii: "+"), 0, 0]
            out.appendLengthPrefixed(payload)
        case .resolution(let x, let y, let units):
            out.appendUInt16(9)
            out.appendInt32(x)
            out.appendInt32(y)
            out.append(units)
        case .range(let lower, let upper):
            out.appendUInt16(8)
            out.appendInt32(lower)
            out.appendInt32(upper)
        case .outOfBand:
            out.appendUInt16(0)
        case .collection(let members):
            out.appendUInt16(0)
            for member in members {
                out.append(IPPTag.memberAttrName.rawValue)
                out.appendUInt16(0)
                out.appendLengthPrefixed(Array(member.name.utf8))
                for memberValue in member.values {
                    write(memberValue, name: "", into: &out)
                }
            }
            out.append(IPPTag.endCollection.rawValue)
            out.appendUInt16(0)
            out.appendUInt16(0)
        }
    }
}

/// RFC 8010 wire-format decoder.
struct IPPDecoder {
    enum DecodeError: Error, CustomStringConvertible {
        case truncated(offset: Int)
        case malformed(String, offset: Int)

        var description: String {
            switch self {
            case .truncated(let offset): return "IPP response truncated at byte \(offset)"
            case .malformed(let what, let offset): return "malformed IPP response at byte \(offset): \(what)"
            }
        }
    }

    private let bytes: [UInt8]
    private var offset = 0

    static func decode(_ data: Data) throws -> IPPMessage {
        var decoder = IPPDecoder(bytes: [UInt8](data))
        return try decoder.decodeMessage()
    }

    private init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    private mutating func decodeMessage() throws -> IPPMessage {
        let major = try readUInt8()
        let minor = try readUInt8()
        var message = IPPMessage(code: try readUInt16())
        message.versionMajor = major
        message.versionMinor = minor
        message.requestID = try readInt32()

        var current: IPPGroup?
        while true {
            let tag = IPPTag(rawValue: try readUInt8())
            if tag.isDelimiter {
                if let group = current { message.groups.append(group) }
                current = nil
                if tag == .endOfAttributes { break }
                current = IPPGroup(tag: tag, attributes: [])
                continue
            }
            guard current != nil else {
                throw DecodeError.malformed("value tag 0x\(String(tag.rawValue, radix: 16)) outside a group", offset: offset)
            }
            let name = try readString(length: Int(try readUInt16()))
            let value = try readValue(tag: tag)
            if name.isEmpty {
                guard !current!.attributes.isEmpty else {
                    throw DecodeError.malformed("additional value with no preceding attribute", offset: offset)
                }
                current!.attributes[current!.attributes.count - 1].values.append(value)
            } else {
                current!.attributes.append(IPPAttribute(name: name, values: [value]))
            }
        }
        message.data = Data(bytes[offset...])
        return message
    }

    /// Reads value-length + value for `tag` (the name has already been consumed).
    private mutating func readValue(tag: IPPTag) throws -> IPPValue {
        let length = Int(try readUInt16())
        if tag == .begCollection {
            _ = try readBytes(length)
            return .collection(try readCollectionMembers())
        }
        // Rebase to 0 so v[0], v[8] etc. index the value, not the whole response.
        let v = Array(try readBytes(length))[...]

        switch tag {
        case _ where tag.isOutOfBand:
            return .outOfBand(tag)
        case .integer where length == 4:
            return .integer(Self.int32(v, 0))
        case .enumeration where length == 4:
            return .enumeration(Self.int32(v, 0))
        case .boolean where length == 1:
            return .boolean(v[0] != 0)
        case .octetString:
            return .octetString(Data(v))
        case .dateTime where length == 11:
            return Self.date(v).map { .dateTime($0) } ?? .other(tag, Data(v))
        case .resolution where length == 9:
            return .resolution(x: Self.int32(v, 0), y: Self.int32(v, 4), units: v[8])
        case .rangeOfInteger where length == 8:
            return .range(Self.int32(v, 0), Self.int32(v, 4))
        case .textWithLanguage, .nameWithLanguage:
            guard length >= 4 else { return .other(tag, Data(v)) }
            let langLength = Int(UInt16(v[0]) << 8 | UInt16(v[1]))
            guard 2 + langLength + 2 <= length else { return .other(tag, Data(v)) }
            let language = String(decoding: v[2 ..< 2 + langLength], as: UTF8.self)
            let textStart = 2 + langLength
            let textLength = Int(UInt16(v[textStart]) << 8 | UInt16(v[textStart + 1]))
            guard textStart + 2 + textLength <= length else { return .other(tag, Data(v)) }
            let text = String(decoding: v[textStart + 2 ..< textStart + 2 + textLength], as: UTF8.self)
            return .stringWithLanguage(tag, language: language, text)
        case _ where tag.isCharacterString:
            return .string(tag, String(decoding: v, as: UTF8.self))
        default:
            return .other(tag, Data(v))
        }
    }

    /// Called just after a begCollection value; consumes through the matching endCollection.
    private mutating func readCollectionMembers() throws -> [IPPAttribute] {
        var members: [IPPAttribute] = []
        while true {
            let tag = IPPTag(rawValue: try readUInt8())
            guard !tag.isDelimiter else {
                throw DecodeError.malformed("delimiter inside collection", offset: offset)
            }
            _ = try readBytes(Int(try readUInt16()))  // name, always empty inside a collection

            if tag == .endCollection {
                _ = try readBytes(Int(try readUInt16()))
                return members
            }
            if tag == .memberAttrName {
                let memberName = try readString(length: Int(try readUInt16()))
                members.append(IPPAttribute(name: memberName, values: []))
                continue
            }
            guard !members.isEmpty else {
                throw DecodeError.malformed("collection value before memberAttrName", offset: offset)
            }
            let value = try readValue(tag: tag)
            members[members.count - 1].values.append(value)
        }
    }

    // MARK: primitives

    private mutating func readBytes(_ count: Int) throws -> ArraySlice<UInt8> {
        guard offset + count <= bytes.count else { throw DecodeError.truncated(offset: offset) }
        defer { offset += count }
        return bytes[offset ..< offset + count]
    }

    private mutating func readUInt8() throws -> UInt8 { try readBytes(1).first! }

    private mutating func readUInt16() throws -> UInt16 {
        let b = try readBytes(2)
        return UInt16(b[b.startIndex]) << 8 | UInt16(b[b.startIndex + 1])
    }

    private mutating func readInt32() throws -> Int32 { Self.int32(try readBytes(4), 0) }

    private mutating func readString(length: Int) throws -> String {
        String(decoding: try readBytes(length), as: UTF8.self)
    }

    private static func int32(_ b: ArraySlice<UInt8>, _ at: Int) -> Int32 {
        let i = b.startIndex + at
        return Int32(bitPattern: UInt32(b[i]) << 24 | UInt32(b[i + 1]) << 16 | UInt32(b[i + 2]) << 8 | UInt32(b[i + 3]))
    }

    /// RFC 2579 DateAndTime (11 octets).
    private static func date(_ b: ArraySlice<UInt8>) -> Date? {
        let s = b.startIndex
        var c = DateComponents()
        c.year = Int(UInt16(b[s]) << 8 | UInt16(b[s + 1]))
        c.month = Int(b[s + 2])
        c.day = Int(b[s + 3])
        c.hour = Int(b[s + 4])
        c.minute = Int(b[s + 5])
        c.second = Int(b[s + 6])
        c.nanosecond = Int(b[s + 7]) * 100_000_000
        let sign = b[s + 8] == UInt8(ascii: "-") ? -1 : 1
        let utcOffset = sign * (Int(b[s + 9]) * 3600 + Int(b[s + 10]) * 60)
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: utcOffset) ?? TimeZone(secondsFromGMT: 0)!
        return cal.date(from: c)
    }
}

private extension Array where Element == UInt8 {
    mutating func appendUInt16(_ v: UInt16) {
        append(UInt8(v >> 8))
        append(UInt8(v & 0xFF))
    }

    mutating func appendInt32(_ v: Int32) {
        let u = UInt32(bitPattern: v)
        append(contentsOf: [UInt8(u >> 24), UInt8(u >> 16 & 0xFF), UInt8(u >> 8 & 0xFF), UInt8(u & 0xFF)])
    }

    mutating func appendLengthPrefixed(_ payload: [UInt8]) {
        appendUInt16(UInt16(payload.count))
        append(contentsOf: payload)
    }
}
