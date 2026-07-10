#!/bin/bash
# 发版前核对全部主题的 toolNames 是否真实存在于各工具的主题列表。
# 数据源自 app registry（cli themes-json），永不与代码漂移。
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BINARY="$PROJECT_DIR/.build/debug/Tintify"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
FAIL=0

[ -x "$BINARY" ] || { echo "先运行 swift build"; exit 1; }
THEMES_JSON=$("$BINARY" cli themes-json)

find_tool() {  # 与 ToolDetection.binSearchPaths 一致
    for dir in /opt/homebrew/bin /usr/local/bin /usr/bin /bin; do
        [ -x "$dir/$1" ] && { echo "$dir/$1"; return 0; }
    done
    return 1
}

check_tool() {  # $1=工具键 $2=主题列表输出
    local tool="$1" list="$2"
    while IFS=$'\t' read -r theme_id name; do
        if echo "$list" | grep -qF "$name"; then
            echo -e "  ${GREEN}✓${NC} $theme_id → $name"
        else
            echo -e "  ${RED}✗ $theme_id → '$name' 不在 $tool 主题列表${NC}"
            FAIL=1
        fi
    done < <(echo "$THEMES_JSON" | /usr/bin/python3 -c "
import json, sys
entries = json.load(sys.stdin)
for e in entries:
    name = e['toolNames'].get('$tool')
    if name:
        print(f\"{e['id']}\t{name}\")
")
}

echo "== ghostty =="
if GHOSTTY=$(find_tool ghostty) || GHOSTTY="/Applications/Ghostty.app/Contents/MacOS/ghostty"; [ -x "$GHOSTTY" ]; then
    check_tool ghostty "$("$GHOSTTY" +list-themes 2>/dev/null)"
else echo -e "${YELLOW}SKIP：未安装${NC}"; fi

echo "== bat =="
if BAT=$(find_tool bat); then
    check_tool bat "$("$BAT" --list-themes 2>/dev/null)"
else echo -e "${YELLOW}SKIP：未安装${NC}"; fi

echo "== delta =="
if DELTA=$(find_tool delta); then
    check_tool delta "$("$DELTA" --show-syntax-themes 2>/dev/null)"
else echo -e "${YELLOW}SKIP：未安装${NC}"; fi

echo "== wezterm =="
echo -e "${YELLOW}无 list 命令，需人工对照 https://wezterm.org/colorschemes/${NC}"

exit $FAIL
