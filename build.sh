#!/bin/bash
# Universal release build -> signed CLI + signed, notarized, stapled "CUPS Admin.app" -> signed PKG
# (payload: /Applications/CUPS Admin.app; postinstall: /usr/local/bin/cupsadmin) -> notarize -> staple -> spctl.
# The pkg step needs admin rights once (sudo in Terminal, or an administrator password dialog) to make the
# staging Applications folder root:admin 775 so the package records the system's real ownership.
# Usage: ./build.sh               full pipeline (VERSION=1.2.0 ./build.sh to set the version)
#        ./build.sh --build-only  build CLI and app, ad-hoc signed; no identities, no pkg, no notarization
#        ./build.sh --screenshots build like --build-only, then regenerate docs/screenshots/app-jobs.png and
#                                 app-options.png (creates four demo queues on 127.0.0.1 — one on Ricoh's
#                                 IM C4500 PPD — with held jobs, and deletes them after)
#
# Signing settings come from the environment, or from an untracked build.env next to this script
# (plain KEY=value lines; a variable already set in the environment wins):
#   CODESIGN_APP_IDENTITY  SHA-1 of your "Developer ID Application" certificate
#   CODESIGN_PKG_IDENTITY  SHA-1 of your "Developer ID Installer" certificate
#   NOTARY_PROFILE         keychain profile from `xcrun notarytool store-credentials`
#   CODESIGN_TEAM_ID       optional: fail if the signatures aren't from this team
set -euo pipefail

BUILD_ONLY=0
SCREENSHOTS=0
for arg in "$@"; do
    case "$arg" in
        --build-only) BUILD_ONLY=1 ;;
        --screenshots) BUILD_ONLY=1; SCREENSHOTS=1 ;;
        *) echo "started $(date +%H:%M:%S)"; echo "ERROR: unknown argument $arg (use --build-only or --screenshots)"
           echo "finished $(date +%H:%M:%S) (total 0.0 min)"; exit 2 ;;
    esac
done

START_EPOCH=$(date +%s)
echo "started $(date +%H:%M:%S)"
STATUS="ERROR: build.sh exited unexpectedly"

finish() {
    local rc=$?
    [ "$SCREENSHOTS" -eq 1 ] && cleanup_screenshots
    if [ $rc -ne 0 ] && [ "${STATUS#OK}" != "$STATUS" ]; then STATUS="ERROR: exit $rc"; fi
    echo "$STATUS"
    echo "finished $(date +%H:%M:%S) (total $(awk -v s="$(( $(date +%s) - START_EPOCH ))" 'BEGIN{printf "%.1f", s/60}') min)"
}
trap finish EXIT
trap 'STATUS="ERROR: interrupted"; exit 130' INT TERM

step() { STATUS="ERROR: failed at: $1"; echo; echo "==> $1"; }

# --- screenshots (--screenshots) ------------------------------------------------
# Demo queues with generic names so the README never shows real queue names or users.
DEMO_QUEUES="Copy_Room Front_Office Library_Color Lab_Mono"
SHOT_JOBS="docs/screenshots/app-jobs.png"
SHOT_OPTIONS="docs/screenshots/app-options.png"
RICOH_DEMO_PPD="/Library/Printers/PPDs/Contents/Resources/RICOH IM C4500"
APP_DOMAIN="edu.wku.cupsadmin.app"
SAVED_PREFS=""

cleanup_screenshots() {
    osascript -e 'quit app "CUPS Admin"' >/dev/null 2>&1 || true
    for _ in 1 2 3 4 5; do pgrep -f "CUPS Admin.app/Contents/MacOS" >/dev/null || break; sleep 1; done
    pkill -f "CUPS Admin.app/Contents/MacOS" 2>/dev/null || true
    for queue in $DEMO_QUEUES; do lpadmin -x "$queue" 2>/dev/null || true; done
    if [ -n "$SAVED_PREFS" ] && [ -f "$SAVED_PREFS" ]; then
        defaults delete "$APP_DOMAIN" 2>/dev/null || true
        defaults import "$APP_DOMAIN" "$SAVED_PREFS" && rm -f "$SAVED_PREFS"
        SAVED_PREFS=""
    fi
}

