#!/bin/sh
set -eu
[ "$(id -u)" -eq 0 ] || { echo 'Run inside the guest using sudo.' >&2; exit 1; }
source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
[ -f "$source_dir/BlotGuestRunner" ] || { echo 'Guest runner is missing.' >&2; exit 1; }
mkdir -p /usr/local/libexec /Users/Shared/BlotBuild/tmp /Users/Shared/BlotBuild/gradle /Users/Shared/BlotBuild/module-cache
cp "$source_dir/BlotGuestRunner" /usr/local/libexec/BlotGuestRunner
chmod 755 /usr/local/libexec/BlotGuestRunner
cat > /Library/LaunchDaemons/com.blot.guest-runner.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>com.blot.guest-runner</string>
<key>ProgramArguments</key><array><string>/usr/local/libexec/BlotGuestRunner</string></array>
<key>RunAtLoad</key><true/>
<key>KeepAlive</key><true/>
<key>StandardErrorPath</key><string>/Users/Shared/BlotBuild/runner.log</string>
</dict></plist>
PLIST
chmod 644 /Library/LaunchDaemons/com.blot.guest-runner.plist
launchctl bootout system/com.blot.guest-runner 2>/dev/null || true
launchctl bootstrap system /Library/LaunchDaemons/com.blot.guest-runner.plist
printf '%s\n' 'Guest runner installed. Install JDK 25 at /Library/Java/JavaVirtualMachines/blot and Xcode, then save the stopped base image.'
