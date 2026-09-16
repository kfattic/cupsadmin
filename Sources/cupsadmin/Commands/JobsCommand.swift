import Foundation
import CupsKit

enum JobsCommand {
    static func run(client: CupsClient, queue: String?, which: String) async throws -> String {
        let jobs = try await client.getJobs(queue: queue, which: which, requested: [
            "job-id", "job-name", "job-originating-user-name", "job-printer-uri", "job-state",
            "job-state-reasons", "job-k-octets", "time-at-creation",
        ])
        let rows = jobs.sorted { ($0.int("job-id") ?? 0) < ($1.int("job-id") ?? 0) }.map { j -> [String] in
            let jobQueue = queueName(j)
            return [
                j.int("job-id").map(String.init) ?? "?",
                jobQueue ?? queue ?? "?",
                j.string("job-originating-user-name") ?? "-",
                Format.jobState(j.int("job-state")),
                Format.kilobytes(j.int("job-k-octets")),
                Format.epoch(j.int("time-at-creation")),
                Format.reasons(j.strings("job-state-reasons")),
                j.string("job-name") ?? "-",
            ]
        }

        let scope = queue.map { " on \($0)" } ?? ""
        let label = which == "not-completed" ? "active" : which
        if rows.isEmpty {
            print("No \(label) jobs\(scope).")
        } else {
            printTable(headers: ["ID", "QUEUE", "OWNER", "STATE", "SIZE", "SUBMITTED", "REASONS", "NAME"], rows: rows)
        }
        return "OK: \(rows.count) \(label) job\(rows.count == 1 ? "" : "s")\(scope)"
    }

    /// Queue name from job-printer-uri (ipp://host/printers/NAME).
    static func queueName(_ job: IPPGroup) -> String? {
        guard let uri = job.string("job-printer-uri"), let last = uri.split(separator: "/").last else { return nil }
        return last.removingPercentEncoding ?? String(last)
    }
}
