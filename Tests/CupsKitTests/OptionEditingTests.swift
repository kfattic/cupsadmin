@testable import CupsKit
import Foundation
import Testing

/// Parser/control tests read Ricoh's vendor PPDs (read-only); each test is skipped when its PPD isn't installed.
let vendorPPDs = "/Library/Printers/PPDs/Contents/Resources/"

func vendorPPD(_ name: String) -> PPD? {
    (try? String(contentsOfFile: vendorPPDs + name, encoding: .isoLatin1)).map(PPD.init(text:))
}

func hasVendorPPD(_ name: String) -> Bool {
    FileManager.default.fileExists(atPath: vendorPPDs + name)
}

@Suite struct PPDParsing {
    @Test(.enabled(if: hasVendorPPD("RICOH IM C4500")))
    func ricohGroupsTypesAndCustomParameters() throws {
        let ppd = try #require(vendorPPD("RICOH IM C4500"))
        #expect(ppd.groups.contains("User Authentication"))
        #expect(ppd.groups.contains(PPD.generalGroup))

        let duplex = try #require(ppd.option("Duplex"))
        #expect(duplex.group == PPD.generalGroup)
        #expect(duplex.choiceList.contains(PPD.Choice(keyword: "DuplexNoTumble", text: "Long Edge")))

        let enable = try #require(ppd.option("RIEnableUserCode"))
        #expect(enable.group == "Job Log")
        #expect(enable.control == .toggle(on: "True", off: "False"))

        guard case .field(let code) = try #require(ppd.option("RIUserCode")).control else {
            Issue.record("RIUserCode should be a field"); return
        }
        #expect(code.kind == .string)
        #expect(code.maximum == 8)
        #expect(!code.isSecret)

        guard case .field(let pin) = try #require(ppd.option("RIPassword")).control else {
            Issue.record("RIPassword should be a field"); return
        }
        #expect(pin.kind == .passcode)
        #expect(pin.isSecret)
        #expect(pin.minimum == 4 && pin.maximum == 8)

        guard case .field(let loginPassword) = try #require(ppd.option("RIAuthLoginPassword")).control else {
            Issue.record("RIAuthLoginPassword should be a field"); return
        }
        #expect(loginPassword.kind == .password)

        // PageSize has a multi-parameter points custom size: stays a picker.
        guard case .picker = try #require(ppd.option("PageSize")).control else {
            Issue.record("PageSize should be a picker"); return
        }
        guard case .picker = try #require(ppd.option("ColorModel")).control else {
            Issue.record("ColorModel should be a picker"); return
        }
    }

    @Test(.enabled(if: hasVendorPPD("RICOH M C251FW.ppd")))
    func booleanWithThreeChoicesFallsBackToPicker() throws {
        let ppd = try #require(vendorPPD("RICOH M C251FW.ppd"))
        let mode = try #require(ppd.option("HQPrintMode"))
        #expect(mode.uiType == .boolean)
        #expect(mode.choices.count == 3)
        guard case .picker(let choices) = mode.control else { Issue.record("expected picker"); return }
        #expect(choices.map(\.keyword) == ["661", "662", "664"])
    }

    @Test func inlineGroupsAndJCL() {
        let ppd = PPD(text: """
        *PPD-Adobe: "4.3"
        *OpenUI *Duplex/Two-Sided: PickOne
        *DefaultDuplex: None
        *Duplex None/Off: ""
        *Duplex DuplexNoTumble/Long Edge: ""
        *CloseUI: *Duplex
        *OpenGroup: Auth/Authentication
        *OpenSubGroup: Codes/Codes
        *JCLOpenUI *JCLCode/Code: PickOne
        *DefaultJCLCode: None
        *JCLCode None/None: ""
        *JCLCloseUI: *JCLCode
        *CustomJCLCode True/Custom: ""
        *ParamCustomJCLCode Code/Account Code: 1 string 1 12
        *CloseSubGroup: Codes
        *CloseGroup: Auth
        """)
        #expect(ppd.groups == ["General", "Authentication / Codes"])
        let code = ppd.option("JCLCode")
        #expect(code?.isJCL == true)
        #expect(code?.customParameters.first?.text == "Account Code")
        #expect(code?.customChoice == "Custom.STRING")
    }
}

@Suite struct CustomValues {
    let field: CustomField = {
        let ppd = PPD(text: """
        *OpenUI *RIPassword/Password: PickOne
        *DefaultRIPassword: None
        *RIPassword None/None: ""
        *CloseUI: *RIPassword
        *CustomRIPassword True/Custom: ""
        *ParamCustomRIPassword Password: 1 passcode 4 8
        """)
        guard case .field(let f) = ppd.option("RIPassword")!.control else { fatalError() }
        return f
    }()

    @Test func prefixIsInvisible() {
        #expect(field.text(fromValue: "Custom.1234") == "1234")
        #expect(field.text(fromValue: "None") == "")
        #expect(field.value(fromText: "1234") == "Custom.1234")
        #expect(field.value(fromText: "") == "None")
    }

    @Test func passcodeValidation() {
        #expect(field.validationError("123") == "At least 4 characters")
        #expect(field.validationError("123456789") == "At most 8 characters")
        #expect(field.validationError("12a4") == "Digits only")
        #expect(field.validationError("1234") == nil)
        #expect(field.validationError("") == nil)
    }

