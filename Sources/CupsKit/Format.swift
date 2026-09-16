import Foundation

public enum Format {
    public static func printerState(_ state: Int?) -> String {
        switch state {
        case 3: return "idle"
        case 4: return "processing"
        case 5: return "stopped"
        case let s?: return "state-\(s)"
        case nil: return "?"
        }
    }

    public static func jobState(_ state: Int?) -> String {
        switch state {
        case 3: return "pending"
        case 4: return "held"
        case 5: return "processing"
        case 6: return "stopped"
        case 7: return "canceled"
        case 8: return "aborted"
        case 9: return "completed"
        case let s?: return "state-\(s)"
        case nil: return "?"
        }
    }

    /// CUPS reports most *-time attributes as integer seconds since the epoch.
    public static func epoch(_ seconds: Int?) -> String {
        guard let seconds, seconds > 0 else { return "-" }
        return timestamp(Date(timeIntervalSince1970: TimeInterval(seconds)))
    }

    public static func timestamp(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f.string(from: date)
    }

    public static func kilobytes(_ k: Int?) -> String {
        guard let k else { return "-" }
        if k < 1024 { return "\(k)K" }
        return String(format: "%.1fM", Double(k) / 1024)
    }

    public static func yesNo(_ b: Bool?) -> String {
        guard let b else { return "?" }
        return b ? "yes" : "no"
    }

    /// state-reasons without the "none" placeholder.
    public static func reasons(_ values: [String]) -> String {
        let real = values.filter { $0 != "none" }
        return real.isEmpty ? "none" : real.joined(separator: ",")
    }

    public static func value(_ value: IPPValue, attribute: String) -> String {
        switch value {
        case .integer(let i):
            if attribute.hasSuffix("-time") || attribute.hasPrefix("time-at-"), i > 946_684_800 {
                return "\(i) (\(epoch(Int(i))))"
            }
            return String(i)
        case .enumeration(let e):
            switch attribute {
            case "printer-state": return printerState(Int(e))
            case "job-state": return jobState(Int(e))
            case "print-quality-default", "print-quality-supported":
                return [3: "draft", 4: "normal", 5: "high"][e] ?? String(e)
            default: return String(e)
            }
        case .boolean(let b): return b ? "true" : "false"
        case .string(_, let s): return s
        case .stringWithLanguage(_, let language, let s): return "\(s) [\(language)]"
        case .octetString(let d):
            if let s = String(data: d, encoding: .utf8), !s.contains(where: { $0.isASCII && $0.asciiValue! < 0x20 }) {
                return s
            }
            return "<\(d.count) bytes>"
        case .dateTime(let date): return timestamp(date)
        case .resolution(let x, let y, let units):
            let unit = units == 3 ? "dpi" : units == 4 ? "dpcm" : "units\(units)"
            return x == y ? "\(x)\(unit)" : "\(x)x\(y)\(unit)"
        case .range(let lower, let upper): return "\(lower)-\(upper)"
        case .collection(let members):
            let inner = members.map { m in
                "\(m.name)=" + m.values.map { self.value($0, attribute: m.name) }.joined(separator: ",")
            }
            return "{" + inner.joined(separator: " ") + "}"
        case .outOfBand(let tag):
            switch tag {
            case .unsupported: return "(unsupported)"
            case .unknown: return "(unknown)"
            case .noValue: return "(no-value)"
            default: return "(out-of-band 0x\(String(tag.rawValue, radix: 16)))"
            }
        case .other(let tag, let d):
            return "<tag 0x\(String(tag.rawValue, radix: 16)), \(d.count) bytes>"
        }
    }
}
