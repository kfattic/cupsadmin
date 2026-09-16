import CupsKit
import Foundation
import Testing

private func available(_ id: String, _ ppd: PPD?) -> Bool {
    QuickAction.named(id)!.isAvailable(for: ppd)
}

@Suite struct QuickActionAvailability {
    @Test(.enabled(if: hasVendorPPD("RICOH IM C4500")))
    func ricohPSHasEverything() throws {
        let ppd = try #require(vendorPPD("RICOH IM C4500"))
        for id in ["color", "bw", "usercode", "duplex", "simplex", "letter", "default"] {
            #expect(available(id, ppd), "\(id)")
        }
        let letter = try QuickAction.named("letter")!.changes(for: ppd).get()
        #expect(letter == [OptionChange(key: "PageSize", value: "Letter", isSecret: false),
                           OptionChange(key: "RIPaperPolicy", value: "NearestSizeAdjust", isSecret: false)])
        let code = try QuickAction.named("usercode")!.changes(for: ppd, value: "4321").get()
        #expect(code.map(\.value) == ["True", "Custom.4321"])
        let clear = try QuickAction.named("usercode")!.changes(for: ppd, value: "").get()
        #expect(clear.map(\.value) == ["False", "None"])
    }

    @Test(.enabled(if: hasVendorPPD("RICOH SP 3710DN.ppd") && hasVendorPPD("RICOH M C251FW.ppd")))
    func otherDriversOnlyGetWhatTheirPPDHas() throws {
        // SP 3710DN: mono PCL — no color option, no fit-to-paper; has Duplex.
        let sp = try #require(vendorPPD("RICOH SP 3710DN.ppd"))
        #expect(!available("color", sp) && !available("bw", sp))
        #expect(!available("letter", sp) && !available("usercode", sp))
        #expect(available("duplex", sp) && available("simplex", sp))

        // M C251FW: color via HQColorMode.
        let fw = try #require(vendorPPD("RICOH M C251FW.ppd"))
        #expect(try QuickAction.named("color")!.changes(for: fw).get() == [OptionChange(key: "HQColorMode", value: "COLOR", isSecret: false)])

        // AirPrint-generated PPD whose printer reported only grayscale: B&W yes, color no.
        let airprint = PPD(text: """
        *OpenUI *ColorModel/Color Mode: PickOne
        *DefaultColorModel: Gray
        *ColorModel Gray/Grayscale: ""
        *CloseUI: *ColorModel
        *OpenUI *PageSize/Media Size: PickOne
        *DefaultPageSize: Letter
        *PageSize Letter/US Letter: ""
        *CloseUI: *PageSize
        """)
        #expect(!available("color", airprint))
        #expect(available("bw", airprint))
        #expect(!available("duplex", airprint))
    }

    @Test func userCodeValidation() {
        let action = QuickAction.named("usercode")!
        let ppd = vendorPPD("RICOH IM C4500")
        #expect(action.validationError("12345", ppd: ppd) == nil)
        #expect(action.validationError("12a", ppd: ppd) == "Digits only")
        #expect(action.validationError("123456789", ppd: ppd) == "At most 8 digits")
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
        for (id, value) in [("letter", nil), ("bw", nil), ("color", nil), ("usercode", "2468"),
                            ("usercode", ""), ("simplex", nil), ("duplex", nil)] as [(String, String?)] {
            let outcome = try await QuickAction.named(id)!.run(queue: queues[0], value: value, client: client)
            #expect(outcome.succeeded, "\(id): \(outcome.message ?? "")")
        }
    }

    @Test func testPageDefaultAndDelete() async throws {
        try #require(queues.count == 2)
        let client = CupsClient()
        let (page, jobID) = try await QueueActions.printTestPage(queue: queues[1], client: client)
        #expect(page.succeeded && jobID != nil, "\(page)")

        let unavailable = try? await QuickAction.named("letter")!.run(queue: queues[1], client: client)
        #expect(unavailable == nil)   // generic PPD has no RIPaperPolicy: throws, writes nothing

        let made = try await QuickAction.named("default")!.run(queue: queues[1], client: client)
        #expect(made.succeeded, "\(made.message ?? "")")
        #expect(try await client.getDefaultPrinter() == queues[1])

        let deleted = try await QueueActions.delete(queue: queues[1], client: client)
        #expect(deleted.succeeded, "\(deleted)")
        #expect(try await client.queueExists(queues[1]) == false)
    }
}
