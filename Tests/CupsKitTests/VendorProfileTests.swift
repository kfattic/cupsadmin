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

@Suite struct XeroxProfile {
    static let altaLink = "Xerox AltaLink C8170.gz"
    static let monoVersaLink = "Xerox VersaLink B620 Printer.gz"

    @Test(.enabled(if: ExtraPPDs.path(altaLink) != nil))
    func altaLinkColorAndStandardAccounting() throws {
        let c = try #require(ExtraPPDs.context(Self.altaLink))
        #expect(DriverProfiles.matching(c).map(\.id) == ["xerox", "generic"])
        #expect(pairs("color", c) == ["XROutputColor=PrintAsColor"])
        #expect(pairs("bw", c) == ["XROutputColor=PrintAsGrayscale"])
        #expect(resolved("duplex", c)?.profile.id == "generic" && pairs("duplex", c) == ["Duplex=DuplexNoTumble"])
        #expect(resolved("letter", c)?.profile.id == "generic" && pairs("letter", c) == ["PageSize=Letter"])
        #expect(QuickAction.named("letter")!.title(in: c) == "Use Letter Paper")

        let usercode = QuickAction.named("usercode")!
        #expect(usercode.inputLabel(c) == "User ID")
        #expect(usercode.secondInputLabel(c) == "Account ID (optional)")
        #expect(!usercode.digitsOnly(c))
        #expect(try usercode.resolve(c, value: "jdoe").get().changes.map { "\($0.key)=\($0.value)" }
                == ["XRAccountingSystem=XSA", "AcctUserID=Custom.jdoe"])
        #expect(try usercode.resolve(c, value: "jdoe", secondValue: "").get().changes.count == 2)
        #expect(try usercode.resolve(c, value: "jdoe", secondValue: "ART101").get().changes.map { "\($0.key)=\($0.value)" }
                == ["XRAccountingSystem=XSA", "AcctUserID=Custom.jdoe", "AcctAccountID=Custom.ART101"])
        #expect(try usercode.resolve(c, clearing: true).get().changes.map { "\($0.key)=\($0.value)" }
                == ["XRAccountingSystem=None", "AcctUserID=None", "AcctAccountID=None"])

        #expect(usercode.validationError("jdoe", context: c) == nil)
        #expect(usercode.validationError(String(repeating: "a", count: 33), context: c) == "At most 32 characters")
        #expect(usercode.validationError("j\"doe", context: c) == "No quotes, backslashes or line breaks")
        #expect(usercode.secondValidationError("ART101", context: c) == nil)
        #expect(usercode.secondValidationError(String(repeating: "9", count: 33), context: c) == "At most 32 characters")
    }

    @Test(.enabled(if: ExtraPPDs.path(monoVersaLink) != nil))
    func versaLinkWithoutXROutputColorFallsBackToColorCorrection() throws {
        let c = try #require(ExtraPPDs.context(Self.monoVersaLink))
        #expect(pairs("bw", c) == ["XRColorCorrection=Gray"])
        #expect(resolved("bw", c)?.profile.id == "xerox")
        #expect(!QuickAction.named("color")!.isAvailable(in: c))   // mono: Gray is the only choice
        #expect(QuickAction.named("usercode")!.isAvailable(in: c))
    }

    /// Every Xerox PPD in the package: each action is offered exactly when the PPD has what the profile needs.
    @Test(.enabled(if: ExtraPPDs.files(prefix: "Xerox ").count > 100))
    func everyXeroxPPD() throws {
        var accounting = 0
        for file in ExtraPPDs.files(prefix: "Xerox ") {
            let c = try #require(ExtraPPDs.context(path: file), "\(file)")
            let name = (file as NSString).lastPathComponent
            #expect(DriverProfiles.matching(c).first?.id == "xerox", "\(name)")
            #expect(QuickAction.named("color")!.isAvailable(in: c)
                    == (hasChoice(c, "XROutputColor", "PrintAsColor") || hasChoice(c, "XRColorCorrection", "Auto")), "\(name)")
            #expect(QuickAction.named("bw")!.isAvailable(in: c)
                    == (hasChoice(c, "XROutputColor", "PrintAsGrayscale") || hasChoice(c, "XRColorCorrection", "Gray")), "\(name)")
            let xsa = hasChoice(c, "XRAccountingSystem", "XSA") && c.ppd?.option("AcctUserID")?.customParameters.isEmpty == false
            #expect(QuickAction.named("usercode")!.isAvailable(in: c) == xsa, "\(name)")
            if xsa { accounting += 1 }
        }
        #expect(accounting > 0)
    }
}

@Suite struct KonicaMinoltaProfile {
    static let bizhub = "KONICAMINOLTAC651i.gz"
    static let reason = "Konica Minolta Account Track codes are set by the driver, not the PPD"

    @Test(.enabled(if: ExtraPPDs.path(bizhub) != nil))
    func bizhubC651i() throws {
        let c = try #require(ExtraPPDs.context(Self.bizhub))
        #expect(DriverProfiles.matching(c).map(\.id) == ["konica-minolta", "generic"])
        #expect(pairs("color", c) == ["ColorModel=CMYK"] && resolved("color", c)?.profile.id == "generic")
        #expect(pairs("bw", c) == ["ColorModel=Gray"])
        #expect(pairs("duplex", c) == ["KMDuplex=Double"] && resolved("duplex", c)?.profile.id == "konica-minolta")
        #expect(pairs("simplex", c) == ["KMDuplex=Single"])
        #expect(pairs("letter", c) == ["PageSize=8.5x11"])
        #expect(QuickAction.named("letter")!.title(in: c) == "Use Letter Paper")
        #expect(QuickAction.named("usercode")!.unavailableReason(in: c) == Self.reason)
    }

    /// Every bizhub PPD found (i and xi, plus the 1-sided "S" variants).
    @Test(.enabled(if: !ExtraPPDs.files(prefix: "KONICAMINOLTA").isEmpty))
    func everyKonicaMinoltaPPD() throws {
        for file in ExtraPPDs.files(prefix: "KONICAMINOLTA") {
            let c = try #require(ExtraPPDs.context(path: file), "\(file)")
            let name = (file as NSString).lastPathComponent
            #expect(DriverProfiles.matching(c).first?.id == "konica-minolta", "\(name)")
            #expect(QuickAction.named("duplex")!.isAvailable(in: c) == hasChoice(c, "KMDuplex", "Double"), "\(name)")
            #expect(QuickAction.named("simplex")!.isAvailable(in: c) == hasChoice(c, "KMDuplex", "Single"), "\(name)")
            #expect(QuickAction.named("letter")!.isAvailable(in: c) == hasChoice(c, "PageSize", "8.5x11"), "\(name)")
            #expect(QuickAction.named("bw")!.isAvailable(in: c) == hasChoice(c, "ColorModel", "Gray"), "\(name)")
            #expect(QuickAction.named("usercode")!.unavailableReason(in: c) == Self.reason, "\(name)")
        }
    }
}
