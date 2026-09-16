@testable import CupsKit
import Foundation
import Testing

private func context(_ ppdFile: String) -> DriverContext? {
    vendorPPD(ppdFile).map { DriverContext(ppd: $0, attributes: nil) }
}

private func available(_ id: String, _ context: DriverContext) -> Bool {
    QuickAction.named(id)!.isAvailable(in: context)
}

private func profileID(_ id: String, _ context: DriverContext) -> String? {
    guard case .success(let resolved) = QuickAction.named(id)!.resolve(context, value: "0") else { return nil }
    return resolved.profile.id
}

@Suite struct DriverProfileFile {
    @Test func builtInProfilesAreWellFormed() {
        let profiles = DriverProfiles.builtIn
        #expect(profiles.map(\.id) == ["ricoh-m-c251fw", "ricoh", "generic"])
        #expect(profiles.last?.isGeneric == true)
        #expect(profiles.dropLast().allSatisfy { !$0.isGeneric })
        let known = Set(QuickAction.all.map(\.id)).union(["usercode-clear"])
        for profile in profiles {
            #expect(Set(profile.actions.keys).isSubset(of: known), "\(profile.id): \(profile.actions.keys.sorted())")
            for alternatives in profile.actions.values {
                #expect(alternatives.allSatisfy { !$0.isEmpty && $0.allSatisfy { QuickAction.parse($0) != nil } })
            }
        }
    }
}

/// One test per Ricoh PPD documented in docs/ricoh-ppd-options.md (vendor PPDs; skipped when not installed).
@Suite struct RicohProfileMatching {
    static let postScript = ["RICOH IM C2000", "RICOH IM C4500", "RICOH MP C2004ex", "RICOH MP C3004ex",
                             "RICOH MP C307", "RICOH MP C3504"]

    @Test(.enabled(if: postScript.allSatisfy(hasVendorPPD)), arguments: postScript)
    func ricohColorPostScript(_ file: String) throws {
        let c = try #require(context(file))
        for id in ["color", "bw", "usercode", "duplex", "simplex", "letter"] {
            #expect(profileID(id, c) == "ricoh", "\(file) \(id)")
        }
        let letter = try QuickAction.named("letter")!.resolve(c).get().changes
        #expect(letter == [OptionChange(key: "PageSize", value: "Letter", isSecret: false),
                           OptionChange(key: "RIPaperPolicy", value: "NearestSizeAdjust", isSecret: false)])
        let code = try QuickAction.named("usercode")!.resolve(c, value: "4321").get().changes
        #expect(code.map(\.value) == ["True", "Custom.4321"])
        let clear = try QuickAction.named("usercode")!.resolve(c, clearing: true).get().changes
        #expect(clear.map(\.value) == ["False", "None"])
    }

    @Test(.enabled(if: hasVendorPPD("RICOH MP 5055")))
    func ricohMonoPostScript() throws {
        let c = try #require(context("RICOH MP 5055"))
        #expect(!available("color", c) && !available("bw", c))   // mono: no ColorModel
        #expect(QuickAction.named("color")!.unavailableReason(in: c)?.hasPrefix("Not available for RICOH MP 5055 PS") == true)
        for id in ["usercode", "duplex", "simplex", "letter"] { #expect(profileID(id, c) == "ricoh", "\(id)") }
    }

    @Test(.enabled(if: hasVendorPPD("RICOH M C251FW.ppd")))
    func ricohMC251FWUsesHQColorMode() throws {
        let c = try #require(context("RICOH M C251FW.ppd"))
        #expect(profileID("color", c) == "ricoh-m-c251fw")
        #expect(try QuickAction.named("color")!.resolve(c).get().changes == [OptionChange(key: "HQColorMode", value: "COLOR", isSecret: false)])
        #expect(!available("usercode", c))
        #expect(profileID("letter", c) == "ricoh-m-c251fw")
    }

    @Test(.enabled(if: hasVendorPPD("RICOH SP 3710DN.ppd")))
    func ricohPCLFallsBackToGenericLetter() throws {
        let c = try #require(context("RICOH SP 3710DN.ppd"))
        #expect(!available("color", c) && !available("usercode", c))
        #expect(profileID("duplex", c) == "ricoh")
        // No RIPaperPolicy on this driver: the Ricoh letter mapping doesn't fit, generic Letter does.
        #expect(profileID("letter", c) == "generic")
        #expect(try QuickAction.named("letter")!.resolve(c).get().changes == [OptionChange(key: "PageSize", value: "Letter", isSecret: false)])
    }

    @Test(.enabled(if: hasVendorPPD("RICOH IM C4500")))
    func userCodeValidationUsesThePPDLimit() throws {
        let c = try #require(context("RICOH IM C4500"))
        let action = QuickAction.named("usercode")!
        #expect(action.validationError("12345", context: c) == nil)
        #expect(action.validationError("12a", context: c) == "Digits only")
        #expect(action.validationError("123456789", context: c) == "At most 8 digits")
    }
}

