#!/bin/bash
# 调试运行：把 debug 二进制装进最小 .app 壳再启动。
# 为什么：macOS 26 对菜单栏图标的宿主有打包/签名要求，
# 裸跑 .build/debug/Tintify 时状态栏图标会被系统扣下（parked off-screen）。
# 用法：bash scripts/dev-run.sh [--settings 等参数原样透传给 app]
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DEV_APP="$PROJECT_DIR/.build/dev/Tintify.app"

cd "$PROJECT_DIR"
swift build

rm -rf "$DEV_APP"
mkdir -p "$DEV_APP/Contents/MacOS" "$DEV_APP/Contents/Resources"
cp .build/debug/Tintify "$DEV_APP/Contents/MacOS/"
if [ -d ".build/debug/Tintify_Tintify.bundle" ]; then
    cp -r ".build/debug/Tintify_Tintify.bundle" "$DEV_APP/Contents/MacOS/"
fi
cp Info.plist "$DEV_APP/Contents/"
[ -f "AppIcon.icns" ] && cp AppIcon.icns "$DEV_APP/Contents/Resources/"

codesign --force --deep -s - "$DEV_APP" 2>/dev/null

pkill -9 -f Tintify 2>/dev/null || true
sleep 1
open "$DEV_APP" --args "$@"
echo "dev 版已启动：$DEV_APP（参数：$*）"