# capture_app <queue> <tab> <file>: launch the app on one queue and tab, capture its window.
capture_app() {
    local queue="$1" tab="$2" file="$3" window="" finder
    osascript -e 'quit app "CUPS Admin"' >/dev/null 2>&1 || true
    for _ in 1 2 3 4 5; do pgrep -f "CUPS Admin.app/Contents/MacOS" >/dev/null || break; sleep 1; done
    defaults write "$APP_DOMAIN" selectedQueue "$queue"
    defaults write "$APP_DOMAIN" detailTab "$tab"
    defaults write "$APP_DOMAIN" "NSWindow Frame main" "120 120 1400 860 $SCREEN "
    open "$APP" --args --only-queues "${DEMO_QUEUES// /,}"

    finder=$(mktemp -t cupsadmin-window).swift
    cat > "$finder" <<'SWIFT'
import CoreGraphics
let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
if let w = windows.first(where: { ($0[kCGWindowOwnerName as String] as? String) == "CUPS Admin" && ($0[kCGWindowLayer as String] as? Int) == 0 }),
   let id = w[kCGWindowNumber as String] as? Int { print(id) }
SWIFT
    for _ in $(seq 1 30); do window=$(swift "$finder" 2>/dev/null || true); [ -n "$window" ] && break; sleep 1; done
    rm -f "$finder"
    [ -n "$window" ] || { STATUS="ERROR: CUPS Admin window didn't appear on this Space"; exit 1; }
    sleep 3   # let the sidebar, header and tab content load
    # Capture it as the active window (colored traffic lights, accent-colored selection).
    osascript -e "tell application id \"$APP_DOMAIN\" to activate" >/dev/null 2>&1 || true
    open "$APP"
    sleep 2
    mkdir -p "$(dirname "$file")"
    screencapture -x -o -l "$window" "$file" \
        || { STATUS="ERROR: screencapture failed (Terminal needs Screen Recording permission)"; exit 1; }
    echo "captured $file ($(sips -g pixelWidth -g pixelHeight "$file" | awk '/pixel/ {print $2}' | paste -sd x -))"
}

