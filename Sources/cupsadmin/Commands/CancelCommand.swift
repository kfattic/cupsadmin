import Foundation
import CupsKit

enum CancelCommand {
    /// Accepts a bare job id ("123") or lpstat's "Queue-123" form.
    static func parseJobID(_ argument: String) throws -> Int {
        let digits = argument.split(separator: "-").last.map(String.init) ?? argument
        guard let id = Int(digits), id > 0 else {
            throw CupsAdminError.usage("cancel needs a job id like 123 or Queue-123, got \(argument)")
        }
        return id
    }

    static func run(client: CupsClient, jobID: Int) async throws -> String {
        let requested = ["job-id", "job-name", "job-printer-uri", "job-originating-user-name", "job-state"]
        let job: IPPGroup
        do {
            job = try await client.getJobAttributes(jobID: jobID, requested: requested)
        } catch CupsAdminError.ipp(let status, _) where status == IPPStatus.notFound {
            throw CupsAdminError.failed("no such job \(jobID)")
        }

        let queue = JobsCommand.queueName(job) ?? "?"
        let name = job.string("job-name") ?? "-"
        let owner = job.string("job-originating-user-name") ?? "-"
        print("Job \(jobID) on \(queue): \"\(name)\" by \(owner), \(Format.jobState(job.int("job-state")))")

        try await client.cancelJob(jobID: jobID)

        // Read back rather than trusting the successful status.
        let after = try? await client.getJobAttributes(jobID: jobID, requested: ["job-state"])
        let state = Format.jobState(after?.int("job-state"))
        print("Now: \(after == nil ? "gone from job history" : state)")
        return "OK: canceled job \(jobID) on \(queue)"
    }
}
