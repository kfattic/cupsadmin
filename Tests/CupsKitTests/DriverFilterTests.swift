@testable import CupsKit
import Foundation
import Testing

private func le32(_ v: UInt32) -> [UInt8] { [UInt8(v & 0xFF), UInt8(v >> 8 & 0xFF), UInt8(v >> 16 & 0xFF), UInt8(v >> 24)] }
private func be32(_ v: UInt32) -> [UInt8] { [UInt8(v >> 24), UInt8(v >> 16 & 0xFF), UInt8(v >> 8 & 0xFF), UInt8(v & 0xFF)] }
private let x86_64: UInt32 = 0x0100_0007, arm64: UInt32 = 0x0100_000C

/// Thin 64-bit Mach-O header (little-endian).
private func thin(_ cpu: UInt32, subtype: UInt32 = 0) -> [UInt8] {
    var bytes: [UInt8] = le32(0xFEEDFACF)
    bytes += le32(cpu)
    bytes += le32(subtype)
    bytes += [UInt8](repeating: 0, count: 20)
    return bytes
}

/// Universal (fat32) header with the given slices.
private func fat(_ slices: [(UInt32, UInt32)]) -> [UInt8] {
    var bytes: [UInt8] = be32(0xCAFEBABE)
    bytes += be32(UInt32(slices.count))
    for (cpu, subtype) in slices {
        bytes += be32(cpu)
        bytes += be32(subtype)
        bytes += be32(0x4000)   // offset
        bytes += be32(0x1000)   // size
        bytes += be32(14)       // align
    }
    return bytes
}

@Suite struct MachOArchitectures {
    @Test func thinAndUniversalBinaries() {
        #expect(DriverFilterCheck.status(header: thin(arm64)) == .native(architectures: ["arm64"]))
        #expect(DriverFilterCheck.status(header: thin(x86_64)) == .intelOnly(architectures: ["x86_64"]))
        #expect(DriverFilterCheck.status(header: fat([(x86_64, 3), (arm64, 2)])) == .native(architectures: ["x86_64", "arm64e"]))
        #expect(DriverFilterCheck.status(header: fat([(x86_64, 3), (7, 3)])) == .intelOnly(architectures: ["x86_64", "i386"]))
        // A newer arm64 subtype lipo can't name (seen on macOS 27's rastertohp) still counts as arm64.
        #expect(DriverFilterCheck.status(header: fat([(x86_64, 3), (arm64, 12)])) == .native(architectures: ["x86_64", "arm64"]))
    }

    @Test func scriptsAndOtherFiles() {
        #expect(DriverFilterCheck.status(header: Array("#!/bin/sh\nexec foo\n".utf8)) == .script(interpreter: "/bin/sh"))
        #expect(DriverFilterCheck.status(header: Array("%PDF-1.4 not a filter".utf8)) == .unrecognized)
        #expect(DriverFilterCheck.status(header: [0xCA, 0xFE, 0xBA, 0xBE, 0, 0, 0, 52]) == .unrecognized)   // Java class file
    }

    @Test(.enabled(if: FileManager.default.fileExists(atPath: "/usr/libexec/cups/filter/rastertohp")))
    func appleFilterIsNative() {
        guard case .native = DriverFilterCheck.status(atPath: "/usr/libexec/cups/filter/rastertohp") else {
            Issue.record("rastertohp should have an arm64 slice"); return
        }
    }
}

@Suite struct FilterLines {
    @Test func resolvesAndClassifiesEveryFilter() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("cupsadmin-filters-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        try Data(thin(arm64)).write(to: dir.appendingPathComponent("nativefilter"))
        let intel = dir.appendingPathComponent("Vendor Filters/pstopsvendor")
        try FileManager.default.createDirectory(at: intel.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(fat([(x86_64, 3)])).write(to: intel)

        let ppd = PPD(text: """
        *PPD-Adobe: "4.3"
        *cupsFilter: "application/vnd.cups-raster 50 nativefilter"
        *cupsFilter: "application/vnd.cups-postscript 0 \(intel.path)"
        *cupsFilter2: "application/vnd.cups-pdf application/pdf 0 maxsize(0) -"
        *cupsFilter: "application/vnd.cups-command 0 /Library/Printers/Nobody/Filters/gone"
        *cupsFilter: "application/vnd.cups-postscript 0 \(intel.path)"
        """)
        #expect(ppd.filterLines.count == 5)

        let report = DriverFilterCheck.check(ppd, filterDirectory: dir.path)
        #expect(report.filters.count == 4)   // duplicate pstopsvendor line counted once
        #expect(report.filters[0].status == .native(architectures: ["arm64"]))
        #expect(report.filters[0].path == dir.appendingPathComponent("nativefilter").path)
        #expect(report.filters[1].status == .intelOnly(architectures: ["x86_64"]))
        #expect(report.filters[2].status == .passthrough)
        #expect(report.filters[3].status == .missing)

        #expect(report.needsRosetta && report.hasMissingFilter)
        #expect(report.headline == "Driver filter missing")   // missing outranks Rosetta
        #expect(report.detail == "/Library/Printers/Nobody/Filters/gone not found; pstopsvendor is Intel-only (x86_64)")
    }

    @Test func rosettaOnlyAndClean() {
        let passthrough = PPD(text: "*cupsFilter2: \"application/vnd.cups-pdf application/pdf 0 maxsize(0) -\"\n*cupsFilter: \"image/urf 10 -\"\n")
        let clean = DriverFilterCheck.check(passthrough)
        #expect(!clean.isFlagged && clean.headline == nil && clean.warning == nil)

        let none = DriverFilterCheck.check(PPD(text: "*NickName: \"No filters\"\n"))
        #expect(none.filters.isEmpty && !none.isFlagged)
    }

    @Test(.enabled(if: hasVendorPPD("RICOH IM C4500")))
    func ricohVendorPPDNamesItsFilters() throws {
        let report = DriverFilterCheck.check(try #require(vendorPPD("RICOH IM C4500")))
        #expect(report.filters.map(\.name) == ["commandfilterRV1", "pstopsRV2"] || report.filters.map(\.name) == ["pstopsRV2", "commandfilterRV1"])
    }
}
