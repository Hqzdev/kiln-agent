#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
mode="${1:-run}"
case "$mode" in
    run|--debug|--logs|--telemetry|--verify) ;;
    *) echo "usage: $0 [--debug|--logs|--telemetry|--verify]" >&2; exit 2 ;;
esac
pkill -x Blot >/dev/null 2>&1 || true
xcodebuild -quiet -project apps/Blot.xcodeproj -scheme BlotMac -configuration Debug \
    -destination "platform=macOS,arch=$(uname -m)" -derivedDataPath .build/xcode CODE_SIGNING_ALLOWED=NO build
app_bundle="$PWD/.build/xcode/Build/Products/Debug/Blot.app"
scripts/package-backend.sh "$app_bundle"
case "$mode" in
    --debug) lldb -- "$app_bundle/Contents/MacOS/Blot" ;;
    --logs) open -n "$app_bundle"; /usr/bin/log stream --info --style compact --predicate 'process == "Blot"' ;;
    --telemetry)
        bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app_bundle/Contents/Info.plist")
        open -n "$app_bundle"
        /usr/bin/log stream --info --style compact --predicate "subsystem == \"$bundle_id\""
        ;;
    --verify) open -n "$app_bundle"; sleep 1; pgrep -x Blot >/dev/null ;;
    run) open -n "$app_bundle" ;;
esac
