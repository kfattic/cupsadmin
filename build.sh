#!/bin/bash
# Universal release build -> signed CLI + signed, notarized, stapled "CUPS Admin.app" -> signed payload-free PKG
# (postinstall installs /usr/local/bin/cupsadmin and /Applications/CUPS Admin.app) -> notarize -> staple -> spctl.
# Usage: ./build.sh               full pipeline (VERSION=1.2.0 ./build.sh to set the version)
#        ./build.sh --build-only  build CLI and app, ad-hoc signed; no identities, no pkg, no notarization
#        ./build.sh --screenshots build like --build-only, then regenerate docs/screenshots/app-jobs.png
#                                 (creates three demo queues on 127.0.0.1 with held jobs, deletes them after)
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
DEMO_QUEUES="Front_Office Library_Color Lab_Mono"
SHOT="docs/screenshots/app-jobs.png"
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

take_screenshots() {
    step "screenshots"
    [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" != "Dark" ] \
        || { STATUS="ERROR: switch macOS to Light appearance first (the README screenshot is light mode)"; exit 1; }
    cleanup_screenshots

    # Save the user's app settings (window frame, selection, tab); restored in cleanup.
    SAVED_PREFS=$(mktemp -t cupsadmin-prefs).plist
    defaults export "$APP_DOMAIN" "$SAVED_PREFS" 2>/dev/null || defaults export "$APP_DOMAIN" - >/dev/null 2>&1 || true
    [ -s "$SAVED_PREFS" ] || printf '{}' | plutil -convert xml1 -o "$SAVED_PREFS" -

    for queue in $DEMO_QUEUES; do
        lpadmin -p "$queue" -v "lpd://127.0.0.1/$queue" -m drv:///sample.drv/generic.ppd \
            -D "${queue//_/ }" -L "Building A" -o printer-is-shared=false -E 2>&1 | grep -v deprecated || true
    done
    # Held jobs never leave the Mac; owners are generic names, not the person running the build.
    lp -d Front_Office -U alex -H hold -t "Quarterly budget.pdf" /etc/hosts >/dev/null
    lp -d Front_Office -U jordan -H hold -t "Staff meeting agenda" /etc/hosts >/dev/null
    lp -d Front_Office -U sam -H hold -t "Parking permits.docx" /etc/hosts >/dev/null
    lp -d Front_Office -U alex -H hold -t "Invoice 2291" /etc/hosts >/dev/null
    lp -d Library_Color -U jordan -H hold -t "Event poster" /etc/hosts >/dev/null

    SCREEN=$(osascript -e 'tell application "Finder" to get bounds of window of desktop' | tr -d ' ' | tr ',' ' ')
    defaults write "$APP_DOMAIN" selectedQueue Front_Office
    defaults write "$APP_DOMAIN" detailTab jobs
    defaults write "$APP_DOMAIN" "NSWindow Frame main" "120 120 1400 860 $SCREEN "
    open "$APP" --args --only-queues "${DEMO_QUEUES// /,}"

    FINDER=$(mktemp -t cupsadmin-window).swift
    cat > "$FINDER" <<'SWIFT'
import CoreGraphics
let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
if let w = windows.first(where: { ($0[kCGWindowOwnerName as String] as? String) == "CUPS Admin" && ($0[kCGWindowLayer as String] as? Int) == 0 }),
   let id = w[kCGWindowNumber as String] as? Int { print(id) }
SWIFT
    WINDOW=""
    for _ in $(seq 1 30); do WINDOW=$(swift "$FINDER" 2>/dev/null || true); [ -n "$WINDOW" ] && break; sleep 1; done
    rm -f "$FINDER"
    [ -n "$WINDOW" ] || { STATUS="ERROR: CUPS Admin window didn't appear on this Space"; exit 1; }
    sleep 3   # let the sidebar, header and jobs load
    # Capture it as the active window (colored traffic lights, accent-colored selection).
    osascript -e "tell application id \"$APP_DOMAIN\" to activate" >/dev/null 2>&1 || true
    open "$APP"
    sleep 2
    mkdir -p "$(dirname "$SHOT")"
    screencapture -x -o -l "$WINDOW" "$SHOT" \
        || { STATUS="ERROR: screencapture failed (Terminal needs Screen Recording permission)"; exit 1; }
    SHOT_SIZE="$(sips -g pixelWidth -g pixelHeight "$SHOT" | awk '/pixel/ {print $2}' | paste -sd x -)"
    echo "captured $SHOT ($SHOT_SIZE)"
}

# --- configuration -------------------------------------------------------------
cd "$(dirname "$0")"
VERSION="${VERSION:-1.1.0}"
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
    STATUS="OK: regenerated $SHOT (${SHOT_SIZE})"
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
    echo "$out" | grep -q ': accepted' && echo "$out" | grep -q 'source=Notarized Developer ID' \
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
# Payload-free for the app too: an /Applications payload's "." entry is recorded as root:wheel, but
# /Applications is root:admin 775 — installing it could take away admins' drag-install rights.
# pkg/postinstall copies both the CLI and the stapled app instead.
step "build and sign pkg"
rm -f "$PKG"
cp pkg/postinstall "$SCRIPTS/postinstall"
chmod 755 "$SCRIPTS/postinstall"
rm -rf "$SCRIPTS/CUPS Admin.app"
ditto "$APP" "$SCRIPTS/CUPS Admin.app"
pkgbuild --nopayload --scripts "$SCRIPTS" --identifier "$IDENTIFIER" --version "$VERSION" \
    --sign "$INSTALLER_SIGN_ID" --timestamp "$PKG"
pkgutil --check-signature "$PKG"

step "verify pkg contents"
echo "pkgutil --payload-files $PKG:"
PAYLOAD_FILES=$(pkgutil --payload-files "$PKG" 2>&1 || true)
echo "${PAYLOAD_FILES:-(no output)}"
if [ -n "$(printf '%s' "$PAYLOAD_FILES" | grep -v -i 'no payload' || true)" ]; then
    STATUS="ERROR: pkg has payload entries; expected none"
    exit 1
fi
EXPANDED="$DIST/expanded"
rm -rf "$EXPANDED"
pkgutil --expand "$PKG" "$EXPANDED"
# pkgutil --expand unpacks the Scripts archive into a directory.
echo "Scripts: $(ls "$EXPANDED/Scripts" | tr '\n' ' ')"
[ -x "$EXPANDED/Scripts/postinstall" ] && [ -f "$EXPANDED/Scripts/cupsadmin" ] && [ -d "$EXPANDED/Scripts/CUPS Admin.app" ] \
    || { STATUS="ERROR: Scripts missing postinstall, cupsadmin or CUPS Admin.app"; exit 1; }
codesign --verify --strict "$EXPANDED/Scripts/cupsadmin" \
    || { STATUS="ERROR: binary inside pkg Scripts lost its signature"; exit 1; }
codesign --verify --deep --strict "$EXPANDED/Scripts/CUPS Admin.app" \
    || { STATUS="ERROR: app inside pkg Scripts lost its signature"; exit 1; }
xcrun stapler validate "$EXPANDED/Scripts/CUPS Admin.app" >/dev/null \
    || { STATUS="ERROR: app inside pkg Scripts lost its stapled ticket"; exit 1; }
echo "inside pkg: cupsadmin signed ($(lipo -archs "$EXPANDED/Scripts/cupsadmin")), CUPS Admin.app signed and stapled"
rm -rf "$EXPANDED"

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
STATUS="OK: $PKG (CLI + CUPS Admin.app) signed, app and pkg notarized, stapled, spctl accepted"
