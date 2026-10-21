#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
check_dir=$(mktemp -d /private/tmp/blot-shell-check.XXXXXX)
trap 'rm -rf "$check_dir"' EXIT
sources=()
while IFS= read -r -d '' source; do sources+=("$source"); done < <(find apps/macos/BlotMac -name '*.swift' ! -name 'BlotMacApp.swift' -print0)
swiftc -module-cache-path "$check_dir/modules" -default-isolation MainActor -parse-as-library "${sources[@]}" scripts/macos-render-scenarios.swift scripts/verify-macos-shell.swift -o "$check_dir/verify"
if [[ "${1:-}" == "--render" || "${1:-}" == "--render-only" ]]; then
    xcodebuild -quiet -project apps/Blot.xcodeproj -scheme BlotMac -destination "platform=macOS,arch=$(uname -m)" -configuration Debug -derivedDataPath "$check_dir/build" CODE_SIGNING_ALLOWED=NO build
    cp -R "$check_dir/build/Build/Products/Debug/Blot.app" "$check_dir/Preview.app"
    cp "$check_dir/verify" "$check_dir/Preview.app/Contents/MacOS/verify"
    /usr/libexec/PlistBuddy -c 'Set :CFBundleExecutable verify' "$check_dir/Preview.app/Contents/Info.plist"
    "$check_dir/Preview.app/Contents/MacOS/verify" "$1" "$PWD/docs/verification/blot-shell"
else
    "$check_dir/verify"
fi
