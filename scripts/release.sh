#!/bin/bash
# Tintify 一键发版：bump → 构建测试 → 主题名核对 → 敏感检查 → push
#                → DMG → tag + GitHub release → Homebrew tap → 本地安装
#
# 用法：bash scripts/release.sh <版本号> <release说明.md>
#   例：bash scripts/release.sh 1.9.5 /tmp/notes-1.9.5.md
#
# 说明文件格式即 gh release create --notes-file 的 markdown 正文。
set -euo pipefail
cd "$(dirname "$0")/.."

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
die() { echo -e "${RED}✗ $1${NC}"; exit 1; }
ok()  { echo -e "${GREEN}✓ $1${NC}"; }

VERSION="${1:-}"; NOTES="${2:-}"
[[ -n "$VERSION" && -n "$NOTES" ]] || die "用法：bash scripts/release.sh <版本号> <release说明.md>"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "版本号格式应为 x.y.z：$VERSION"
[[ -f "$NOTES" ]] || die "说明文件不存在：$NOTES"

# ── 前置检查 ─────────────────────────────────────────────
[[ "$(git branch --show-current)" == "main" ]] || die "必须在 main 分支发版"
[[ -z "$(git status --porcelain | grep -v '^??')" ]] || die "工作区有未提交改动"
gh auth status >/dev/null 2>&1 || die "gh 未认证，先跑 gh auth login"
git tag | grep -qx "v$VERSION" && die "tag v$VERSION 已存在"
ok "前置检查通过"

# ── bump 版本号（build 号自增）─────────────────────────────
BUILD=$(( $(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" Info.plist) + 1 ))
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" -c "Set :CFBundleVersion $BUILD" Info.plist
git add Info.plist
git commit -q -m "chore: bump version to $VERSION"
ok "版本号 $VERSION (build $BUILD)"

# ── 构建 + 测试 + 主题名核对 ─────────────────────────────
swift build >/dev/null || die "构建失败"
swift test >/dev/null 2>&1 || die "测试未通过"
ok "构建与测试通过"
FAILS=$(bash scripts/verify-theme-names.sh 2>&1 | grep -cE "✗|✘|FAIL|失败" || true)
[[ "$FAILS" == "0" ]] || die "主题名核对有 $FAILS 个失败项"
ok "主题名核对 0 失败"

# ── 敏感检查 + push ──────────────────────────────────────
if git ls-files | grep -qiE "CLAUDE|\.claude|superpowers|secret|stripe"; then
    die "检测到敏感文件进入版本库，中止"
fi
ok "敏感文件检查干净"
git push origin main
ok "已推送 main"

# ── DMG + tag + release ──────────────────────────────────
./scripts/dmg.sh >/dev/null || die "DMG 打包失败"
[[ -f "Tintify-$VERSION.dmg" && -f "Tintify-$VERSION.dmg.sha256" ]] || die "DMG 产物缺失"
ok "DMG 与 sha256 就绪"
git tag "v$VERSION" && git push origin "v$VERSION"
TITLE=$(head -1 "$NOTES" | sed 's/^#* *//')
gh release create "v$VERSION" "Tintify-$VERSION.dmg" "Tintify-$VERSION.dmg.sha256" \
    --title "Tintify v$VERSION — $TITLE" --notes-file "$NOTES"
ok "GitHub release 已发布"

# ── Homebrew tap ─────────────────────────────────────────
NEW_SHA=$(cut -d' ' -f1 "Tintify-$VERSION.dmg.sha256")
TMP_RB=$(mktemp)
gh api repos/notwin/homebrew-tap/contents/Casks/tintify.rb -q '.content' | base64 -d \
    | sed -E "s/version \"[0-9.]+\"/version \"$VERSION\"/; s/sha256 \"[a-f0-9]+\"/sha256 \"$NEW_SHA\"/" > "$TMP_RB"
grep -q "version \"$VERSION\"" "$TMP_RB" || die "cask 版本替换失败"
FILE_SHA=$(gh api repos/notwin/homebrew-tap/contents/Casks/tintify.rb -q '.sha')
gh api -X PUT repos/notwin/homebrew-tap/contents/Casks/tintify.rb \
    -f message="tintify $VERSION" -f content="$(base64 -i "$TMP_RB")" -f sha="$FILE_SHA" -q '.commit.sha' >/dev/null
rm -f "$TMP_RB"
ok "Homebrew tap 已更新"

# ── 本地安装并重启 ────────────────────────────────────────
pkill -9 -f Tintify.app 2>/dev/null || true
sleep 1
open /Applications/Tintify.app
ok "本地 app 已重启（$(defaults read /Applications/Tintify.app/Contents/Info.plist CFBundleShortVersionString)）"

echo ""
ok "v$VERSION 发版完成：https://github.com/notwin/Tintify/releases/tag/v$VERSION"
