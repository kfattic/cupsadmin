import Foundation
import CupsKit

/// Every OpenGroup/OpenUI in a queue's PPD, so contributors can find their driver's keywords.
enum PPDReportCommand {
    static func run(client: CupsClient, queue: String?, file: String?) async throws -> String {
        let text: String
        let source: String
        var attributes: IPPGroup?
        if let file {
            guard let data = FileManager.default.contents(atPath: file) else { throw CupsAdminError.failed("can’t read \(file)") }
            text = String(decoding: data, as: UTF8.self)
            source = file
        } else if let queue {
            guard try await client.queueExists(queue) else { throw CupsAdminError.failed("no such queue \(queue)") }
            guard let ppdText = try await client.getPPD(queue: queue) else {
                throw CupsAdminError.failed("\(queue) has no PPD (driverless or raw queue)")
            }
            text = ppdText
            source = queue
            attributes = try? await client.getPrinterAttributes(queue: queue, requested: [
                "printer-make-and-model", "print-color-mode-supported", "sides-supported", "media-supported"])
        } else {
            throw CupsAdminError.usage("ppdreport needs a queue name or --file <path.ppd>")
        }

        let ppd = PPD(text: text)
        let a = ppd.attributes
        print("PPD:          \(a["NickName"] ?? "?")")
        print("Manufacturer: \(a["Manufacturer"] ?? "?")")
        print("PCFileName:   \(a["PCFileName"] ?? "?")  version \(a["FileVersion"] ?? "?")")

        let context = DriverContext(ppd: ppd, attributes: attributes)
        let profiles = DriverProfiles.matching(context)
        print("Profiles:     \(profiles.map(\.id).joined(separator: ", "))")
        let quick = QuickAction.all.filter { !$0.isDefaultPrinter }.map { action -> String in
            action.isAvailable(in: context) ? action.id : "\(action.id) (unavailable)"
        }
        print("Quick:        \(quick.joined(separator: ", "))")

        for group in ppd.groups {
            print("\n\(group)")
            for option in ppd.options where option.group == group {
                let type = option.uiType == .unknown ? "?" : option.uiType.rawValue
                print("  \(option.keyword) — \(option.text) (\(type)\(option.isJCL ? ", JCL" : ""), default \(option.defaultChoice ?? "none"))")
                let choices = option.choiceList.map { $0.text == $0.keyword ? $0.keyword : "\($0.keyword) \"\($0.text)\"" }
                if !choices.isEmpty { print("    choices: \(choices.joined(separator: ", "))") }
                if !option.customParameters.isEmpty {
                    let params = option.customParameters.map { "\($0.name) \($0.type) \($0.minimum)–\($0.maximum)" }
                    print("    custom:  \(params.joined(separator: "; "))  (write as \(option.keyword)=Custom.<value>)")
                }
            }
        }
        return "OK: \(source) \(ppd.options.count) options in \(ppd.groups.count) groups"
    }
}
