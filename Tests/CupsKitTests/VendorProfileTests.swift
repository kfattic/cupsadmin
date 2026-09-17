@testable import CupsKit
import Foundation
import Testing

/// Canon and HP profile tests read the vendors' gzipped PPDs, read-only. They look in CUPSKIT_PPD_DIRS
/// (colon-separated, e.g. PPDs extracted with `pkgutil --expand-full` from a driver package you haven't
/// installed) and then /Library/Printers/PPDs; each test is skipped when its PPDs aren't found.
enum ExtraPPDs {
    static let directories: [String] =
        (ProcessInfo.processInfo.environment["CUPSKIT_PPD_DIRS"] ?? "").split(separator: ":").map(String.init) + [vendorPPDs]

    static func path(_ name: String) -> String? {
        directories.map { ($0 as NSString).appendingPathComponent(name) }.first { FileManager.default.fileExists(atPath: $0) }
    }

    static func files(prefix: String) -> [String] {
        var seen: Set<String> = []
        return directories.flatMap { dir in
            ((try? FileManager.default.contentsOfDirectory(atPath: dir)) ?? [])
                .filter { $0.hasPrefix(prefix) && seen.insert($0).inserted }
                .sorted()
                .map { (dir as NSString).appendingPathComponent($0) }
        }
    }

    static func context(path: String) -> DriverContext? {
        (try? PPD.text(contentsOfFile: path)).map { DriverContext(ppd: PPD(text: $0), attributes: nil) }
    }

    static func context(_ name: String) -> DriverContext? { path(name).flatMap(context(path:)) }
}

private func resolved(_ id: String, _ c: DriverContext) -> ResolvedQuickAction? {
    try? QuickAction.named(id)!.resolve(c, value: "0").get()
}

private func pairs(_ id: String, _ c: DriverContext) -> [String]? {
    resolved(id, c)?.changes.map { "\($0.key)=\($0.value)" }
}

private func hasChoice(_ c: DriverContext, _ keyword: String, _ choice: String) -> Bool {
    c.ppd?.option(keyword)?.choices.contains(choice) == true
}

@Suite struct CanonProfile {
    static let adv = "CNPZUIRAC3530IIIZU.ppd.gz"

    @Test(.enabled(if: ExtraPPDs.path(adv) != nil))
    func imageRunnerAdvance() throws {
        let c = try #require(ExtraPPDs.context(Self.adv))
        #expect(DriverProfiles.matching(c).map(\.id) == ["canon", "generic"])
        #expect(pairs("color", c) == ["CNColorMode=color"])
        #expect(pairs("bw", c) == ["CNColorMode=mono"])
        #expect(pairs("duplex", c) == ["CNDuplex=DuplexFront"])
        #expect(pairs("simplex", c) == ["CNDuplex=None"])
        #expect(pairs("letter", c) == ["PageSize=Letter"])
        for id in ["color", "bw", "duplex", "simplex", "letter"] { #expect(resolved(id, c)?.profile.id == "canon", "\(id)") }
        // No fit-to-paper option in Canon's PPDs: Letter sets the page size only, and the title says so.
        #expect(QuickAction.named("letter")!.title(in: c) == "Use Letter Paper")
        #expect(QuickAction.named("usercode")!.unavailableReason(in: c) == "Canon department IDs are set by the Canon driver, not the PPD")
        #expect(throws: QuickActionUnavailable.self) { try QuickAction.named("usercode")!.resolve(c, clearing: true).get() }
    }

    /// Every Canon PPD in the package: an action is offered exactly when the PPD has its keyword and choice.
    @Test(.enabled(if: !ExtraPPDs.files(prefix: "CNPZU").isEmpty))
    func everyCanonPPD() throws {
        let files = ExtraPPDs.files(prefix: "CNPZU")
        var mono = 0
        for file in files {
            let c = try #require(ExtraPPDs.context(path: file), "\(file)")
            let name = (file as NSString).lastPathComponent
            #expect(DriverProfiles.matching(c).first?.id == "canon", "\(name)")
            #expect(QuickAction.named("color")!.isAvailable(in: c) == hasChoice(c, "CNColorMode", "color"), "\(name)")
            #expect(QuickAction.named("bw")!.isAvailable(in: c) == hasChoice(c, "CNColorMode", "mono"), "\(name)")
            #expect(QuickAction.named("duplex")!.isAvailable(in: c) == hasChoice(c, "CNDuplex", "DuplexFront"), "\(name)")
            #expect(QuickAction.named("simplex")!.isAvailable(in: c) == hasChoice(c, "CNDuplex", "None"), "\(name)")
            #expect(pairs("letter", c) == ["PageSize=Letter"], "\(name)")
            #expect(QuickAction.named("letter")!.title(in: c) == "Use Letter Paper", "\(name)")
            #expect(QuickAction.named("usercode")!.unavailableReason(in: c) == "Canon department IDs are set by the Canon driver, not the PPD")
            if !hasChoice(c, "CNColorMode", "color") { mono += 1 }
        }
        #expect(files.count - mono > 0 && mono > 0)
    }
}

@Suite struct HPProfile {
    static let colorLaser = "HP Color LaserJet M750.gz"
    static let officejet = "HP Officejet Pro 8600.ppd.gz"
    static let monoLaser = "HP LaserJet 600 M601 M602 M603.gz"
    static let reason = "HP drivers have no accounting code option"

