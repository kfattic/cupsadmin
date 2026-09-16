import Foundation
import CupsKit

enum PrintersCommand {
    static func run(client: CupsClient) async throws -> String {
        let printers = try await client.getPrinters(requested: [
            "printer-name", "printer-type", "printer-state", "printer-state-reasons",
            "printer-is-accepting-jobs", "printer-is-shared", "queued-job-count", "device-uri",
        ])
        let sorted = printers.sorted {
            ($0.string("printer-name") ?? "").localizedStandardCompare($1.string("printer-name") ?? "") == .orderedAscending
        }
        let rows = sorted.map { p -> [String] in
            [
                p.string("printer-name") ?? "?",
                PrinterType.kind(p.int("printer-type")),
                Format.printerState(p.int("printer-state")),
                Format.yesNo(p.bool("printer-is-accepting-jobs")),
                Format.yesNo(p.bool("printer-is-shared")),
                p.int("queued-job-count").map(String.init) ?? "-",
                Format.reasons(p.strings("printer-state-reasons")),
                p.string("device-uri") ?? "-",
            ]
        }
        if rows.isEmpty {
            print("No queues.")
        } else {
            printTable(headers: ["QUEUE", "KIND", "STATE", "ACCEPTING", "SHARED", "JOBS", "REASONS", "DEVICE URI"],
                       rows: rows)
        }

        let classes = sorted.filter { ($0.int("printer-type") ?? 0) & PrinterType.isClass != 0 }.count
        let problems = sorted.filter {
            $0.int("printer-state") == 5 || $0.bool("printer-is-accepting-jobs") == false
        }.count
        var status = "OK: \(sorted.count - classes) printers"
        if classes > 0 { status += ", \(classes) class\(classes == 1 ? "" : "es")" }
        if problems > 0 { status += ", \(problems) stopped or rejecting" }
        return status
    }
}

enum PrinterCommand {
    static func run(client: CupsClient, queue: String, dumpAll: Bool) async throws -> String {
        // "all" in CUPS excludes a few expensive attributes (e.g. media-col-database), which is what we want.
        let p = try await client.getPrinterAttributes(queue: queue, requested: ["all"])

        if dumpAll {
            let width = min(p.attributes.map(\.name.count).max() ?? 0, 40)
            for attribute in p.attributes.sorted(by: { $0.name < $1.name }) {
                let values = attribute.values.map { Format.value($0, attribute: attribute.name) }
                let pad = String(repeating: " ", count: max(0, width - attribute.name.count))
                print("\(attribute.name)\(pad)  \(values.joined(separator: ", "))")
            }
            return "OK: \(queue) \(Format.printerState(p.int("printer-state"))), \(p.attributes.count) attributes"
        }

        let type = p.int("printer-type")
        var lines: [(String, String)] = [
            ("Queue", p.string("printer-name") ?? queue),
            ("Description", p.string("printer-info") ?? "-"),
            ("Location", p.string("printer-location") ?? "-"),
            ("Make and model", p.string("printer-make-and-model") ?? "-"),
            ("Kind", PrinterType.kind(type)),
        ]
        if (type ?? 0) & PrinterType.isClass != 0 {
            lines.append(("Members", p.strings("member-names").joined(separator: ", ")))
        }
        let stateMessage = p.string("printer-state-message") ?? ""
        lines += [
            ("Device URI", p.string("device-uri") ?? "-"),
            ("Printer URI", p.strings("printer-uri-supported").first ?? "-"),
            ("State", Format.printerState(p.int("printer-state")) + (stateMessage.isEmpty ? "" : " — \(stateMessage)")),
            ("State reasons", Format.reasons(p.strings("printer-state-reasons"))),
            ("State changed", Format.epoch(p.int("printer-state-change-time"))),
            ("Accepting jobs", Format.yesNo(p.bool("printer-is-accepting-jobs"))),
            ("Shared", Format.yesNo(p.bool("printer-is-shared"))),
            ("Queued jobs", p.int("queued-job-count").map(String.init) ?? "-"),
            ("Capabilities", PrinterType.capabilities(type)),
        ]

        let defaults = ["media-default", "sides-default", "print-color-mode-default", "print-quality-default",
                        "output-bin-default", "copies-default", "job-sheets-default", "printer-error-policy",
                        "printer-op-policy"]
        for name in defaults {
            guard let attribute = p[name] else { continue }
            lines.append((name, attribute.values.map { Format.value($0, attribute: name) }.joined(separator: ", ")))
        }

        let markerNames = p.strings("marker-names")
        let markerLevels = p.ints("marker-levels")
        for (i, marker) in markerNames.enumerated() {
            let level = i < markerLevels.count ? markerLevels[i] : -1
            lines.append((i == 0 ? "Supplies" : "", "\(marker): " + (level >= 0 ? "\(level)%" : "unknown")))
        }

        let width = lines.map(\.0.count).max() ?? 0
        for (label, value) in lines {
            let heading = label.isEmpty ? String(repeating: " ", count: width + 1)
                                        : label + ":" + String(repeating: " ", count: width - label.count)
            print("\(heading)  \(value)")
        }
        if let ppdText = try? await client.getPPD(queue: queue),
           let warning = DriverFilterCheck.check(PPD(text: ppdText)).warning {
            print("\nWARNING: \(warning)")
        }
        print("\n(use --all for every attribute)")

        return "OK: \(queue) \(Format.printerState(p.int("printer-state"))), reasons \(Format.reasons(p.strings("printer-state-reasons")))"
    }
}

/// `printers --rosetta`: queues whose PPD filters have no arm64 slice or don't exist.
enum RosettaCommand {
    static func run(client: CupsClient) async throws -> String {
        let printers = try await client.getPrinters(requested: ["printer-name"])
        let names = printers.compactMap { $0.string("printer-name") }
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }

        var rows: [[String]] = []
        var affected = 0
        for name in names {
            guard let text = try await client.getPPD(queue: name) else { continue }
            let report = DriverFilterCheck.check(PPD(text: text))
            guard report.isFlagged else { continue }
            affected += 1
            let flagged = report.missing + report.intelOnly
            for (i, filter) in flagged.enumerated() {
                let what: String
                switch filter.status {
                case .intelOnly(let archs): what = archs.joined(separator: " ")
                case .missing: what = "missing"
                default: what = ""
                }
                rows.append([i == 0 ? name : "", i == 0 ? (report.headline ?? "") : "", what, filter.path ?? filter.program])
            }
        }

        let host = DriverFilterCheck.hostIsAppleSilicon
            ? "Apple silicon, Rosetta \(DriverFilterCheck.rosettaInstalled ? "installed" : "NOT installed")"
            : "Intel Mac (Intel-only filters run natively here)"
        if rows.isEmpty {
            print("No queues need Rosetta or have missing driver filters. This Mac: \(host).")
            return "OK: none of \(names.count) queues need Rosetta or have missing filters"
        }
        printTable(headers: ["QUEUE", "PROBLEM", "ARCH", "FILTER"], rows: rows)
        print("\nThis Mac: \(host).")
        return "OK: \(affected) of \(names.count) queues need Rosetta or have missing filters"
    }
}
