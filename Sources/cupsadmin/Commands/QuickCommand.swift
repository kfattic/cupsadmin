import Foundation
import CupsKit

enum QuickCommand {
    static func run(client: CupsClient, args: [String], clear: Bool) async throws -> String {
        guard let name = args.first else {
            printTable(headers: ["ACTION", "VALUE", "WHAT IT SETS"], rows: QuickAction.all.map {
                [$0.id, $0.input == .userCode ? "<code> | --clear" : "", $0.summary]
            })
            return "OK: \(QuickAction.all.count) quick actions"
        }
        guard let action = QuickAction.named(name) else {
            throw CupsAdminError.usage("unknown quick action \(name) (one of: \(QuickAction.all.map(\.id).joined(separator: ", ")))")
        }
        guard args.count >= 2 else { throw CupsAdminError.usage("quick \(name) needs a queue name") }
        let queue = args[1]
        let value: String?
        switch action.input {
        case .none:
            guard args.count == 2, !clear else { throw CupsAdminError.usage("quick \(name) takes only a queue name") }
            value = nil
        case .userCode:
            if clear {
                guard args.count == 2 else { throw CupsAdminError.usage("use a code or --clear, not both") }
                value = ""
            } else {
                guard args.count == 3 else { throw CupsAdminError.usage("quick \(name) needs a code (digits) or --clear") }
                value = args[2]
            }
        }
        guard try await client.queueExists(queue) else { throw CupsAdminError.failed("no such queue \(queue)") }

        if case .defaultPrinter = action.effect {
            let before = try await client.getDefaultPrinter()
            let status = try runTool(CupsTools.lpadminPath, ["-d", queue])
            guard status == 0 else { throw CupsAdminError.failed("lpadmin exited \(status); default not changed") }
            let after = try await client.getDefaultPrinter()
            print()
            printTable(headers: ["SETTING", "BEFORE", "AFTER", "RESULT"],
                       rows: [["server default", before ?? "none", after ?? "none", after == queue ? "ok" : "NOT APPLIED (wanted \(queue))"]])
            guard after == queue else { throw CupsAdminError.failed("lpadmin exited 0 but the server default is \(after ?? "none")") }
            return "OK: \(queue) is the server default printer"
        }

        let before = try await OptionState.load(client: client, queue: queue)
        if let value, let error = action.validationError(value, ppd: before.ppd) {
            throw CupsAdminError.usage("user code \(value): \(error)")
        }
        let changes: [OptionChange]
        switch action.changes(for: before.ppd, value: value) {
        case .success(let resolved): changes = resolved
        case .failure(let unavailable): throw CupsAdminError.failed("\(action.id) isn’t available on \(queue): \(unavailable.reason)")
        }

        let (executable, arguments) = OptionApplier.command(queue: queue, changes: changes)
        let status = try runTool(executable, arguments)
        guard status == 0 else { throw CupsAdminError.failed("lpadmin exited \(status); nothing verified") }
        let after = try await OptionState.load(client: client, queue: queue)
        let checks = changes.map { OptionApplier.verify($0, state: after) }

        print()
        printTable(headers: ["SETTING", "BEFORE", "AFTER", "RESULT"], rows: zip(changes, checks).map { change, check in
            [change.key, before.queueValue(change.key) ?? "-", after.queueValue(change.key) ?? "-",
             check.applied ? "ok" : "NOT APPLIED (wanted \(change.value))"]
        })
        let failed = checks.filter { !$0.applied }
        guard failed.isEmpty else {
            throw CupsAdminError.failed("lpadmin exited 0 but \(failed.count) setting(s) not applied: "
                                        + failed.map(\.key).joined(separator: ", "))
        }
        return "OK: \(queue) \(action.id) applied, \(changes.count) setting(s) verified"
    }
}
