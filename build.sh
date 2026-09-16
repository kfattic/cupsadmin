#!/bin/bash
# Universal release build -> signed CLI binary + signed "CUPS Admin.app" -> signed payload-free PKG
# (postinstall installs /usr/local/bin/cupsadmin) -> notarize -> staple -> spctl.
# Usage: ./build.sh               full pipeline (VERSION=1.2.0 ./build.sh to set the version)
#        ./build.sh --build-only  build CLI and app, ad-hoc signed; no identities, no pkg, no notarization
#
# Signing settings come from the environment, or from an untracked build.env next to this script
# (plain KEY=value lines; a variable already set in the environment wins):
#   CODESIGN_APP_IDENTITY  SHA-1 of your "Developer ID Application" certificate
#   CODESIGN_PKG_IDENTITY  SHA-1 of your "Developer ID Installer" certificate
#   NOTARY_PROFILE         keychain profile from `xcrun notarytool store-credentials`
#   CODESIGN_TEAM_ID       optional: fail if the signatures aren't from this team
set -euo pipefail

BUILD_ONLY=0
for arg in "$@"; do
    case "$arg" in
        --build-only) BUILD_ONLY=1 ;;
        *) echo "started $(date +%H:%M:%S)"; echo "ERROR: unknown argument $arg (use --build-only)"
           echo "finished $(date +%H:%M:%S) (total 0.0 min)"; exit 2 ;;
    esac
done

START_EPOCH=$(date +%s)
echo "started $(date +%H:%M:%S)"
STATUS="ERROR: build.sh exited unexpectedly"

finish() {
    local rc=$?
    if [ $rc -ne 0 ] && [ "${STATUS#OK}" != "$STATUS" ]; then STATUS="ERROR: exit $rc"; fi
    echo "$STATUS"
    echo "finished $(date +%H:%M:%S) (total $(awk -v s="$(( $(date +%s) - START_EPOCH ))" 'BEGIN{printf "%.1f", s/60}') min)"
}
trap finish EXIT
trap 'STATUS="ERROR: interrupted"; exit 130' INT TERM

step() { STATUS="ERROR: failed at: $1"; echo; echo "==> $1"; }

# --- configuration -------------------------------------------------------------
cd "$(dirname "$0")"
VERSION="${VERSION:-1.0.1}"
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

if [ $BUILD_ONLY -eq 1 ]; then
    STATUS="OK: built $BINARY and $APP, ad-hoc signed (build only: no pkg, no notarization)"
    exit 0
fi

# --- build + sign pkg -----------------------------------------------------------
step "build and sign pkg"
rm -f "$PKG"
cp pkg/postinstall "$SCRIPTS/postinstall"
chmod 755 "$SCRIPTS/postinstall"
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
pkgutil --expand "$PKG" "$EXPANDED"
# pkgutil --expand unpacks the Scripts archive into a directory.
echo "Scripts: $(ls "$EXPANDED/Scripts" | tr '\n' ' ')"
[ -x "$EXPANDED/Scripts/postinstall" ] && [ -f "$EXPANDED/Scripts/cupsadmin" ] \
    || { STATUS="ERROR: Scripts missing postinstall or cupsadmin"; exit 1; }
codesign --verify --strict "$EXPANDED/Scripts/cupsadmin" \
    || { STATUS="ERROR: binary inside pkg Scripts lost its signature"; exit 1; }
echo "binary inside pkg: signature intact, $(lipo -archs "$EXPANDED/Scripts/cupsadmin")"
rm -rf "$EXPANDED"

# --- notarize -------------------------------------------------------------------
step "notarize (this uploads the pkg to Apple and waits)"
SUBMIT_JSON="$DIST/notary-submit.json"
xcrun notarytool submit "$PKG" --keychain-profile "$NOTARY_PROFILE" --wait --output-format json > "$SUBMIT_JSON" || true
NOTARY_STATUS=$(plutil -extract status raw "$SUBMIT_JSON" 2>/dev/null || echo "unknown")
SUBMISSION_ID=$(plutil -extract id raw "$SUBMIT_JSON" 2>/dev/null || echo "")
echo "submission $SUBMISSION_ID: $NOTARY_STATUS"
if [ -n "$SUBMISSION_ID" ]; then
    xcrun notarytool log "$SUBMISSION_ID" --keychain-profile "$NOTARY_PROFILE" "$DIST/notary-log.json" >/dev/null 2>&1 || true
fi
if [ "$NOTARY_STATUS" != "Accepted" ]; then
    STATUS="ERROR: notarization $NOTARY_STATUS (see $SUBMIT_JSON and $DIST/notary-log.json)"
    exit 1
fi

# --- staple + verify ------------------------------------------------------------
step "staple"
xcrun stapler staple "$PKG"
xcrun stapler validate "$PKG"

step "spctl assessment"
spctl -a -vv -t install "$PKG" 2>&1 | tee "$DIST/spctl.txt"
grep -q ': accepted' "$DIST/spctl.txt" && grep -q 'source=Notarized Developer ID' "$DIST/spctl.txt" \
    || { STATUS="ERROR: spctl did not accept $PKG as Notarized Developer ID"; exit 1; }

echo
echo "install: sudo installer -pkg $PKG -target /"
STATUS="OK: $PKG signed, notarized ($SUBMISSION_ID), stapled, spctl accepted"
