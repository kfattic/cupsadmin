# CUPS Admin for macOS

A native replacement for the CUPS web interface (`http://localhost:631`) that Apple removed in macOS 27.

`cupsd`, `lpadmin`, `lpstat`, `lpoptions` and IPP Everywhere queues all still work on macOS 27 — only the browser admin page is gone. This project puts it back, twice:

- **`cupsadmin`** — a command-line tool for scripts, Mosyle/Jamf/Munki commands and quick checks.
- **CUPS Admin.app** — a native SwiftUI app that covers everything the old web pages did: printers, jobs, queue options (including per-driver options like Ricoh user codes), classes and server settings.

No third-party dependencies. Builds with the Xcode Command Line Tools alone.

> Status: the CLI is stable (1.0.x). The app is under active development — see [Releases](../../releases) for what's shipped.

## Install

Download the signed, notarized PKG from the latest [release](../../releases). It installs:

- `/usr/local/bin/cupsadmin`
- `/Applications/CUPS Admin.app` (once the app ships)

The package is payload-free and installs via a postinstall script, so it never changes the ownership of an existing `/usr/local/bin` (Homebrew on Intel Macs is safe). For Munki, use an `installs` array pointing at `/usr/local/bin/cupsadmin`; there is no payload file list to key off.

Requires macOS 14 or later. Universal (Apple silicon and Intel).

## CLI

```
cupsadmin printers               # every queue: state, reasons, accepting, shared, URI
cupsadmin printer <queue>        # one queue in detail (--all for every IPP attribute)
cupsadmin jobs [queue]           # active jobs (--completed, --all-jobs)
cupsadmin cancel <job-id>        # cancel one job
cupsadmin options <queue>        # PPD options and IPP *-default values, like lpoptions -l
cupsadmin add <queue> -v <uri> [-m everywhere | -P file.ppd] [-D desc] [-L location] [--shared] [-o k=v ...]
cupsadmin set <queue> -o k=v ... # change queue defaults, then read them back and report
cupsadmin quick <action> <queue> [value]   # task-named shortcuts, see below
```

Every run prints `started HH:MM:SS`, one status line (`OK: …` or `ERROR: …`) and `finished HH:MM:SS (total N min)` — on every exit path. Status lines go to stderr so table output pipes cleanly.

`set` is stricter than `lpadmin`: `lpadmin -o PageSzie=Letter` (misspelled) exits 0 and changes nothing; `cupsadmin set` reads the queue back afterwards and reports `NOT APPLIED` with a non-zero exit.

### Quick actions

The things admins actually do, without knowing the driver's option keywords:

```
cupsadmin quick color <queue>          # always print in color
cupsadmin quick bw <queue>             # always print black & white
cupsadmin quick usercode <queue> 12345 # set a Ricoh user code (enables it too)
cupsadmin quick duplex <queue>         # default to two-sided
cupsadmin quick simplex <queue>
cupsadmin quick letter <queue>         # Letter paper + fit to nearest size (no "prompt user" at the printer)
cupsadmin quick default <queue>        # make this the server default printer
```

Actions whose option isn't in the queue's PPD are refused with a message saying why. Because these are ordinary `lpadmin -p <queue> -o …` writes, they work in an MDM custom command exactly as they do in Terminal.

## How it works

- **Reads** go straight to cupsd over IPP, using a small hand-written IPP encoder/decoder (RFC 8010). That's the same data the web UI showed, fully typed — `printer-state-reasons`, `media-supported`, `*-default`, job state and owner — instead of parsing localized `lpstat` output.
- **Transport is the Unix socket** `/private/var/run/cupsd`, not TCP 631. On macOS 27, launchd socket-activates cupsd only on that socket, and cupsd exits after about a minute idle, so port 631 is only reachable right after something else has woken it. The socket path works cold.
- **Writes** shell out to `lpadmin`, `cupsenable`/`cupsdisable`, `cupsaccept`/`cupsreject`, `lp`, `lpmove` and `cupsctl`, then read the result back over IPP. Admin operations over raw IPP would need the same `_lpadmin` group membership anyway, and `lpadmin` already knows how to generate IPP Everywhere PPDs.
- **Options** are parsed from the queue's PPD, grouped the way the PPD groups them, with typed custom values (user codes, passcodes, numbers) handled as text and number fields. Ricoh's PS drivers are documented in `docs/ricoh-ppd-options.md`.

## Build from source

Requirements: macOS 14+, Xcode Command Line Tools (full Xcode not needed).

```
git clone https://github.com/kfattic/cupsadmin.git
cd cupsadmin
swift build
.build/debug/cupsadmin printers
```

To produce a signed, notarized package like the ones in Releases:

```
export CODESIGN_APP_IDENTITY="<SHA-1 of your Developer ID Application cert>"
export CODESIGN_PKG_IDENTITY="<SHA-1 of your Developer ID Installer cert>"
export NOTARY_PROFILE="<name from: xcrun notarytool store-credentials>"
VERSION=1.2.3 ./build.sh
```

Or put those three lines (without `export`) in a `build.env` next to `build.sh`; it's read if present and gitignored. Variables already set in the environment win.

`build.sh` builds a universal binary (per-architecture `swift build` + `lipo`), signs with the hardened runtime, builds the payload-free PKG, notarizes, staples and verifies with `spctl`. Use `./build.sh --build-only` to skip signing and notarization. Run `./test.sh` for the test suite (`CUPSKIT_LIVE_QUEUE=<throwaway queue>` enables the live tests; `CUPSKIT_LIVE_JOBS` and `CUPSKIT_LIVE_QUICK` take two throwaway queues each for the job and quick-action tests).

## Notes for admins

- Queue defaults written by `set`, `quick` and the app's Options page go into `/etc/cups/ppd/<queue>.ppd` via `lpadmin`, so they apply to every user on the Mac — the same thing the web UI's "Set Default Options" did. Per-user `~/.cups/lpoptions` overrides still win for that user's own jobs.
- PPD files are world-readable. A locked-print password or login password set as a queue default is stored in plain text; the tool warns before doing that. User codes are accounting codes, not secrets.
- New queues default to `printer-is-shared=false`. `lpadmin` defaults to shared; this tool doesn't.

## License

MIT — see `LICENSE`.

Built at Western Kentucky University by Kurt Fattic, with Claude. Not affiliated with Apple or OpenPrinting.