    @Test(.enabled(if: ExtraPPDs.path(colorLaser) != nil))
    func colorLaserJetEnterprise() throws {
        let c = try #require(ExtraPPDs.context(Self.colorLaser))
        #expect(DriverProfiles.matching(c).map(\.id) == ["hp", "generic"])
        #expect(pairs("color", c) == ["HPColorAsGray=False"])
        #expect(pairs("bw", c) == ["HPColorAsGray=True"])
        #expect(resolved("color", c)?.profile.id == "hp")
        #expect(pairs("duplex", c) == ["Duplex=DuplexNoTumble"])
        #expect(pairs("simplex", c) == ["Duplex=None"])
        #expect(resolved("duplex", c)?.profile.id == "generic")
        #expect(pairs("letter", c) == ["PageSize=Letter"])
        #expect(QuickAction.named("letter")!.title(in: c) == "Use Letter Paper")
        #expect(QuickAction.named("usercode")!.unavailableReason(in: c) == Self.reason)
    }

    @Test(.enabled(if: ExtraPPDs.path(officejet) != nil))
    func officejetProUsesHPColorMode() throws {
        let c = try #require(ExtraPPDs.context(Self.officejet))
        #expect(pairs("color", c) == ["HPColorMode=colorsmart"])
        #expect(pairs("bw", c) == ["HPColorMode=grayscale"])
        #expect(resolved("bw", c)?.profile.id == "hp")
        #expect(pairs("duplex", c) == ["Duplex=DuplexNoTumble"])
        #expect(pairs("letter", c) == ["PageSize=Letter"])
        #expect(QuickAction.named("usercode")!.unavailableReason(in: c) == Self.reason)
    }

    @Test(.enabled(if: ExtraPPDs.path(monoLaser) != nil))
    func monoLaserJet() throws {
        let c = try #require(ExtraPPDs.context(Self.monoLaser))
        #expect(!QuickAction.named("color")!.isAvailable(in: c) && !QuickAction.named("bw")!.isAvailable(in: c))
        #expect(pairs("duplex", c) == ["Duplex=DuplexNoTumble"])
        #expect(pairs("letter", c) == ["PageSize=Letter"])
        #expect(QuickAction.named("usercode")!.unavailableReason(in: c) == Self.reason)
    }

    /// Every HP PPD: color and black & white come from the HP profile whenever the PPD has HPColorAsGray or HPColorMode.
    @Test(.enabled(if: ExtraPPDs.files(prefix: "HP ").count > 100))
    func everyHPPPD() throws {
        var hpColor = 0
        for file in ExtraPPDs.files(prefix: "HP ") {
            let c = try #require(ExtraPPDs.context(path: file), "\(file)")
            let name = (file as NSString).lastPathComponent
            guard c.manufacturer == "HP" else { continue }
            #expect(DriverProfiles.matching(c).first?.id == "hp", "\(name)")
            #expect(QuickAction.named("usercode")!.unavailableReason(in: c) == Self.reason, "\(name)")
            if hasChoice(c, "HPColorAsGray", "True") || hasChoice(c, "HPColorMode", "grayscale") {
                #expect(resolved("bw", c)?.profile.id == "hp", "\(name)")
                hpColor += 1
            }
            if hasChoice(c, "HPColorAsGray", "False") || hasChoice(c, "HPColorMode", "colorsmart") {
                #expect(resolved("color", c)?.profile.id == "hp", "\(name)")
            }
            if hasChoice(c, "PageSize", "Letter") { #expect(QuickAction.named("letter")!.title(in: c) == "Use Letter Paper", "\(name)") }
        }
        #expect(hpColor > 0)
    }
}
