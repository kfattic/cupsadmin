#!/bin/bash
# Runs CupsKit tests with Swift Testing from the Command Line Tools (no Xcode).
# The CLT ship Testing.framework outside the default search path and an empty _Testing_Foundation
# overlay, so point at the framework, disable cross-import overlays, and load the @Test macro plugin.
# Live apply tests: CUPSKIT_LIVE_QUEUE=<throwaway Ricoh queue> ./test.sh
START_EPOCH=$(date +%s)
echo "started $(date +%H:%M:%S)"
finish() {
    local rc=$?
    [ $rc -eq 0 ] && echo "OK: tests passed" || echo "ERROR: swift test exited $rc"
    echo "finished $(date +%H:%M:%S) (total $(awk -v s="$(( $(date +%s) - START_EPOCH ))" 'BEGIN{printf "%.1f", s/60}') min)"
}
trap finish EXIT
cd "$(dirname "$0")"
F=/Library/Developer/CommandLineTools/Library/Developer/Frameworks
P=/Library/Developer/CommandLineTools/usr/lib/swift/host/plugins/testing
swift test \
    -Xswiftc -F -Xswiftc "$F" -Xswiftc -Xfrontend -Xswiftc -disable-cross-import-overlays \
    -Xswiftc -plugin-path -Xswiftc "$P" \
    -Xlinker -F -Xlinker "$F" -Xlinker -rpath -Xlinker "$F" "$@"
