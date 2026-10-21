#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
bundle="${1:?Pass the generated app bundle}"
: "${BLOT_SIGNING_IDENTITY:?Set an Apple Development or Developer ID Application signing identity with a private key before packaging}"
[ "$BLOT_SIGNING_IDENTITY" != "-" ] || { echo 'A Team ID is required for the hardened JVM and SQLite libraries.' >&2; exit 1; }
[ -d "$bundle/Contents" ] || { echo "App bundle is missing" >&2; exit 1; }
if [ -x .build/tools/jdk-25.0.4.1+1/Contents/Home/bin/java ]; then
    JAVA_HOME="$PWD/.build/tools/jdk-25.0.4.1+1/Contents/Home"
    export JAVA_HOME
fi
: "${JAVA_HOME:?Select JDK 25 before packaging}"
GRADLE_USER_HOME="${GRADLE_USER_HOME:-$PWD/.build/gradle-home}"
export GRADLE_USER_HOME
backend/gradlew --no-daemon -p backend :api:bootJar
resources="$bundle/Contents/Resources/Backend"
mkdir -p "$resources"
cp backend/api/build/libs/blot-backend.jar "$resources/blot-backend.jar"
scripts/build-native-helpers.sh "$resources"
mkdir -p "$resources/native"
# Версия берётся из фактического bootJar, поэтому не дублируется в скрипте.
python3 - "$resources/blot-backend.jar" "$resources/native/libsqlitejdbc.dylib" <<'PYTHON'
import io, pathlib, sys, zipfile
with zipfile.ZipFile(sys.argv[1]) as application:
    libraries = [name for name in application.namelist() if name.startswith('BOOT-INF/lib/sqlite-jdbc-') and name.endswith('.jar')]
    if len(libraries) != 1:
        raise SystemExit('Expected one pinned SQLite JDBC library')
    with zipfile.ZipFile(io.BytesIO(application.read(libraries[0]))) as driver:
        pathlib.Path(sys.argv[2]).write_bytes(driver.read('org/sqlite/native/Mac/aarch64/libsqlitejdbc.dylib'))
PYTHON
codesign --force --options runtime --sign "${BLOT_SIGNING_IDENTITY:--}" "$resources/native/libsqlitejdbc.dylib"

runtime="$resources/runtime/Contents/Home"
if [ ! -x "$runtime/bin/java" ]; then
    mkdir -p "$resources/runtime/Contents"
    "$JAVA_HOME/bin/jlink" --add-modules java.se,jdk.crypto.ec,jdk.unsupported,jdk.management,jdk.zipfs,jdk.charsets \
        --strip-debug --no-header-files --no-man-pages --output "$runtime"
fi
"$JAVA_HOME/bin/java" -version

# Подписываем вложенный код отдельно; основной App Sandbox остаётся включённым.
find "$runtime" -type f \( -name '*.dylib' -o -perm -111 \) | while IFS= read -r binary; do
    if /usr/bin/file -b "$binary" | /usr/bin/grep -q 'Mach-O'; then
        case "$binary" in
            */lib/jspawnhelper) codesign --force --identifier com.blot.backend.spawn --options runtime --entitlements native/InheritedProcess.entitlements --sign "${BLOT_SIGNING_IDENTITY:--}" "$binary" ;;
            */bin/java) codesign --force --identifier com.blot.backend.java --options runtime --entitlements native/JavaRuntime.entitlements --sign "${BLOT_SIGNING_IDENTITY:--}" "$binary" ;;
            */bin/*) codesign --force --options runtime --entitlements native/JavaRuntime.entitlements --sign "${BLOT_SIGNING_IDENTITY:--}" "$binary" ;;
            *) codesign --force --options runtime --sign "${BLOT_SIGNING_IDENTITY:--}" "$binary" ;;
        esac
    fi
done

# Debug Xcode может вынести собственный код в отдельные dylib.
for library in "$bundle"/Contents/MacOS/*.dylib; do
    [ -f "$library" ] || continue
    codesign --force --options runtime --sign "${BLOT_SIGNING_IDENTITY:--}" "$library"
done
codesign --force --options runtime --entitlements apps/macos/BlotMac/BlotMac.entitlements --sign "${BLOT_SIGNING_IDENTITY:--}" "$bundle"
codesign --verify --deep --strict "$bundle"
