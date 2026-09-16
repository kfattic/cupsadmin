import Darwin
import Foundation

/// One filter program a PPD names in `*cupsFilter` / `*cupsFilter2`, and whether it can run natively.
public struct DriverFilter: Hashable {
    public enum Status: Hashable {
        /// Has an arm64 slice (arm64, arm64e or newer subtypes).
        case native(architectures: [String])
        /// Intel only: needs Rosetta on Apple silicon.
        case intelOnly(architectures: [String])
        /// A script (`#!`); runs wherever its interpreter does.
        case script(interpreter: String)
        /// `-`: no program, cupsd passes the data through.
        case passthrough
        case missing
        /// Exists but isn't a Mach-O binary or script this check understands.
        case unrecognized
    }

    public let keyword: String
    /// The line's value, e.g. `application/vnd.cups-postscript 0 /Library/Printers/…/pstopsRV2`.
    public let line: String
    public let program: String
    /// Resolved absolute path; nil for `-`.
    public let path: String?
    public let status: Status

    public var name: String { (program as NSString).lastPathComponent }
}

public struct DriverFilterReport: Hashable {
    public let filters: [DriverFilter]

    public var intelOnly: [DriverFilter] { filters.filter { if case .intelOnly = $0.status { return true } else { return false } } }
    public var missing: [DriverFilter] { filters.filter { $0.status == .missing } }
    public var needsRosetta: Bool { !intelOnly.isEmpty }
    public var hasMissingFilter: Bool { !missing.isEmpty }
    public var isFlagged: Bool { needsRosetta || hasMissingFilter }

    /// "Driver filter missing" (worse, shown first) or "Driver needs Rosetta"; nil when fine.
    public var headline: String? {
        if hasMissingFilter { return "Driver filter missing" }
        if needsRosetta { return "Driver needs Rosetta" }
        return nil
    }

    /// e.g. "pstopsRV2, commandfilterRV1 are Intel-only (x86_64); /Library/…/foo not found".
    public var detail: String? {
        var parts: [String] = []
        if !missing.isEmpty {
            parts.append(missing.compactMap(\.path).joined(separator: ", ") + " not found")
        }
        if !intelOnly.isEmpty {
            let names = intelOnly.map(\.name)
            let archs = Set(intelOnly.flatMap { if case .intelOnly(let a) = $0.status { return a } else { return [] } }).sorted()
            parts.append("\(names.joined(separator: ", ")) \(names.count == 1 ? "is" : "are") Intel-only (\(archs.joined(separator: ", ")))")
        }
        return parts.isEmpty ? nil : parts.joined(separator: "; ")
    }

    /// One line for CLI output: "Driver needs Rosetta — pstopsRV2 is Intel-only (x86_64)".
    public var warning: String? {
        guard let headline, let detail else { return nil }
        return "\(headline) — \(detail)"
    }
}

public enum DriverFilterCheck {
    /// Where cupsd looks for filters named without a path.
    public static let filterDirectory = "/usr/libexec/cups/filter"

    public static func check(_ ppd: PPD, filterDirectory: String = filterDirectory) -> DriverFilterReport {
        var seen = Set<String>()
        var filters: [DriverFilter] = []
        for (keyword, value) in ppd.filterLines {
            // cupsFilter: "type cost program"; cupsFilter2: "source destination cost [maxsize(n)] program".
            var fields = value.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
            let skip = keyword == "cupsFilter2" ? 3 : 2
            guard fields.count > skip else { continue }
            fields.removeFirst(skip)
            if let first = fields.first, first.hasPrefix("maxsize("), first.hasSuffix(")") { fields.removeFirst() }
            guard !fields.isEmpty else { continue }
            let program = fields.joined(separator: " ")
            let path: String? = program == "-" ? nil
                : program.hasPrefix("/") ? program : (filterDirectory as NSString).appendingPathComponent(program)
            guard seen.insert(path ?? "-\(keyword)").inserted else { continue }
            let status: DriverFilter.Status = path.map(Self.status(atPath:)) ?? .passthrough
            filters.append(DriverFilter(keyword: keyword, line: value, program: program, path: path, status: status))
        }
        return DriverFilterReport(filters: filters)
    }

    /// Reads the file's header: Mach-O (thin or universal) or `#!` script.
    public static func status(atPath path: String) -> DriverFilter.Status {
        guard FileManager.default.fileExists(atPath: path) else { return .missing }
        guard let handle = FileHandle(forReadingAtPath: path) else { return .unrecognized }
        defer { try? handle.close() }
        let header = [UInt8](handle.readData(ofLength: 4096))
        return status(header: header)
    }

    static func status(header b: [UInt8]) -> DriverFilter.Status {
        guard b.count >= 8 else { return .unrecognized }
        if b[0] == UInt8(ascii: "#"), b[1] == UInt8(ascii: "!") {
            let line = b.prefix { $0 != UInt8(ascii: "\n") }.dropFirst(2)
            return .script(interpreter: String(decoding: line, as: UTF8.self).trimmingCharacters(in: .whitespaces))
        }
        func be32(_ i: Int) -> UInt32 { UInt32(b[i]) << 24 | UInt32(b[i + 1]) << 16 | UInt32(b[i + 2]) << 8 | UInt32(b[i + 3]) }
        func le32(_ i: Int) -> UInt32 { UInt32(b[i + 3]) << 24 | UInt32(b[i + 2]) << 16 | UInt32(b[i + 1]) << 8 | UInt32(b[i]) }

        var cpuTypes: [(type: UInt32, subtype: UInt32)] = []
        switch be32(0) {
        case 0xCAFEBABE, 0xCAFEBABF:   // universal (fat32 / fat64)
            let count = Int(be32(4))
            let entrySize = be32(0) == 0xCAFEBABF ? 32 : 20
            guard count > 0, count < 32 else { return .unrecognized }   // Java class files share the magic
            for i in 0 ..< count {
                let offset = 8 + i * entrySize
                guard offset + 8 <= b.count else { break }
                cpuTypes.append((be32(offset), be32(offset + 4) & 0x00FF_FFFF))
            }
        default:
            switch le32(0) {
            case 0xFEEDFACF, 0xFEEDFACE:   // thin Mach-O, little-endian
                cpuTypes.append((le32(4), le32(8) & 0x00FF_FFFF))
            default:
                return .unrecognized
            }
        }
        let names = cpuTypes.map { architectureName(type: $0.type, subtype: $0.subtype) }
        if cpuTypes.contains(where: { $0.type == 0x0100_000C }) { return .native(architectures: names) }
        if cpuTypes.contains(where: { $0.type == 0x0100_0007 || $0.type == 7 }) { return .intelOnly(architectures: names) }
        return .unrecognized
    }

    static func architectureName(type: UInt32, subtype: UInt32) -> String {
        switch type {
        case 0x0100_0007: return "x86_64"
        case 7: return "i386"
        case 0x0100_000C: return subtype == 2 ? "arm64e" : "arm64"
        case 0x0200_000C: return "arm64_32"
        case 12: return "arm"
        default: return "cpu\(type)"
        }
    }

    /// True on Apple silicon (also when this process itself runs under Rosetta).
    public static var hostIsAppleSilicon: Bool {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        return sysctlbyname("hw.optional.arm64", &value, &size, nil, 0) == 0 && value == 1
    }

    public static var rosettaInstalled: Bool {
        FileManager.default.fileExists(atPath: "/Library/Apple/usr/libexec/oah/libRosettaRuntime")
    }
}
