#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
backend/gradlew --no-daemon -p backend projects
backend/gradlew --no-daemon -p backend --dependency-verification=strict spotlessCheck check :api:bootJar
swift --version
swift build --package-path packages/BlotDomain
swift test --package-path packages/BlotDomain
swift build --package-path packages/BlotAPI
BLOT_HTTP_FIXTURES="$PWD/.build/http-fixtures" swift test --package-path packages/BlotAPI
