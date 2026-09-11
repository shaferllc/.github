#!/bin/bash
# Usage:
#   ./make-app.sh          build for this Mac, install to /Applications, launch
#   ./make-app.sh --dist   build a universal dist/__APP__.app plus a .zip and .dmg
#
# The version comes from the VERSION file; VERSION=x.y.z in the environment
# overrides it, which is how the release workflow stamps a build. Builds here
# are ad-hoc signed; the release workflow (shaferllc/.github mac-release)
# re-signs with the Developer ID and notarizes.
set -euo pipefail
cd "$(dirname "$0")"

DIST=0
[ "${1:-}" = "--dist" ] && DIST=1
SHORT_VERSION="${VERSION:-$(tr -d '[:space:]' < VERSION 2>/dev/null || echo 0.1.0)}"

if [ "$DIST" = "1" ]; then
  # Anything people download has to run on both architectures.
  echo "› Building universal release binary…"
  swift build -c release --arch arm64 --arch x86_64
  BINARY=".build/apple/Products/Release/__APP__"
else
  echo "› Building release binary…"
  swift build -c release
  BINARY=".build/release/__APP__"
fi

if [ ! -f AppIcon.icns ] || [ make-icon.swift -nt AppIcon.icns ]; then
  echo "› Generating AppIcon.icns…"
  swift make-icon.swift
fi

STAGE="$(mktemp -d)"
APP="$STAGE/__APP__.app"
echo "› Assembling in staging: $APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BINARY"     "$APP/Contents/MacOS/__APP__"
cp AppIcon.icns  "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>                 <string>__APP__</string>
    <key>CFBundleDisplayName</key>          <string>__APP__</string>
    <key>CFBundleIdentifier</key>           <string>com.tomshafer.__SLUG__</string>
    <key>CFBundleVersion</key>              <string>${GITHUB_RUN_NUMBER:-1}</string>
    <key>CFBundleShortVersionString</key>   <string>${SHORT_VERSION}</string>
    <key>CFBundleExecutable</key>           <string>__APP__</string>
    <key>CFBundlePackageType</key>          <string>APPL</string>
    <key>CFBundleSupportedPlatforms</key>   <array><string>MacOSX</string></array>
    <key>CFBundleIconFile</key>             <string>AppIcon</string>
    <key>CFBundleIconName</key>             <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>       <string>14.0</string>
    <key>NSHighResolutionCapable</key>      <true/>
    <key>NSHumanReadableCopyright</key>     <string>© __YEAR__ Tom Shafer</string>
    <!-- shafer.llc hands a registration key back via __SLUG__://activate?key=…&state=… -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>      <string>com.tomshafer.__SLUG__</string>
            <key>CFBundleURLSchemes</key>   <array><string>__SLUG__</string></array>
        </dict>
    </array>
</dict>
</plist>
PLIST

xattr -cr "$APP" 2>/dev/null || true
codesign --force --sign - "$APP" >/dev/null 2>&1 || true

if [ "$DIST" = "1" ]; then
  rm -rf dist
  mkdir -p dist
  /bin/mv "$APP" dist/__APP__.app
  rm -rf "$STAGE"

  echo "› Packaging dist/__APP__-${SHORT_VERSION}.zip"
  /usr/bin/ditto -c -k --keepParent dist/__APP__.app "dist/__APP__-${SHORT_VERSION}.zip"

  echo "› Packaging dist/__APP__-${SHORT_VERSION}.dmg"
  DMG_ROOT="$(mktemp -d)"
  /bin/cp -R dist/__APP__.app "$DMG_ROOT/__APP__.app"
  /bin/ln -s /Applications "$DMG_ROOT/Applications"
  /usr/bin/hdiutil create \
    -volname "__APP__ ${SHORT_VERSION}" \
    -srcfolder "$DMG_ROOT" \
    -fs HFS+ -format UDZO -ov -quiet \
    "dist/__APP__-${SHORT_VERSION}.dmg"
  rm -rf "$DMG_ROOT"
  echo "› Packaged: dist/__APP__-${SHORT_VERSION}.dmg"
else
  DEST="/Applications/__APP__.app"
  echo "› Installing to $DEST"
  /usr/bin/pkill -x __APP__ 2>/dev/null || true
  /bin/sleep 0.3
  rm -rf "$DEST"
  /bin/mv "$APP" "$DEST"
  rm -rf "$STAGE"
  open "$DEST"
  echo "› Installed and launched: $DEST"
fi