@Suite struct GenericProfile {
    static let genericPPD = "/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Resources/Generic.ppd"

    @Test(.enabled(if: FileManager.default.fileExists(atPath: GenericProfile.genericPPD)))
    func genericPostScriptPPD() throws {
        let text = try String(contentsOfFile: Self.genericPPD, encoding: .isoLatin1)
        let c = DriverContext(ppd: PPD(text: text), attributes: nil)
        #expect(DriverProfiles.matching(c).map(\.id) == ["generic"])
        for id in ["duplex", "simplex", "letter"] { #expect(profileID(id, c) == "generic", "\(id)") }
        #expect(!available("color", c) && !available("bw", c) && !available("usercode", c))
        #expect(QuickAction.named("default")!.isAvailable(in: c))
    }

    @Test func ippEverywhereUsesIPPAttributes() throws {
        let attributes = IPPGroup(tag: .printerAttributes, attributes: [
            .string("printer-make-and-model", .textWithoutLanguage, ["Example Laser 5000"]),
            .string("print-color-mode-supported", .keyword, ["auto", "color", "monochrome"]),
            .string("sides-supported", .keyword, ["one-sided", "two-sided-long-edge"]),
            .string("media-supported", .keyword, ["na_letter_8.5x11in", "iso_a4_210x297mm"]),
        ])
        let c = DriverContext(ppd: nil, attributes: attributes)
        #expect(try QuickAction.named("color")!.resolve(c).get().changes == [OptionChange(key: "print-color-mode-default", value: "color", isSecret: false)])
        #expect(try QuickAction.named("duplex")!.resolve(c).get().changes == [OptionChange(key: "sides-default", value: "two-sided-long-edge", isSecret: false)])
        #expect(try QuickAction.named("letter")!.resolve(c).get().changes == [OptionChange(key: "media-default", value: "na_letter_8.5x11in", isSecret: false)])
        #expect(QuickAction.named("usercode")!.unavailableReason(in: c) == "Not available for Example Laser 5000 (no driver profile maps usercode)")

        // Grayscale-only AirPrint PPD: black & white yes, color no.
        let gray = DriverContext(ppd: PPD(text: """
        *OpenUI *ColorModel/Color Mode: PickOne
        *DefaultColorModel: Gray
        *ColorModel Gray/Grayscale: ""
        *CloseUI: *ColorModel
        """), attributes: nil)
        #expect(available("bw", gray) && !available("color", gray))
    }
}

/// Opt-in: CUPSKIT_LIVE_QUICK=<throwaway Ricoh PS queue>,<throwaway generic queue> ./test.sh
/// Changes both queues; the generic one becomes the server default and is DELETED at the end.
@Suite(.enabled(if: ProcessInfo.processInfo.environment["CUPSKIT_LIVE_QUICK"] != nil), .serialized)
struct LiveQuickActions {
    let queues = (ProcessInfo.processInfo.environment["CUPSKIT_LIVE_QUICK"] ?? "").split(separator: ",").map(String.init)

    @Test func everyActionOnRicohQueue() async throws {
        try #require(queues.count == 2)
        let client = CupsClient()
        for (id, value, clearing) in [("letter", nil, false), ("bw", nil, false), ("color", nil, false), ("usercode", "2468", false),
                                      ("usercode", nil, true), ("simplex", nil, false), ("duplex", nil, false)] as [(String, String?, Bool)] {
            let outcome = try await QuickAction.named(id)!.run(queue: queues[0], value: value, clearing: clearing, client: client)
            #expect(outcome.succeeded, "\(id): \(outcome.message ?? "")")
            #expect(outcome.profile?.id == "ricoh", "\(id)")
        }
    }

    @Test func genericQueueTestPageDefaultAndDelete() async throws {
        try #require(queues.count == 2)
        let client = CupsClient()
        let (page, jobID) = try await QueueActions.printTestPage(queue: queues[1], client: client)
        #expect(page.succeeded && jobID != nil, "\(page)")

        let letter = try await QuickAction.named("letter")!.run(queue: queues[1], client: client)
        #expect(letter.succeeded && letter.profile?.id == "generic", "\(letter.message ?? "")")
        let color = try? await QuickAction.named("usercode")!.run(queue: queues[1], value: "1", client: client)
        #expect(color == nil)   // generic PPD: no user code mapping, throws, writes nothing

        let made = try await QuickAction.named("default")!.run(queue: queues[1], client: client)
        #expect(made.succeeded, "\(made.message ?? "")")
        #expect(try await client.getDefaultPrinter() == queues[1])

        let deleted = try await QueueActions.delete(queue: queues[1], client: client)
        #expect(deleted.succeeded, "\(deleted)")
        #expect(try await client.queueExists(queues[1]) == false)
    }
}
