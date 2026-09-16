import CupsKit
import Foundation
import Testing

/// Opt-in: CUPSKIT_LIVE_JOBS=<queueA>,<queueB> ./test.sh — two throwaway, paused queues.
/// Submits /etc/hosts as jobs, drives every action, and leaves both queues paused with no active jobs.
@Suite(.enabled(if: ProcessInfo.processInfo.environment["CUPSKIT_LIVE_JOBS"] != nil), .serialized)
struct LiveQueueActions {
    let queues = (ProcessInfo.processInfo.environment["CUPSKIT_LIVE_JOBS"] ?? "").split(separator: ",").map(String.init)

    private func submit(_ queue: String) throws -> Int {
        let result = try CupsTools.run(CupsTools.lpPath, ["-d", queue, "-t", "cupskit live test", "/etc/hosts"])
        let text = String(decoding: result.standardOutput, as: UTF8.self)   // "request id is Q-123 (1 file(s))"
        guard result.succeeded, let id = text.split(separator: " ").compactMap({ $0.split(separator: "-").last.flatMap { Int($0) } }).first else {
            throw CupsAdminError.failed("lp failed: \(result.message)")
        }
        return id
    }

    @Test func jobHoldReleaseMoveCancel() async throws {
        try #require(queues.count == 2)
        let client = CupsClient()
        let id = try submit(queues[0])

        let held = await QueueActions.perform(.hold, jobIDs: [id], client: client)[id]
        #expect(held?.succeeded == true, "\(String(describing: held))")
        #expect(held?.command == "/usr/bin/lp -i \(id) -H hold")

        let released = await QueueActions.perform(.release, jobIDs: [id], client: client)[id]
        #expect(released?.succeeded == true, "\(String(describing: released))")

        let moved = await QueueActions.perform(.move(to: queues[1]), jobIDs: [id], client: client)[id]
        #expect(moved?.succeeded == true, "\(String(describing: moved))")

        let canceled = await QueueActions.perform(.cancel, jobIDs: [id], client: client)[id]
        #expect(canceled?.succeeded == true, "\(String(describing: canceled))")

        // Releasing an already-canceled job must fail, not report success.
        let bogus = await QueueActions.perform(.hold, jobIDs: [id], client: client)[id]
        #expect(bogus?.succeeded == false)
    }

    @Test func cancelAllPauseResumeAcceptReject() async throws {
        try #require(queues.count == 2)
        let client = CupsClient()
        let queue = queues[1]
        _ = try submit(queue)
        _ = try submit(queue)

        let cancelAll = try await QueueActions.perform(.cancelAllJobs, queue: queue, client: client)
        #expect(cancelAll.succeeded, "\(cancelAll)")
        #expect(try await client.getJobs(queue: queue, which: "not-completed", requested: ["job-id"]).isEmpty)

        for action in [PrinterAction.reject, .accept, .resume, .pause] {
            let outcome = try await QueueActions.perform(action, queue: queue, client: client)
            #expect(outcome.succeeded, "\(action): \(outcome)")
        }
    }
}
