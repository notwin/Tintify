#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="Tintify"
BUNDLE_NAME="${APP_NAME}.app"
BUNDLE_PATH="${PROJECT_DIR}/${BUNDLE_NAME}"

echo "=== Building Tintify (release) ==="
cd "$PROJECT_DIR"
swift build -c release

echo "=== Creating app bundle ==="
rm -rf "$BUNDLE_PATH"
mkdir -p "$BUNDLE_PATH/Contents/MacOS"
mkdir -p "$BUNDLE_PATH/Contents/Resources"

# Copy executable
cp .build/release/Tintify "$BUNDLE_PATH/Contents/MacOS/"

# Copy Info.plist
cp Info.plist "$BUNDLE_PATH/Contents/"

# Copy icon if exists
if [ -f "AppIcon.icns" ]; then
    cp AppIcon.icns "$BUNDLE_PATH/Contents/Resources/"
fi

echo "=== Signing (ad-hoc) ==="
codesign --force --deep -s - "$BUNDLE_PATH"

echo "=== Installing to /Applications ==="
# Kill running instance
pkill -9 -f Tintify 2>/dev/null || true
sleep 1

# Remove old installation
rm -rf "/Applications/${BUNDLE_NAME}"

# Copy to Applications
cp -r "$BUNDLE_PATH" /Applications/

# Install CLI tool
echo "=== Installing CLI ==="
ln -sf "$SCRIPT_DIR/tintify" /usr/local/bin/tintify

# Clean up project directory bundle to avoid Spotlight duplicates
rm -rf "$BUNDLE_PATH"

echo "=== Done ==="
echo "Installed to /Applications/${BUNDLE_NAME}"
echo "CLI installed to /usr/local/bin/tintify"
echo "Run: open /Applications/${BUNDLE_NAME}"
