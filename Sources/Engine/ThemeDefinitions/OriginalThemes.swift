// Sources/Engine/ThemeDefinitions/OriginalThemes.swift
import Foundation

/// Tintify 原创主题
enum OriginalThemes {
    static let all: [Theme] = [
        // ── Neon City ───────────────────────────────────────────
        // 灵感来源：SynthWave '84
        // 80 年代合成波美学，粉紫霓虹 + 明亮青色，高饱和高对比
        Theme(
            id: "neon-city",
            name: "Neon City",
            appearance: .dark,
            palette: Palette(
                rosewater: "#ff7edb", flamingo: "#ff6bcb", pink: "#ff2daf", mauve: "#c792ea",
                red: "#fe4450", maroon: "#e53e5c", peach: "#f78c6c", yellow: "#fede5d",
                green: "#72f1b8", teal: "#03edf9", sky: "#03edf9", sapphire: "#36d7f7",
                blue: "#6796e6", lavender: "#c5a3ff",
                text: "#f0f0f0", subtext1: "#d4d4d8", subtext0: "#aeaeb5",
                overlay2: "#7e7e8a", overlay1: "#5e5e6a", overlay0: "#48485a",
                surface2: "#38384a", surface1: "#2d2d3f", surface0: "#242436",
                base: "#1b1b2f", mantle: "#161626", crust: "#10101e"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "80 年代合成波霓虹，粉紫青的梦幻迷离",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["neon-city-matrix", "neon-city-ember"]
        ),

        // ── Neon City Matrix ────────────────────────────────────
        // 灵感来源：Cyberpunk-Neon by Roboron3042
        // 深海蓝底色，青色前景，品红/紫色点缀，真正的黑客美学
        Theme(
            id: "neon-city-matrix",
            name: "Neon City Matrix",
            appearance: .dark,
            palette: Palette(
                rosewater: "#ea00d9", flamingo: "#d400c4", pink: "#ea00d9", mauve: "#711c91",
                red: "#ff0055", maroon: "#d40044", peach: "#f57800", yellow: "#f7c318",
                green: "#0abdc6", teal: "#0abdc6", sky: "#00e8c6", sapphire: "#008fb3",
                blue: "#123e7c", lavender: "#9b59b6",
                text: "#0abdc6", subtext1: "#08a0aa", subtext0: "#068088",
                overlay2: "#055a60", overlay1: "#044a50", overlay0: "#033a40",
                surface2: "#022a30", surface1: "#011e26", surface0: "#01161e",
                base: "#000b1e", mantle: "#000816", crust: "#00050e"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "深海黑客美学，青色数据流穿透暗蓝深渊",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["neon-city", "neon-city-ember"]
        ),

        // ── Neon City Ember ─────────────────────────────────────
        // 灵感来源：Amber CRT 终端 + Blade Runner
        // 纯黑底色，琥珀色前景，模拟老式 CRT 荧光屏的温暖辉光
        Theme(
            id: "neon-city-ember",
            name: "Neon City Ember",
            appearance: .dark,
            palette: Palette(
                rosewater: "#e8a060", flamingo: "#d48850", pink: "#cc6688", mauve: "#9977aa",
                red: "#c5301a", maroon: "#a82816", peach: "#e97801", yellow: "#dba400",
                green: "#13a10e", teal: "#3a8a5c", sky: "#3a96dd", sapphire: "#2878aa",
                blue: "#0037da", lavender: "#8866aa",
                text: "#e97801", subtext1: "#c86800", subtext0: "#a05800",
                overlay2: "#7a4800", overlay1: "#5c3800", overlay0: "#442a00",
                surface2: "#2e1e00", surface1: "#221600", surface0: "#1a1000",
                base: "#0c0c0c", mantle: "#080808", crust: "#040404"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "琥珀 CRT 终端，80 年代磷光屏的温暖余晖",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["neon-city", "neon-city-matrix"]
        ),
    ]
}
