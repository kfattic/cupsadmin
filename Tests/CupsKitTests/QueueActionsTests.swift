@testable import CupsKit
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

/// Delete is judged by whether the queue is gone afterwards, not by lpadmin's exit status.
@Suite struct DeleteReadBack {
    private func result(_ status: Int32, _ stderr: String = "") -> ToolResult {
        ToolResult(executable: CupsTools.lpadminPath, arguments: ["-x", "Old_Queue"], status: status,
                   standardOutput: Data(), standardError: Data(stderr.utf8))
    }

    @Test func deletedNormally() {
        let outcome = QueueActions.deleteOutcome(queue: "Old_Queue", result: result(0), stillExists: false)
        #expect(outcome == ActionOutcome(succeeded: true, command: "/usr/sbin/lpadmin -x Old_Queue", message: nil))
    }

    /// The reported bug: the queue was removed elsewhere before Delete Printer ran, lpadmin said
    /// "The printer or class does not exist", and the app showed a failure alert.
    @Test func alreadyGoneIsASuccess() {
        let outcome = QueueActions.deleteOutcome(queue: "Old_Queue",
                                                 result: result(1, "lpadmin: The printer or class does not exist."),
                                                 stillExists: false)
        #expect(outcome.succeeded)
        #expect(outcome.message == "Old_Queue was already deleted")
    }

    @Test func failureWhileQueueRemainsShowsToolOutput() {
        let outcome = QueueActions.deleteOutcome(queue: "Old_Queue", result: result(1, "lpadmin: Forbidden"), stillExists: true)
        #expect(!outcome.succeeded && outcome.message == "lpadmin: Forbidden")
    }

    @Test func exitZeroButStillThereIsNotApplied() {
        let outcome = QueueActions.deleteOutcome(queue: "Old_Queue", result: result(0), stillExists: true)
        #expect(!outcome.succeeded && outcome.message == "Not applied: Old_Queue still exists")
    }

    /// Opt-in (CUPSKIT_LIVE_DELETE=1): the real lpadmin and cupsd on a name that never existed. Writes nothing.
    @Test(.enabled(if: ProcessInfo.processInfo.environment["CUPSKIT_LIVE_DELETE"] != nil))
    func liveDeleteOfMissingQueue() async throws {
        let name = "cupsadmin_missing_\(UInt32.random(in: 0 ... .max))"
        let outcome = try await QueueActions.delete(queue: name, client: CupsClient())
        #expect(outcome.succeeded, "\(outcome)")
        #expect(outcome.message == "\(name) was already deleted")
    }
}
