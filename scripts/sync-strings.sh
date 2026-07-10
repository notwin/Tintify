#!/bin/bash
# 从 en.lproj/Localizable.strings 派生 zh-Hans 副本（值 = key）。
# 手动只维护 en 文件；每次改动后跑本脚本。
set -euo pipefail
SRC="$(dirname "$0")/../Sources/Resources/en.lproj/Localizable.strings"
DST_DIR="$(dirname "$0")/../Sources/Resources/zh-Hans.lproj"
mkdir -p "$DST_DIR"
sed -E 's/^("((\\.|[^"\\])*)") = ".*";$/\1 = \1;/' "$SRC" > "$DST_DIR/Localizable.strings"
echo "zh-Hans/Localizable.strings regenerated ($(grep -c ' = ' "$DST_DIR/Localizable.strings") keys)"
