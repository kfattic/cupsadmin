import Foundation
import CupsKit

// Hard rule: started/status/finished on every exit path. These go to stderr so stdout stays pipeable.

let startTime = Date()

func clock(_ date: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "HH:mm:ss"
    return f.string(from: date)
}

func printErr(_ line: String) {
    fflush(stdout)
    FileHandle.standardError.write(Data((line + "\n").utf8))
}

func finish(_ code: Int32, _ status: String) -> Never {
    printErr(status)
    let end = Date()
    let minutes = String(format: "%.1f", end.timeIntervalSince(startTime) / 60)
    printErr("finished \(clock(end)) (total \(minutes) min)")
    exit(code)
}

let usage = """
    usage: cupsadmin <command> [args]

      printers                   all queues: state, reasons, accepting, shared, device URI
      printers --rosetta         only queues whose driver filters are Intel-only or missing
      printer <queue> [--all]    one queue in detail (--all dumps every IPP attribute)
      jobs [queue] [--completed | --all-jobs]
                                 active jobs (all queues unless one is given)
      cancel <job-id>            cancel one job (123 or Queue-123)
      options <queue> [--full]   PPD options (lpoptions -l style) and IPP *-default/*-supported
      add <queue> -v <uri> [-m model | -P ppd] [-D description] [-L location] [-o key=value ...] [--shared]
                                 create, enable and accept a queue via lpadmin, then verify
                                 (not shared unless --shared)
      set <queue> [-o key=value ...] [-v uri] [-D description] [-L location] [-m model | -P ppd]
                                 change a queue via lpadmin, then show before/after
      quick                      list quick actions (task-named queue defaults)
      quick <action> <queue> [code [account] | --clear]
                                 apply one via lpadmin, then verify
      ppdreport <queue | path.ppd[.gz]>
                                 every PPD group and option: keyword, label, type, default, choices
      help                       show this help
    """

printErr("started \(clock(startTime))")

// Ctrl-C / kill still reports finished.
var signalSources: [DispatchSourceSignal] = []
for sig in [SIGINT, SIGTERM] {
    signal(sig, SIG_IGN)
    let source = DispatchSource.makeSignalSource(signal: sig, queue: .main)
    source.setEventHandler { finish(128 + sig, "ERROR: interrupted by signal \(sig)") }
    source.resume()
    signalSources.append(source)
}

func runCommand(_ args: [String]) async throws -> String {
    guard let command = args.first else { throw CupsAdminError.usage("no command given") }
    var rest = Array(args.dropFirst())
    let client = CupsClient()

    func takeFlag(_ flag: String) -> Bool {
        guard let i = rest.firstIndex(of: flag) else { return false }
        rest.remove(at: i)
        return true
    }
    func rejectUnknownFlags() throws {
        if let flag = rest.first(where: { $0.hasPrefix("-") }) {
            throw CupsAdminError.usage("unknown option \(flag) for \(command)")
        }
    }

    switch command {
    case "help", "-h", "--help":
        print(usage)
        return "OK: help"

    case "printers":
        let rosetta = takeFlag("--rosetta")
        try rejectUnknownFlags()
        guard rest.isEmpty else { throw CupsAdminError.usage("printers takes no arguments") }
        return rosetta ? try await RosettaCommand.run(client: client) : try await PrintersCommand.run(client: client)

    case "printer":
        let dumpAll = takeFlag("--all")
        try rejectUnknownFlags()
        guard rest.count == 1 else { throw CupsAdminError.usage("printer needs exactly one queue name") }
        return try await PrinterCommand.run(client: client, queue: rest[0], dumpAll: dumpAll)

    case "jobs":
        let completed = takeFlag("--completed")
        let all = takeFlag("--all-jobs")
        try rejectUnknownFlags()
        guard rest.count <= 1 else { throw CupsAdminError.usage("jobs takes at most one queue name") }
        guard !(completed && all) else { throw CupsAdminError.usage("use --completed or --all-jobs, not both") }
        let which = completed ? "completed" : all ? "all" : "not-completed"
        return try await JobsCommand.run(client: client, queue: rest.first, which: which)

    case "cancel":
        try rejectUnknownFlags()
        guard rest.count == 1 else { throw CupsAdminError.usage("cancel needs exactly one job id") }
        return try await CancelCommand.run(client: client, jobID: try CancelCommand.parseJobID(rest[0]))

    case "options":
        let full = takeFlag("--full")
        try rejectUnknownFlags()
        guard rest.count == 1 else { throw CupsAdminError.usage("options needs exactly one queue name") }
        return try await OptionsCommand.run(client: client, queue: rest[0], full: full)

    case "add":
        let shared = takeFlag("--shared")
        let (queue, spec) = try QueueSpec.parse(rest, command: command)
        return try await AddCommand.run(client: client, queue: queue, spec: spec, shared: shared)

    case "set":
        let (queue, spec) = try QueueSpec.parse(rest, command: command)
        return try await SetCommand.run(client: client, queue: queue, spec: spec)

    case "ppdreport":
        var file: String?
        if let i = rest.firstIndex(of: "--file") {
            guard i + 1 < rest.count else { throw CupsAdminError.usage("--file needs a path") }
            file = rest[i + 1]
            rest.removeSubrange(i ... i + 1)
        }
        try rejectUnknownFlags()
        guard (file == nil && rest.count == 1) || (file != nil && rest.isEmpty) else {
            throw CupsAdminError.usage("ppdreport needs one queue name or PPD file path")
        }
        // A path (anything with "/", or ending in .ppd / .gz) is a PPD file; queue names can't contain "/".
        if file == nil, let argument = rest.first, PPD.looksLikeFile(argument) {
            file = argument
            rest.removeAll()
        }
        return try await PPDReportCommand.run(client: client, queue: rest.first, file: file)

    case "quick":
        let clear = takeFlag("--clear")
        try rejectUnknownFlags()
        return try await QuickCommand.run(client: client, args: rest, clear: clear)

    default:
        throw CupsAdminError.usage("unknown command \(command)")
    }
}

do {
    let status = try await runCommand(Array(CommandLine.arguments.dropFirst()))
    finish(0, status)
} catch CupsAdminError.usage(let message) {
    printErr(usage)
    finish(2, "ERROR: \(message)")
} catch {
    finish(1, "ERROR: \(error)")
}
