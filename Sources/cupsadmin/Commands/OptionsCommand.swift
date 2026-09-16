import Foundation
import CupsKit

enum OptionsCommand {
    /// Queue-level settings lpadmin -o can change that aren't named *-default.
    static let policyAttributes = ["printer-error-policy", "printer-op-policy", "printer-is-shared",
                                   "port-monitor", "job-quota-period", "job-k-limit", "job-page-limit"]

    static func run(client: CupsClient, queue: String, full: Bool) async throws -> String {
        let attributes = try await client.getPrinterAttributes(queue: queue, requested: ["all"])
        let ppd = try await client.getPPD(queue: queue).map(PPD.init(text:))

        if let ppd {
            let a = ppd.attributes
            let details = [a["Manufacturer"], a["PCFileName"], a["FileVersion"].map { "version \($0)" }]
                .compactMap { $0 }.joined(separator: ", ")
            print("PPD: \(a["NickName"] ?? "?")" + (details.isEmpty ? "" : " (\(details))"))
            print("PPD options (* = queue default; per-user lpoptions overrides not applied):")
            for option in ppd.options {
                let choices = option.choices.map { $0 == option.defaultChoice ? "*\($0)" : $0 }
                    + [option.customChoice].compactMap { $0 }
                var line = choices.joined(separator: " ")
                if option.choices.isEmpty, let d = option.defaultChoice { line = "*\(d)" }
                print("  \(option.keyword)/\(option.text): \(line)")
            }
        } else {
            print("PPD: none (raw queue, or cupsd could not provide one)")
        }

        let defaultNames = attributes.attributes.map(\.name).filter { $0.hasSuffix("-default") }.sorted()
        let names = defaultNames + policyAttributes.filter { attributes[$0] != nil }
        let rows = names.map { name -> [String] in
            let base = name.hasSuffix("-default") ? String(name.dropLast("-default".count)) : name
            return [name,
                    cell(attributes[name], full: full),
                    cell(attributes[base + "-supported"], full: full)]
        }
        print("\nIPP defaults and queue policy:")
        printTable(headers: ["  ATTRIBUTE", "DEFAULT", "SUPPORTED"], rows: rows.map { ["  " + $0[0]] + $0.dropFirst() })
        if !full { print("\n(long lists truncated; use --full)") }

        return "OK: \(queue) \(ppd?.options.count ?? 0) PPD options, \(rows.count) IPP defaults/policies"
    }

    private static func cell(_ attribute: IPPAttribute?, full: Bool) -> String {
        guard let attribute else { return "-" }
        var values = attribute.values.map { Format.value($0, attribute: attribute.name) }
        if !full, values.count > 8 {
            values = Array(values.prefix(8)) + ["… (+\(attribute.values.count - 8) more)"]
        }
        let text = values.joined(separator: ", ")
        return !full && text.count > 100 ? String(text.prefix(99)) + "…" : text
    }
}
