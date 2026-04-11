// Sources/Engine/ThemeDefinitions/OriginalThemes.swift
import Foundation

/// Tintify 原创主题
enum OriginalThemes {
    static let all: [Theme] = [
        // ── Neon City ───────────────────────────────────────────
        // 灵感：Cyberdream + SynthWave '84
        // 纯白前景 + 高饱和霓虹强调色，粉紫青三色交织的赛博朋克美学
        Theme(
            id: "neon-city",
            name: "Neon City",
            appearance: .dark,
            palette: Palette(
                rosewater: "#ff7edb", flamingo: "#ff6bcb", pink: "#ff2daf", mauve: "#bd5eff",
                red: "#ff6e5e", maroon: "#e8555a", peach: "#ffbd5e", yellow: "#f1ff5e",
                green: "#5eff6c", teal: "#5ef1ff", sky: "#5ef1ff", sapphire: "#5ea1ff",
                blue: "#5ea1ff", lavender: "#c5a3ff",
                text: "#ffffff", subtext1: "#d4d4dc", subtext0: "#ababba",
                overlay2: "#7e7e8e", overlay1: "#5a5a6e", overlay0: "#46465a",
                surface2: "#363648", surface1: "#2c2c3e", surface0: "#232336",
                base: "#16181a", mantle: "#111114", crust: "#0c0c0f"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "纯白霓虹赛博朋克，高对比的荧光色彩爆发",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["neon-city-matrix", "neon-city-ember"]
        ),

        // ── Neon City Matrix ────────────────────────────────────
        // 灵感：Cyberdream 的高对比 + 绿色主导的赛博矩阵
        // 白色前景，绿/青色为主强调色，紫色为辅，深黑底色
        Theme(
            id: "neon-city-matrix",
            name: "Neon City Matrix",
            appearance: .dark,
            palette: Palette(
                rosewater: "#80ffea", flamingo: "#6be8d4", pink: "#e135ff", mauve: "#a16aff",
                red: "#ff5555", maroon: "#e04848", peach: "#ffb86c", yellow: "#f1fa8c",
                green: "#50fa7b", teal: "#80ffea", sky: "#80ffea", sapphire: "#5ebbff",
                blue: "#6272e6", lavender: "#b4a0ff",
                text: "#f0f0f0", subtext1: "#c8c8d0", subtext0: "#a0a0ae",
                overlay2: "#707080", overlay1: "#555566", overlay0: "#404052",
                surface2: "#303042", surface1: "#262638", surface0: "#1e1e30",
                base: "#0a0a14", mantle: "#06060e", crust: "#030308"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "数字矩阵风，翡翠绿与电光紫的暗夜交响",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["neon-city", "neon-city-ember"]
        ),

        // ── Neon City Ember ─────────────────────────────────────
        // 灵感：SilkCircuit + Blade Runner 暖色调
        // 浅灰白前景，橙/金/琥珀为主强调色，紫粉为辅，深棕底色
        Theme(
            id: "neon-city-ember",
            name: "Neon City Ember",
            appearance: .dark,
            palette: Palette(
                rosewater: "#ff9e80", flamingo: "#ff8a70", pink: "#ff6090", mauve: "#cc88dd",
                red: "#ff5544", maroon: "#e04a3a", peach: "#ff8830", yellow: "#ffcc44",
                green: "#88cc66", teal: "#66bbaa", sky: "#66aadd", sapphire: "#5588cc",
                blue: "#5580cc", lavender: "#aa88dd",
                text: "#e8e0d8", subtext1: "#c4bab0", subtext0: "#a09890",
                overlay2: "#7a7068", overlay1: "#605850", overlay0: "#4a4038",
                surface2: "#382e26", surface1: "#2e2420", surface0: "#261e1a",
                base: "#1a1410", mantle: "#14100c", crust: "#0e0a08"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "赛博废土余烬，琥珀与暖金在深棕夜色中燃烧",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["neon-city", "neon-city-matrix"]
        ),
    ]
}