    @Test func quotingAndMasking() {
        #expect(OptionEncoding.argument(key: "RIUserCode", value: "Custom.12345") == "RIUserCode=Custom.12345")
        #expect(OptionEncoding.argument(key: "RIAuthLoginUserNameText", value: "Custom.John Smith")
                == "RIAuthLoginUserNameText=\"Custom.John Smith\"")
        #expect(OptionEncoding.argument(key: "k", value: "a\"b") == "k=\"a\\\"b\"")
        #expect(OptionEncoding.masked("Custom.1234") == "Custom.••••")
        let command = OptionApplier.displayCommand(queue: "Q", changes: [
            OptionChange(key: "RIPassword", value: "Custom.9876", isSecret: true),
            OptionChange(key: "RIUserCode", value: "Custom.42", isSecret: false),
        ])
        #expect(command == "/usr/sbin/lpadmin -p Q -o RIPassword=Custom.•••• -o RIUserCode=Custom.42")
        #expect(!command.contains("9876"))
    }
}

@Suite struct ReadBackAndOrder {
    private func state(_ ppdText: String, attributes: [IPPAttribute] = []) -> OptionState {
        OptionState(queue: "Q", snapshot: QueueSnapshot(attributes: IPPGroup(tag: .printerAttributes, attributes: attributes),
                                                        ppd: PPD(text: ppdText)), userOptions: [:])
    }

    @Test func readBackFlagsTyposAndValuesThatDidNotStick() {
        let s = state("*OpenUI *Duplex/Duplex: PickOne\n*DefaultDuplex: None\n*Duplex None/Off: \"\"\n*CloseUI: *Duplex\n",
                      attributes: [.string("job-sheets-default", .nameWithoutLanguage, ["none", "none"])])
        #expect(OptionApplier.verify(OptionChange(key: "Duplex", value: "None", isSecret: false), state: s).applied)
        #expect(!OptionApplier.verify(OptionChange(key: "Duplex", value: "DuplexTumble", isSecret: false), state: s).applied)
        let typo = OptionApplier.verify(OptionChange(key: "Duplx", value: "None", isSecret: false), state: s)
        #expect(!typo.applied)
        #expect(typo.reason == "Not applied: Q has no option Duplx")
        #expect(OptionApplier.verify(OptionChange(key: "job-sheets-default", value: "none", isSecret: false), state: s).applied)
        #expect(OptionApplier.command(queue: "Q", changes: []).executable == "/usr/sbin/lpadmin")
    }

    @Test(.enabled(if: hasVendorPPD("RICOH IM C4500")))
    func generalBasicPaperFirstInstallableOptionsLast() throws {
        let ppdText = try #require(try? String(contentsOfFile: vendorPPDs + "RICOH IM C4500", encoding: .isoLatin1))
        let titles = state(ppdText).sections().map(\.title)
        #expect(Array(titles.prefix(3)) == ["General", "Basic", "Paper"])
        #expect(titles.last == "Installable Options")
        #expect(titles.filter { $0 == "Installable Options" }.count == 1)
    }
}

@Suite struct LpOptionsParsing {
    @Test func destLineWithQuotesAndBraces() {
        let text = """
        Default OldPrinter
        Dest Office sides=two-sided-long-edge RIAuthLoginUserNameText="Custom.My Name" PageSize={Width=100 Height=200}
        Dest Office/draft print-quality=3
        """
        let office = LpOptionsFile.options(for: "Office", in: text)
        #expect(office["sides"] == "two-sided-long-edge")
        #expect(office["RIAuthLoginUserNameText"] == "Custom.My Name")
        #expect(office["PageSize"] == "{Width=100 Height=200}")
        #expect(office["print-quality"] == nil)   // instance line ignored
        #expect(LpOptionsFile.options(for: "OldPrinter", in: text).isEmpty)
    }
}

/// Live apply + read-back through the same code path the app uses.
/// Opt-in: CUPSKIT_LIVE_QUEUE=<throwaway Ricoh queue> swift test. Restores every value it changes.
@Suite(.enabled(if: ProcessInfo.processInfo.environment["CUPSKIT_LIVE_QUEUE"] != nil))
struct LiveApply {
    // Queue defaults only: the app writes with lpadmin, never lpoptions.
    let queue = ProcessInfo.processInfo.environment["CUPSKIT_LIVE_QUEUE"] ?? ""

    @Test func queueScopeCustomCodeToggleAndIPP() async throws {
        let client = CupsClient()
        let before = try await OptionState.load(client: client, queue: queue)
        let originals = ["RIEnableUserCode", "RIUserCode", "RIAuthLoginUserNameText", "copies-default", "RIPassword"]
            .map { ($0, before.queueValue($0)) }

        let changes = [
            OptionChange(key: "RIEnableUserCode", value: "True", isSecret: false),
            OptionChange(key: "RIUserCode", value: "Custom.12345", isSecret: false),
            OptionChange(key: "RIAuthLoginUserNameText", value: "Custom.John Smith", isSecret: false),
            OptionChange(key: "RIPassword", value: "Custom.2468", isSecret: true),
            OptionChange(key: "copies-default", value: "2", isSecret: false),
            OptionChange(key: "RIUsrCode", value: "Custom.1", isSecret: false),   // typo: must fail read-back
        ]
        let (result, readBack, _) = try await OptionApplier.apply(client: client, queue: queue, changes: changes)
        #expect(result.succeeded)
        let byKey = Dictionary(uniqueKeysWithValues: readBack.map { ($0.key, $0) })
        for key in ["RIEnableUserCode", "RIUserCode", "RIAuthLoginUserNameText", "RIPassword", "copies-default"] {
            #expect(byKey[key]?.applied == true, "\(key): \(byKey[key]?.reason ?? "")")
        }
        #expect(byKey["RIUsrCode"]?.applied == false)

        let restore = originals.compactMap { key, value in value.map { OptionChange(key: key, value: $0, isSecret: false) } }
        let (_, restored, _) = try await OptionApplier.apply(client: client, queue: queue, changes: restore)
        let allRestored = restored.allSatisfy { $0.applied }
        #expect(allRestored, "\(restored.filter { !$0.applied })")
    }
}
