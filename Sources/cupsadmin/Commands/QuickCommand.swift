import Foundation
import CupsKit

enum QuickCommand {
    static func run(client: CupsClient, args: [String], clear: Bool) async throws -> String {
        guard let name = args.first else {
            printTable(headers: ["ACTION", "VALUE", "WHAT IT SETS"], rows: QuickAction.all.map {
                [$0.id, $0.input == .userCode ? "<code> | --clear" : "", $0.summary]
            })
            print("\nDriver profiles (first match wins, generic last): "
                  + DriverProfiles.builtIn.map(\.id).joined(separator: ", "))
            print("See what a queue's driver offers: cupsadmin ppdreport <queue>")
            return "OK: \(QuickAction.all.count) quick actions, \(DriverProfiles.builtIn.count) driver profiles"
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
                value = nil
            } else {
                guard args.count == 3 else { throw CupsAdminError.usage("quick \(name) needs a code (digits) or --clear") }
                value = args[2]
            }
        }
        guard try await client.queueExists(queue) else { throw CupsAdminError.failed("no such queue \(queue)") }

        if action.isDefaultPrinter {
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
        let context = DriverContext(ppd: before.ppd, attributes: before.snapshot.attributes)
        if let value, let error = action.validationError(value, context: context) {
            throw CupsAdminError.usage("user code \(value): \(error)")
        }
        let resolved: ResolvedQuickAction
        switch action.resolve(context, value: value, clearing: clear) {
        case .success(let r): resolved = r
        case .failure(let unavailable): throw CupsAdminError.failed("\(action.id) on \(queue): \(unavailable.reason)")
        }
        print("driver: \(context.driverName) · profile: \(resolved.profile.id)")

        let (executable, arguments) = OptionApplier.command(queue: queue, changes: resolved.changes)
        let status = try runTool(executable, arguments)
        guard status == 0 else { throw CupsAdminError.failed("lpadmin exited \(status); nothing verified") }
        let after = try await OptionState.load(client: client, queue: queue)
        let checks = resolved.changes.map { OptionApplier.verify($0, state: after) }

        print()
        printTable(headers: ["SETTING", "BEFORE", "AFTER", "RESULT"], rows: zip(resolved.changes, checks).map { change, check in
            [change.key, before.queueValue(change.key) ?? "-", after.queueValue(change.key) ?? "-",
             check.applied ? "ok" : "NOT APPLIED (wanted \(change.value))"]
        })
        let failed = checks.filter { !$0.applied }
        guard failed.isEmpty else {
            throw CupsAdminError.failed("lpadmin exited 0 but \(failed.count) setting(s) not applied: "
                                        + failed.map(\.key).joined(separator: ", "))
        }
        return "OK: \(queue) \(action.id) applied (\(resolved.profile.id)), \(resolved.changes.count) setting(s) verified"
    }
}
