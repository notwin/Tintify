// Sources/Engine/ThemeDefinitions/OriginalThemes.swift
import Foundation

/// Tintify 原创主题
enum OriginalThemes {
    static let all: [Theme] = [
        // ── Neon City ───────────────────────────────────────────
        // 赛博朋克：雨夜霓虹街头，深紫黑底色配高饱和荧光色
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
            variants: ["neon-city-haze", "neon-city-dawn"]
        ),

        // ── Neon City Haze ──────────────────────────────────────
        // 更暗更沉，雾霾笼罩的城市，色彩偏冷
        Theme(
            id: "neon-city-haze",
            name: "Neon City Haze",
            appearance: .dark,
            palette: Palette(
                rosewater: "#d4619a", flamingo: "#c9527e", pink: "#d42a7d", mauve: "#9d7cd8",
                red: "#d4003a", maroon: "#b80032", peach: "#d4855a", yellow: "#c8cc82",
                green: "#5cc99a", teal: "#3ad0bc", sky: "#50bdd6", sapphire: "#2da3ca",
                blue: "#6688d4", lavender: "#9588d4",
                text: "#c8cbde", subtext1: "#a6a9c0", subtext0: "#8488a6",
                overlay2: "#5e6280", overlay1: "#4a4e6b", overlay0: "#3a3e58",
                surface2: "#2e324c", surface1: "#252942", surface0: "#1e2239",
                base: "#171a30", mantle: "#121528", crust: "#0d0f20"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "雾霾笼罩的赛博都市，冷峻深沉的暗色调",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["neon-city", "neon-city-dawn"]
        ),

        // ── Neon City Dawn ──────────────────────────────────────
        // 赛博朋克的黎明，底色偏深蓝，暖光渗入
        Theme(
            id: "neon-city-dawn",
            name: "Neon City Dawn",
            appearance: .dark,
            palette: Palette(
                rosewater: "#ffa0c8", flamingo: "#ff87a8", pink: "#ff5a9e", mauve: "#c9a4f7",
                red: "#ff4466", maroon: "#e63d5a", peach: "#ffb07a", yellow: "#ffe0a0",
                green: "#88e8b0", teal: "#60dfc8", sky: "#78d4f0", sapphire: "#5bb8e0",
                blue: "#8ab4f8", lavender: "#c4b8ff",
                text: "#f0eef8", subtext1: "#ccc8e0", subtext0: "#a8a4c2",
                overlay2: "#7a78a0", overlay1: "#62608a", overlay0: "#4e4c72",
                surface2: "#3c3a5e", surface1: "#322f52", surface0: "#282648",
                base: "#1e1c3e", mantle: "#181636", crust: "#12102e"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "赛博朋克黎明，暗夜中渗入的第一缕暖光",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["neon-city", "neon-city-haze"]
        ),
    ]
}
