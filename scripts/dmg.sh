#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="Tintify"
VERSION=$(plutil -extract CFBundleShortVersionString raw "$PROJECT_DIR/Info.plist")
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
BUNDLE_PATH="$PROJECT_DIR/${APP_NAME}.app"
DMG_PATH="$PROJECT_DIR/$DMG_NAME"
STAGING_DIR="$PROJECT_DIR/.dmg-staging"

echo "=== Building Tintify v${VERSION} ==="

# Build bundle first
"$SCRIPT_DIR/bundle.sh"

echo "=== Creating DMG ==="

# Clean up
rm -rf "$STAGING_DIR" "$DMG_PATH"
mkdir -p "$STAGING_DIR"

# Copy app from /Applications (bundle.sh cleans up project dir copy)
cp -r "/Applications/${APP_NAME}.app" "$STAGING_DIR/"

# Create symlink to Applications
ln -s /Applications "$STAGING_DIR/Applications"

# Create DMG
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

# Clean up staging
rm -rf "$STAGING_DIR"

echo "=== Done ==="
echo "DMG created: $DMG_PATH"
echo "Size: $(ls -lh "$DMG_PATH" | awk '{print $5}')"
