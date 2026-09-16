import Foundation

/// CUPS printer-type bits (cups/cups.h cups_ptype_e) we surface.
public enum PrinterType {
    public static let isClass = 0x0000_0001
    public static let remote = 0x0000_0002
    public static let bw = 0x0000_0004
    public static let color = 0x0000_0008
    public static let duplex = 0x0000_0010
    public static let staple = 0x0000_0020
    public static let fax = 0x0004_0000
    public static let discovered = 0x0100_0000
    public static let scanner = 0x0200_0000
    public static let mfp = 0x0400_0000

    public static func kind(_ type: Int?) -> String {
        guard let type else { return "?" }
        var parts = [type & isClass != 0 ? "class" : "printer"]
        if type & remote != 0 { parts.append("remote") }
        if type & discovered != 0 { parts.append("discovered") }
        if type & fax != 0 { parts.append("fax") }
        return parts.joined(separator: ",")
    }

    public static func capabilities(_ type: Int?) -> String {
        guard let type else { return "?" }
        var caps: [String] = []
        if type & color != 0 { caps.append("color") } else if type & bw != 0 { caps.append("b/w") }
        if type & duplex != 0 { caps.append("duplex") }
        if type & staple != 0 { caps.append("staple") }
        if type & scanner != 0 { caps.append("scanner") }
        if type & mfp != 0 { caps.append("mfp") }
        return caps.isEmpty ? "-" : caps.joined(separator: ", ")
    }
}
