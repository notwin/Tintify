// Sources/Engine/ThemeDefinitions/OriginalThemes.swift
import Foundation

/// Tintify 原创主题
enum OriginalThemes {
    static let all: [Theme] = [
        // ── Neon City ───────────────────────────────────────────
        // 赛博朋克：Cyberdream 风格，纯白前景 + 高饱和霓虹强调色
        // 粉紫青三色为主，深灰黑底色，张扬而锐利
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
            description: "赛博朋克霓虹，纯白底上的荧光色彩爆发",
            stars: nil,
            compatibility: .ansiPartial,
            variants: nil,
            promptSegments: [
                PromptSegment(color: "#ff2daf", ink: "#0c0c0f"),
                PromptSegment(color: "#bd5eff", ink: "#0c0c0f"),
                PromptSegment(color: "#5ea1ff", ink: "#0c0c0f"),
                PromptSegment(color: "#5ef1ff", ink: "#0c0c0f"),
                PromptSegment(color: "#5eff6c", ink: "#0c0c0f"),
            ]
        ),

        // ── 墨竹 (Ink Bamboo) ───────────────────────────────────
        // 中国水墨画意境：墨色底色，竹青/朱砂/赭石/靛蓝为强调色
        // 素雅沉静，低饱和度，文人风骨
        Theme(
            id: "ink-bamboo",
            name: "墨竹",
            appearance: .dark,
            palette: Palette(
                rosewater: "#c8827a", flamingo: "#b87070", pink: "#c46688", mauve: "#8878a8",
                red: "#c45040", maroon: "#a84438", peach: "#cc8844", yellow: "#c8a838",
                green: "#6a9a6a", teal: "#5a8a7a", sky: "#6888a0", sapphire: "#4a78a0",
                blue: "#4870a0", lavender: "#8880a8",
                text: "#d0ccc4", subtext1: "#b0aaa0", subtext0: "#908880",
                overlay2: "#706860", overlay1: "#585048", overlay0: "#484038",
                surface2: "#383028", surface1: "#2e2820", surface0: "#26201a",
                base: "#1c1814", mantle: "#161210", crust: "#100e0c"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "水墨文人风，竹青朱砂间的素雅沉静",
            stars: nil,
            compatibility: .ansiPartial,
            variants: nil,
            promptSegments: [
                PromptSegment(color: "#8878a8", ink: "#1c1814"),
                PromptSegment(color: "#c45040", ink: "#d0ccc4"),
                PromptSegment(color: "#cc8844", ink: "#1c1814"),
                PromptSegment(color: "#6a9a6a", ink: "#1c1814"),
                PromptSegment(color: "#4870a0", ink: "#d0ccc4"),
            ]
        ),

        // ── 极光 (Aurora) ───────────────────────────────────────
        // 北极光灵感：深蓝夜空底色，绿紫粉渐变的极光色彩
        // 冷色调为主，绿色是绝对主角，紫粉作为光晕点缀
        Theme(
            id: "aurora",
            name: "极光",
            appearance: .dark,
            palette: Palette(
                rosewater: "#e8a0b8", flamingo: "#d890a8", pink: "#e070a0", mauve: "#b080e0",
                red: "#e05070", maroon: "#c84860", peach: "#e0a070", yellow: "#d8c870",
                green: "#60e8a0", teal: "#50d8c0", sky: "#70c8e8", sapphire: "#5090d8",
                blue: "#4878d0", lavender: "#a088e0",
                text: "#e0e8f0", subtext1: "#b8c0d0", subtext0: "#9098b0",
                overlay2: "#687098", overlay1: "#505878", overlay0: "#404860",
                surface2: "#303850", surface1: "#283048", surface0: "#202840",
                base: "#141828", mantle: "#101420", crust: "#0c1018"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "北极光之夜，绿紫光晕在深蓝夜空中舞动",
            stars: nil,
            compatibility: .ansiPartial,
            variants: nil,
            promptSegments: [
                PromptSegment(color: "#60e8a0", ink: "#0c1018"),
                PromptSegment(color: "#50d8c0", ink: "#0c1018"),
                PromptSegment(color: "#70c8e8", ink: "#0c1018"),
                PromptSegment(color: "#a088e0", ink: "#0c1018"),
                PromptSegment(color: "#e070a0", ink: "#0c1018"),
            ]
        ),
    ]
}
