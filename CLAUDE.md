# cupsadmin

A native replacement for the CUPS web interface (`http://localhost:631`) that Apple removed in
macOS 27. `cupsd`, `lpadmin`, `lpstat`, `lpoptions` and IPP Everywhere queues still work; only the
browser admin pages are gone. Two front ends share one library:

- **CupsKit** (`Sources/CupsKit`) — IPP client, PPD parser, CUPS tool wrappers, read-back checks.
  Pure logic: returns values or throws, never prints.
- **`cupsadmin`** (`Sources/cupsadmin`) — the CLI, a thin layer over CupsKit.
- **CUPS Admin.app** (`Sources/CUPSAdminApp`) — the SwiftUI app. The target is `CUPSAdminApp`, not
  `CUPSAdmin`: APFS is case-insensitive, so `Sources/CUPSAdmin` is the same folder as `Sources/cupsadmin`
  and the two executables would collide in `.build/`.

Private maintainer notes, if present, are in `CLAUDE.local.md` (gitignored).

## Architecture
- **Reads are IPP** with a small hand-written encoder/decoder (RFC 8010, `CupsKit/IPP`):
  CUPS-Get-Printers, Get-Printer-Attributes, Get-Jobs, Get-Job-Attributes, Cancel-Job,
  CUPS-Get-Default. This gives typed data (state reasons, `*-default`, `*-supported`, job state)
  instead of localized `lpstat` text.
- **Transport is the Unix socket `/private/var/run/cupsd`, not TCP 631.** On macOS 27 launchd
  socket-activates cupsd only on that socket; cupsd binds port 631 itself while running and exits
  after about a minute idle, so TCP fails whenever it's asleep. URLSession can't use AF_UNIX, so
  `UnixSocketHTTP.swift` speaks minimal HTTP/1.1 over POSIX sockets. PPDs are fetched the same way
  (`GET /printers/<queue>.ppd`).
- **Writes shell out** through `CupsTools`: `lpadmin`, `cupsenable`/`cupsdisable`,
  `cupsaccept`/`cupsreject`, `cancel`, `lp`, `lpmove`, `lpinfo`. `lpadmin` already handles
  `_lpadmin` authorization and IPP Everywhere PPD generation.
- **Queue defaults are written with `lpadmin -p <queue> -o key=value`** (into the queue's PPD /
  printers.conf, for every user) — never `lpoptions`. `~/.cups/lpoptions` is only read, to point out
  a per-user override.
- **PPD options** keep their `*OpenGroup`, UI type and `*ParamCustom` type/range. Custom values are
  written as `Custom.<value>` and quoted when they contain spaces (unquoted, `lpadmin` silently truncates).
- **Quick actions** are vendor-neutral. `QuickActions.swift` defines the actions; what each writes comes
  from `Resources/driver-profiles.json` (embedded in code — the CLI is a single binary), matched on the
  PPD's `*Manufacturer`/`*NickName`, vendor profiles first and `generic` (standard PPD keywords, IPP
  Everywhere `*-default` attributes) last. A pair is used only if that queue supports the keyword and
  value; otherwise the action is unavailable with the reason. `cupsadmin ppdreport <queue>` shows a
  driver's keywords and which actions its profile enables.

## Build and test
```
swift build                          # debug build of everything
.build/debug/cupsadmin printers      # run the CLI
./test.sh                            # Swift Testing via the Command Line Tools (see flags inside)
./build.sh --build-only              # universal CLI + app bundle, ad-hoc signed, no identities needed
./build.sh --screenshots             # regenerate docs/screenshots/app-jobs.png from temporary demo queues
./build.sh                           # release: sign, payload-free PKG, notarize, staple, spctl
```
- Only the Command Line Tools are required. Universal builds are per-triple
  (`swift build -c release --triple arm64-apple-macosx14.0` and `x86_64-…`) plus `lipo`;
  `--arch arm64 --arch x86_64` needs full Xcode.
- Package: tools-version 6.0, Swift 5 language mode, macOS 14 minimum.
- `build.sh` reads `CODESIGN_APP_IDENTITY`, `CODESIGN_PKG_IDENTITY`, `NOTARY_PROFILE` (and optional
  `CODESIGN_TEAM_ID`) from the environment or an untracked `build.env`. Never hard-code identities.
- The PKG is payload-free (`pkgbuild --nopayload --scripts`): `pkg/postinstall` installs the CLI to
  `/usr/local/bin` and the notarized, stapled app to `/Applications`. A payload's "." entry is recorded as
  root:wheel for its install location, which would reset an existing `/usr/local/bin` (Homebrew) or
  `/Applications` (root:admin 775). The app is notarized and stapled before packaging; the PKG after.
- The app icon master is `Icon/AppIcon-1024.png`; `build.sh` generates `AppIcon.icns` from it. Don't redraw it.
- Live tests are opt-in and write to queues: `CUPSKIT_LIVE_QUEUE=<queue>`, `CUPSKIT_LIVE_JOBS=<a>,<b>`,
  `CUPSKIT_LIVE_QUICK=<ricoh>,<generic>`. Use throwaway queues (e.g. `lpd://127.0.0.1/…`, paused) and
  delete them afterwards; the live tests restore what they change. Offline tests use vendor PPDs from
  `/Library/Printers/PPDs` and skip when they aren't installed.

## Conventions
- **US spelling everywhere** — code, UI, CLI output, docs (color, canceled, gray).
- **No third-party dependencies.** No Xcode project.
- **CLI status lines on every exit path:** `started HH:MM:SS`, exactly one `OK: …` or `ERROR: …`, and
  `finished HH:MM:SS (total N min)` — on stderr, so tables on stdout pipe cleanly. Exit 0 success,
  1 runtime error or not applied, 2 usage error. Existing command output is a contract: don't change it
  casually. Scripts (`build.sh`, `test.sh`) print the same started/finished lines.
- **Read back after every write.** Re-query cupsd and compare; a change that didn't take is reported
  (`NOT APPLIED`, non-zero exit, or a red X with the reason) — never silent.
- **App feedback:** every action updates the bottom status line with its timing ("Set 3 options on
  Office in 0.4 s", "ERROR: …") and logs the same through `os_log` (subsystem `edu.wku.cupsadmin.app`).
  Failures show the tool output and, for permission errors, the `_lpadmin` fix. The exact command is
  visible before it runs. Destructive actions confirm and name the object.
- **Secrets:** passcode/password options written as queue defaults land in a world-readable PPD — warn,
  and mask them in displayed commands. Never commit `build.env`, `dist/`, notary output or `CLAUDE.local.md`.
- **Native SwiftUI and macOS idioms only:** `NavigationSplitView`, sortable/resizable `Table`,
  `Form` with `.formStyle(.grouped)`, standard sheets, alerts and confirmation dialogs, SF Symbols,
  system fonts, semantic colors (`.primary`, `.secondary`, `.green`/`.blue`/`.red` state dots),
  `ContentUnavailableView` empty states. No custom chrome, no web-style cards, no emoji. Must look right
  in light and dark mode. Tables and text are selectable and copyable.