take_screenshots() {
    step "screenshots"
    [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" != "Dark" ] \
        || { STATUS="ERROR: switch macOS to Light appearance first (the README screenshots are light mode)"; exit 1; }
    [ -f "$RICOH_DEMO_PPD" ] \
        || { STATUS="ERROR: the Options screenshot needs Ricoh's driver ($RICOH_DEMO_PPD not found)"; exit 1; }
    cleanup_screenshots

    # Save the user's app settings (window frame, selection, tab); restored in cleanup.
    SAVED_PREFS=$(mktemp -t cupsadmin-prefs).plist
    defaults export "$APP_DOMAIN" "$SAVED_PREFS" 2>/dev/null || true
    [ -s "$SAVED_PREFS" ] || printf '{}' | plutil -convert xml1 -o "$SAVED_PREFS" -

    for queue in Front_Office Library_Color Lab_Mono; do
        lpadmin -p "$queue" -v "lpd://127.0.0.1/$queue" -m drv:///sample.drv/generic.ppd \
            -D "${queue//_/ }" -L "Building A" -o printer-is-shared=false -E 2>&1 | grep -v deprecated || true
    done
    # A Ricoh queue for the Options tab, set to Letter + fit to nearest size (what a US site uses).
    # Ricoh's filters are Intel-only, so its header also shows "Driver needs Rosetta".
    lpadmin -p Copy_Room -v lpd://127.0.0.1/Copy_Room -P "$RICOH_DEMO_PPD" -D "Copy Room" -L "Building A" \
        -o printer-is-shared=false -o PageSize=Letter -o RIPaperPolicy=NearestSizeAdjust -E 2>&1 | grep -v deprecated || true
    # Held jobs never leave the Mac; owners are generic names, not the person running the build.
    lp -d Front_Office -U alex -H hold -t "Quarterly budget.pdf" /etc/hosts >/dev/null
    lp -d Front_Office -U jordan -H hold -t "Staff meeting agenda" /etc/hosts >/dev/null
    lp -d Front_Office -U sam -H hold -t "Parking permits.docx" /etc/hosts >/dev/null
    lp -d Front_Office -U alex -H hold -t "Invoice 2291" /etc/hosts >/dev/null
    lp -d Library_Color -U jordan -H hold -t "Event poster" /etc/hosts >/dev/null

    # The Options shot shows the header's "Driver needs Rosetta" row: Ricoh's pstopsRV2 filter is Intel-only.
    # grep without -q: under pipefail, -q exiting early would kill ppdreport and fail the pipeline.
    "$BINARY" ppdreport Copy_Room 2>/dev/null | grep '^WARNING: *Driver needs Rosetta' >/dev/null \
        || { STATUS="ERROR: Copy_Room isn't flagged \"Driver needs Rosetta\" on this Mac, so the Options screenshot wouldn't show the warning"; exit 1; }

    SCREEN=$(osascript -e 'tell application "Finder" to get bounds of window of desktop' | tr -d ' ' | tr ',' ' ')
    capture_app Front_Office jobs "$SHOT_JOBS"
    capture_app Copy_Room options "$SHOT_OPTIONS"
}

# --- configuration -------------------------------------------------------------
cd "$(dirname "$0")"
VERSION="${VERSION:-1.1.1}"
IDENTIFIER="edu.wku.cupsadmin"

# build.env fills in only what the environment doesn't already set.
SETTINGS="CODESIGN_APP_IDENTITY CODESIGN_PKG_IDENTITY NOTARY_PROFILE CODESIGN_TEAM_ID"
for name in $SETTINGS; do
    if [ -n "${!name+set}" ]; then eval "FROM_ENV_$name=\"\${$name}\""; fi
done
if [ -f build.env ]; then
    set -a; . ./build.env; set +a
    echo "read build.env"
fi
for name in $SETTINGS; do
    from_env="FROM_ENV_$name"
    if [ -n "${!from_env+set}" ]; then eval "$name=\"\${$from_env}\""; fi
done

require() {
    [ -n "${!1:-}" ] || { STATUS="ERROR: $1 is not set ($2). Export it or add it to build.env"; exit 1; }
}
if [ $BUILD_ONLY -eq 0 ]; then
    # SHA-1 hashes rather than names: a keychain can hold several identities with the same name.
    require CODESIGN_APP_IDENTITY "SHA-1 of your Developer ID Application certificate"
    require CODESIGN_PKG_IDENTITY "SHA-1 of your Developer ID Installer certificate"
    require NOTARY_PROFILE "keychain profile from xcrun notarytool store-credentials"
    APP_SIGN_ID="$CODESIGN_APP_IDENTITY"
    INSTALLER_SIGN_ID="$CODESIGN_PKG_IDENTITY"
else
    APP_SIGN_ID="-"   # ad-hoc: runs on this Mac, not distributable
fi
TEAM_ID="${CODESIGN_TEAM_ID:-}"

DIST="dist"
# Payload-free: pkgbuild always gives a payload a "." entry (the install-location directory, root:wheel 755),
# which would reset ownership of an existing /usr/local/bin. The binary rides in Scripts instead and
# pkg/postinstall copies it, creating /usr/local/bin only if missing.
SCRIPTS="$DIST/scripts"
BINARY="$SCRIPTS/cupsadmin"
APP="$DIST/CUPS Admin.app"
APP_IDENTIFIER="edu.wku.cupsadmin.app"
APP_EXECUTABLE="CUPSAdminApp"   # can't be "CUPSAdmin": APFS is case-insensitive and would collide with cupsadmin
APP_ICON_SOURCE="Icon/AppIcon-1024.png"
PKG="$DIST/cupsadmin-$VERSION.pkg"

# --- preflight ------------------------------------------------------------------
step "preflight"
if [ $BUILD_ONLY -eq 0 ]; then
    security find-identity -v -p codesigning | grep "$APP_SIGN_ID" >/dev/null \
        || { STATUS="ERROR: CODESIGN_APP_IDENTITY $APP_SIGN_ID is not a valid codesigning identity in the keychain"; exit 1; }
    security find-identity -v | grep "$INSTALLER_SIGN_ID" >/dev/null \
        || { STATUS="ERROR: CODESIGN_PKG_IDENTITY $INSTALLER_SIGN_ID is not an identity in the keychain"; exit 1; }
    xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" >/dev/null 2>&1 \
        || { STATUS="ERROR: NOTARY_PROFILE '$NOTARY_PROFILE' missing or invalid (create it with xcrun notarytool store-credentials)"; exit 1; }
    echo "identities and notary profile OK"
else
    echo "build only: ad-hoc signing, no identities or notary profile needed"
fi

# --- universal build ------------------------------------------------------------
# `swift build --arch arm64 --arch x86_64` needs full Xcode (XCBuild); with only the Command Line Tools
# we build each triple and lipo them together. Same result.
step "universal release build"
# Only clear what this run rebuilds; earlier notarized pkgs in dist/ stay.
rm -rf "$SCRIPTS" "$APP" "$DIST/expanded" "$DIST/AppIcon.iconset"
mkdir -p "$SCRIPTS"
for arch in arm64 x86_64; do
    swift build -c release --triple "$arch-apple-macosx14.0"
done
lipo -create -output "$BINARY" \
    .build/arm64-apple-macosx/release/cupsadmin \
    .build/x86_64-apple-macosx/release/cupsadmin
chmod 755 "$BINARY"
echo "architectures: $(lipo -archs "$BINARY")"

# --- sign binary ----------------------------------------------------------------
step "sign binary"
if [ $BUILD_ONLY -eq 0 ]; then
    codesign --force --sign "$APP_SIGN_ID" --options runtime --timestamp --identifier "$IDENTIFIER" "$BINARY"
else
    codesign --force --sign - --identifier "$IDENTIFIER" "$BINARY"
fi
codesign --verify --strict --verbose=2 "$BINARY"
codesign -dvv "$BINARY" 2>&1 | grep -E '^(Identifier|Authority|TeamIdentifier|Timestamp|Runtime Version)=' || true
if [ -n "$TEAM_ID" ] && [ $BUILD_ONLY -eq 0 ]; then
    codesign -dvv "$BINARY" 2>&1 | grep "^TeamIdentifier=$TEAM_ID$" >/dev/null \
        || { STATUS="ERROR: binary signed with wrong team (expected CODESIGN_TEAM_ID=$TEAM_ID)"; exit 1; }
fi
"$BINARY" help >/dev/null 2>&1 || { STATUS="ERROR: signed binary failed to run"; exit 1; }

# --- assemble + sign app --------------------------------------------------------
step "assemble and sign app"
mkdir -p "$APP/Contents/MacOS"
lipo -create -output "$APP/Contents/MacOS/$APP_EXECUTABLE" \
    ".build/arm64-apple-macosx/release/$APP_EXECUTABLE" \
    ".build/x86_64-apple-macosx/release/$APP_EXECUTABLE"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>            <string>$APP_IDENTIFIER</string>
    <key>CFBundleName</key>                  <string>CUPS Admin</string>
    <key>CFBundleDisplayName</key>           <string>CUPS Admin</string>
    <key>CFBundleExecutable</key>            <string>$APP_EXECUTABLE</string>
    <key>CFBundleIconFile</key>              <string>AppIcon</string>
    <key>CFBundlePackageType</key>           <string>APPL</string>
    <key>CFBundleShortVersionString</key>    <string>$VERSION</string>
    <key>CFBundleVersion</key>               <string>$VERSION</string>
    <key>CFBundleInfoDictionaryVersion</key> <string>6.0</string>
    <key>LSMinimumSystemVersion</key>        <string>14.0</string>
    <key>LSApplicationCategoryType</key>     <string>public.app-category.utilities</string>
    <key>NSHighResolutionCapable</key>       <true/>
    <key>NSPrincipalClass</key>              <string>NSApplication</string>
    <key>NSHumanReadableCopyright</key>      <string>Western Kentucky University</string>
</dict>
</plist>
PLIST
plutil -lint "$APP/Contents/Info.plist"

# App icon: every iconset size from the 1024 px PNG, then one .icns.
[ -f "$APP_ICON_SOURCE" ] || { STATUS="ERROR: app icon $APP_ICON_SOURCE not found"; exit 1; }
ICONSET="$DIST/AppIcon.iconset"
rm -rf "$ICONSET"; mkdir -p "$ICONSET" "$APP/Contents/Resources"
for size in 16 32 128 256 512; do
    sips -z $size $size "$APP_ICON_SOURCE" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    sips -z $((size * 2)) $((size * 2)) "$APP_ICON_SOURCE" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET"
echo "icon: $(ls -l "$APP/Contents/Resources/AppIcon.icns" | awk '{print $5}') bytes"
printf 'APPL????' > "$APP/Contents/PkgInfo"
if [ $BUILD_ONLY -eq 0 ]; then
    codesign --force --sign "$APP_SIGN_ID" --options runtime --timestamp "$APP"
else
    codesign --force --sign - "$APP"
fi
codesign --verify --deep --strict --verbose=2 "$APP"
codesign -dvv "$APP" 2>&1 | grep -E '^(Identifier=|Authority=Developer ID|TeamIdentifier=|Runtime Version=)' || true
if [ -n "$TEAM_ID" ] && [ $BUILD_ONLY -eq 0 ]; then
    codesign -dvv "$APP" 2>&1 | grep "^TeamIdentifier=$TEAM_ID$" >/dev/null \
        || { STATUS="ERROR: app signed with wrong team (expected CODESIGN_TEAM_ID=$TEAM_ID)"; exit 1; }
fi
echo "app architectures: $(lipo -archs "$APP/Contents/MacOS/$APP_EXECUTABLE")"

if [ $SCREENSHOTS -eq 1 ]; then
    take_screenshots
    STATUS="OK: regenerated $SHOT_JOBS and $SHOT_OPTIONS"
    exit 0
fi

if [ $BUILD_ONLY -eq 1 ]; then
    STATUS="OK: built $BINARY and $APP, ad-hoc signed (build only: no pkg, no notarization)"
    exit 0
fi

# --- notarize helper --------------------------------------------------------------
# notarize <file> <label>: submits, waits, saves the log; fails the build unless Accepted.
notarize() {
    local file="$1" label="$2"
    local json="$DIST/notary-$label.json"
    xcrun notarytool submit "$file" --keychain-profile "$NOTARY_PROFILE" --wait --output-format json > "$json" || true
    local status id
    status=$(plutil -extract status raw "$json" 2>/dev/null || echo "unknown")
    id=$(plutil -extract id raw "$json" 2>/dev/null || echo "")
    echo "$label submission $id: $status"
    if [ -n "$id" ]; then
        xcrun notarytool log "$id" --keychain-profile "$NOTARY_PROFILE" "$DIST/notary-$label-log.json" >/dev/null 2>&1 || true
    fi
    [ "$status" = "Accepted" ] \
        || { STATUS="ERROR: $label notarization $status (see $json and $DIST/notary-$label-log.json)"; exit 1; }
}

# spctl_check <type> <path> <log>: must be accepted as Notarized Developer ID.
spctl_check() {
    local type="$1" path="$2" log="$3" out
    out=$(spctl -a -vv -t "$type" "$path" 2>&1 || true)
    echo "$out" | tee "$log"
    echo "$out" | grep ': accepted' >/dev/null && echo "$out" | grep 'source=Notarized Developer ID' >/dev/null \
        || { STATUS="ERROR: spctl did not accept $path as Notarized Developer ID"; exit 1; }
}

# --- notarize + staple app --------------------------------------------------------
step "notarize app (uploads to Apple and waits)"
APP_ZIP="$DIST/CUPS-Admin-$VERSION.zip"
rm -f "$APP_ZIP"
ditto -c -k --keepParent "$APP" "$APP_ZIP"
notarize "$APP_ZIP" app
rm -f "$APP_ZIP"
xcrun stapler staple "$APP"
xcrun stapler validate "$APP"
spctl_check execute "$APP" "$DIST/spctl-app.txt"

# --- build + sign pkg -----------------------------------------------------------
# App: a normal payload with a receipt. The staging root mirrors the system — "/" root:wheel 755,
# Applications root:admin 775, the app root:wheel — and pkgbuild --ownership preserve records exactly
# that, so installing never changes /Applications' ownership. (--ownership recommended would record
# Applications as root:wheel.) Making files root-owned needs admin rights, once per build.
# CLI: stays payload-free — the binary rides in Scripts and pkg/postinstall copies it, because a
# /usr/local/bin payload entry would reset an existing Homebrew-owned /usr/local/bin.

# as_root "<command>": sudo when there's a terminal (or cached credentials), else the standard
# administrator password dialog. Never stores a password.
as_root() {
    if sudo -n true 2>/dev/null || [ -t 0 ]; then
        sudo /bin/sh -c "$1"
    else
        local escaped="${1//\\/\\\\}"
        escaped="${escaped//\"/\\\"}"
        osascript -e "do shell script \"$escaped\" with administrator privileges" >/dev/null
    fi
}

step "build and sign pkg"
rm -f "$PKG"
rm -rf "$SCRIPTS/CUPS Admin.app"
cp pkg/postinstall "$SCRIPTS/postinstall"
chmod 755 "$SCRIPTS/postinstall"

PKGROOT="$PWD/$DIST/pkgroot-$$"
mkdir -p "$PKGROOT/Applications"
ditto "$APP" "$PKGROOT/Applications/CUPS Admin.app"
echo "setting staging ownership (admin rights needed once)"
# Also removes root-owned staging folders left by earlier builds.
as_root "find '$PWD/$DIST' -maxdepth 1 -name 'pkgroot-*' ! -name 'pkgroot-$$' -exec rm -rf {} + ; \
    chown root:wheel '$PKGROOT' && chmod 755 '$PKGROOT' && \
    chown root:admin '$PKGROOT/Applications' && chmod 775 '$PKGROOT/Applications' && \
    chown -R root:wheel '$PKGROOT/Applications/CUPS Admin.app' && chmod -R go-w '$PKGROOT/Applications/CUPS Admin.app'" \
    || { STATUS="ERROR: couldn't set staging ownership (admin rights are needed for the app payload)"; exit 1; }

COMPONENTS="$DIST/components.plist"
pkgbuild --analyze --root "$PKGROOT" "$COMPONENTS" >/dev/null
# Install exactly at /Applications/CUPS Admin.app, never "relocated" to another copy LaunchServices knows about.
plutil -replace 0.BundleIsRelocatable -bool NO "$COMPONENTS"
plutil -replace 0.BundleOverwriteAction -string upgrade "$COMPONENTS"
pkgbuild --root "$PKGROOT" --install-location / --ownership preserve --component-plist "$COMPONENTS" \
    --scripts "$SCRIPTS" --identifier "$IDENTIFIER" --version "$VERSION" \
    --sign "$INSTALLER_SIGN_ID" --timestamp "$PKG"
pkgutil --check-signature "$PKG"

step "verify pkg contents"
PAYLOAD_FILES=$(pkgutil --payload-files "$PKG")
echo "payload: $(echo "$PAYLOAD_FILES" | wc -l | tr -d ' ') entries, top level:"
echo "$PAYLOAD_FILES" | awk -F/ 'NF <= 3' | sed 's/^/    /'
if echo "$PAYLOAD_FILES" | grep -v -E '^\.$|^\./Applications$|^\./Applications/CUPS Admin\.app(/|$)' | grep . >/dev/null; then
    STATUS="ERROR: payload contains something other than /Applications/CUPS Admin.app"; exit 1
fi
EXPANDED="$DIST/expanded"
rm -rf "$EXPANDED"
pkgutil --expand "$PKG" "$EXPANDED"
BOM_ROOT=$(lsbom "$EXPANDED/Bom" | awk -F'\t' '$1=="."{print $2, $3}')
BOM_APPS=$(lsbom "$EXPANDED/Bom" | awk -F'\t' '$1=="./Applications"{print $2, $3}')
BOM_APP=$(lsbom "$EXPANDED/Bom" | awk -F'\t' '$1=="./Applications/CUPS Admin.app"{print $2, $3}')
echo "BOM: / $BOM_ROOT · /Applications $BOM_APPS · CUPS Admin.app $BOM_APP"
[ "$BOM_ROOT" = "40755 0/0" ] && [ "$BOM_APPS" = "40775 0/80" ] && [ "$BOM_APP" = "40755 0/0" ] \
    || { STATUS="ERROR: pkg ownership doesn't match the system (expected / 40755 0/0, /Applications 40775 0/80, app 40755 0/0)"; exit 1; }
echo "Scripts: $(ls "$EXPANDED/Scripts" | tr '\n' ' ')"
[ -x "$EXPANDED/Scripts/postinstall" ] && [ -f "$EXPANDED/Scripts/cupsadmin" ] && [ ! -e "$EXPANDED/Scripts/CUPS Admin.app" ] \
    || { STATUS="ERROR: Scripts should hold only postinstall and cupsadmin"; exit 1; }
codesign --verify --strict "$EXPANDED/Scripts/cupsadmin" \
    || { STATUS="ERROR: binary inside pkg Scripts lost its signature"; exit 1; }
rm -rf "$EXPANDED"
FULL="$DIST/expanded-full"
rm -rf "$FULL"
pkgutil --expand-full "$PKG" "$FULL"
codesign --verify --deep --strict "$FULL/Payload/Applications/CUPS Admin.app" \
    || { STATUS="ERROR: app in the payload lost its signature"; exit 1; }
xcrun stapler validate "$FULL/Payload/Applications/CUPS Admin.app" >/dev/null \
    || { STATUS="ERROR: app in the payload lost its stapled ticket"; exit 1; }
echo "inside pkg: CUPS Admin.app signed and stapled (payload), cupsadmin signed (Scripts)"
rm -rf "$FULL"

# --- notarize + staple pkg ------------------------------------------------------
step "notarize pkg (uploads to Apple and waits)"
notarize "$PKG" pkg

step "staple pkg"
xcrun stapler staple "$PKG"
xcrun stapler validate "$PKG"

step "spctl assessment"
spctl_check install "$PKG" "$DIST/spctl.txt"
spctl_check execute "$APP" "$DIST/spctl-app.txt"

echo
echo "install: sudo installer -pkg $PKG -target /"
STATUS="OK: $PKG (app payload + CLI postinstall) signed, app and pkg notarized, stapled, spctl accepted"
