// Sources/Engine/ThemeDefinitions/OriginalThemes.swift
import Foundation

/// Tintify 原创主题
enum OriginalThemes {
    static let all: [Theme] = [
        // ── Neon City ───────────────────────────────────────────
        // 霓虹粉青风：雨夜东京，高饱和荧光色，粉+青+黄为主色调
        Theme(
            id: "neon-city",
            name: "Neon City",
            appearance: .dark,
            palette: Palette(
                rosewater: "#ff6ac1", flamingo: "#ff5c8a", pink: "#ff2d95", mauve: "#bd93f9",
                red: "#ff003c", maroon: "#e6003a", peach: "#ff9e64", yellow: "#f3f99d",
                green: "#72f1b8", teal: "#45fce5", sky: "#61e2ff", sapphire: "#36c5f0",
                blue: "#7aa2f7", lavender: "#b4a4ff",
                text: "#eef1ff", subtext1: "#c3c7e0", subtext0: "#9a9ec2",
                overlay2: "#6e7399", overlay1: "#565b80", overlay0: "#434868",
                surface2: "#353a5e", surface1: "#2a2f52", surface0: "#222747",
                base: "#1a1e3a", mantle: "#151831", crust: "#101228"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "赛博朋克霓虹街头，雨夜中的荧光色彩",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["neon-city-matrix", "neon-city-ember"]
        ),

        // ── Neon City Matrix ────────────────────────────────────
        // 绿色矩阵风：黑客帝国终端，绿色为绝对主色，黑底绿字
        Theme(
            id: "neon-city-matrix",
            name: "Neon City Matrix",
            appearance: .dark,
            palette: Palette(
                rosewater: "#7ce38b", flamingo: "#5fd068", pink: "#c177db", mauve: "#a580d0",
                red: "#f0465a", maroon: "#d93e50", peach: "#e8a44a", yellow: "#d4e05a",
                green: "#00ff41", teal: "#00d4aa", sky: "#4ac6e0", sapphire: "#3a9bcc",
                blue: "#4a8ae0", lavender: "#8a9ae0",
                text: "#b5e8b0", subtext1: "#8cc488", subtext0: "#6a9a68",
                overlay2: "#4a7048", overlay1: "#3a5838", overlay0: "#2e4830",
                surface2: "#243a24", surface1: "#1c2e1e", surface0: "#162618",
                base: "#0a160a", mantle: "#071007", crust: "#040a04"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "黑客帝国矩阵风，绿色代码雨中的数字世界",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["neon-city", "neon-city-ember"]
        ),

        // ── Neon City Ember ─────────────────────────────────────
        // 暖橙赛博朋克：Blade Runner 2049 沙漠废土，橙黄琥珀为主色调
        Theme(
            id: "neon-city-ember",
            name: "Neon City Ember",
            appearance: .dark,
            palette: Palette(
                rosewater: "#f0a070", flamingo: "#e88860", pink: "#e06090", mauve: "#c07acc",
                red: "#f04050", maroon: "#d83848", peach: "#ff8844", yellow: "#ffc04a",
                green: "#a0c060", teal: "#70b898", sky: "#80b8d0", sapphire: "#5898c0",
                blue: "#6088cc", lavender: "#a090d0",
                text: "#f0e0cc", subtext1: "#ccb8a0", subtext0: "#a89880",
                overlay2: "#887060", overlay1: "#705a4c", overlay0: "#5a483c",
                surface2: "#483828", surface1: "#3a2e22", surface0: "#30261c",
                base: "#261e16", mantle: "#1e1810", crust: "#18120c"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "废土余烬风，Blade Runner 式的橙黄琥珀色调",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["neon-city", "neon-city-matrix"]
        ),
    ]
}
