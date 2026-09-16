import Foundation
import CupsKit

extension QueueSpec {
    /// Parses `<queue> [-v uri] [-m model | -P ppd] [-D text] [-L text] [-o key=value ...]`.
    static func parse(_ args: [String], command: String) throws -> (queue: String, spec: QueueSpec) {
        var spec = QueueSpec()
        var queue: String?
        var i = 0
        func value(_ flag: String) throws -> String {
            i += 1
            guard i < args.count else { throw CupsAdminError.usage("\(flag) needs a value") }
            return args[i]
        }
        while i < args.count {
            let arg = args[i]
            switch arg {
            case "-v": spec.deviceURI = try value(arg)
            case "-m": spec.model = try value(arg)
            case "-P": spec.ppdFile = try value(arg)
            case "-D": spec.description = try value(arg)
            case "-L": spec.location = try value(arg)
            case "-o":
                let pair = try value(arg)
                guard let eq = pair.firstIndex(of: "="), eq != pair.startIndex else {
                    throw CupsAdminError.usage("-o expects key=value, got \(pair)")
                }
                spec.options.append((String(pair[..<eq]), String(pair[pair.index(after: eq)...])))
            case _ where arg.hasPrefix("-"):
                throw CupsAdminError.usage("unknown option \(arg) for \(command)")
            default:
                guard queue == nil else { throw CupsAdminError.usage("\(command) takes one queue name, got extra \(arg)") }
                queue = arg
            }
            i += 1
        }
        guard let queue else { throw CupsAdminError.usage("\(command) needs a queue name") }
        guard spec.model == nil || spec.ppdFile == nil else { throw CupsAdminError.usage("use -m or -P, not both") }
        if let ppdFile = spec.ppdFile, !FileManager.default.fileExists(atPath: ppdFile) {
            throw CupsAdminError.usage("PPD file not found: \(ppdFile)")
        }
        return (queue, spec)
    }
}

/// Echoes the command, runs it through CupsKit, and passes its output through (lpadmin warnings etc.).
func runTool(_ executable: String, _ arguments: [String]) throws -> Int32 {
    print("+ " + CupsTools.commandLine(executable, arguments))
    fflush(stdout)
    let result = try CupsTools.run(executable, arguments)
    FileHandle.standardOutput.write(result.standardOutput)
    FileHandle.standardError.write(result.standardError)
    return result.status
}

enum AddCommand {
    static func run(client: CupsClient, queue: String, spec: QueueSpec, shared: Bool) async throws -> String {
        let spec = try await QueueAdmin.prepareAdd(client: client, queue: queue, spec: spec, shared: shared)
        let status = try runTool(CupsTools.lpadminPath, QueueAdmin.addArguments(queue: queue, spec: spec))
        let after = try await QueueAdmin.confirmAdded(client: client, queue: queue, lpadminStatus: status)

        let a = after.attributes
        print("\nAdded \(queue): \(Format.printerState(a.int("printer-state"))), "
              + "accepting \(Format.yesNo(a.bool("printer-is-accepting-jobs"))), "
              + "model \(a.string("printer-make-and-model") ?? "-")")

        let settings = after.settings(for: spec)
        let failed = settings.filter { !$0.applied }
        if !settings.isEmpty {
            printTable(headers: ["SETTING", "SOURCE", "VALUE", "RESULT"], rows: settings.map {
                [$0.name, $0.source, $0.value ?? "-", $0.applied ? "ok" : "NOT APPLIED (wanted \($0.wanted))"]
            })
        }
        guard failed.isEmpty else {
            throw CupsAdminError.failed("added \(queue), but \(failed.count) setting(s) not applied: "
                                        + failed.map(\.name).joined(separator: ", "))
        }
        return "OK: added \(queue), \(settings.count) setting(s) verified"
    }
}

enum SetCommand {
    static func run(client: CupsClient, queue: String, spec: QueueSpec) async throws -> String {
        let before = try await QueueAdmin.prepareSet(client: client, queue: queue, spec: spec)
        let status = try runTool(CupsTools.lpadminPath, spec.lpadminArguments(queue: queue))
        let after = try await QueueAdmin.confirmSet(client: client, queue: queue, spec: spec, lpadminStatus: status)

        print()
        let rows = zip(before, after).map { b, a -> [String] in
            [a.name, a.source, b.value ?? "-", a.value ?? "-", a.applied ? "ok" : "NOT APPLIED (wanted \(a.wanted))"]
        }
        printTable(headers: ["SETTING", "SOURCE", "BEFORE", "AFTER", "RESULT"], rows: rows)
        if spec.model != nil || spec.ppdFile != nil {
            print("(driver changed; see `cupsadmin printer \(queue)` for make-and-model)")
        }

        let failed = after.filter { !$0.applied }
        guard failed.isEmpty else {
            throw CupsAdminError.failed("lpadmin exited 0 but \(failed.count) setting(s) not applied: "
                                        + failed.map(\.name).joined(separator: ", "))
        }
        return "OK: \(queue) \(after.count) setting(s) changed and verified"
    }
}
