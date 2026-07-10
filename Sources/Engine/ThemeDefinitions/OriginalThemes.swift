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

        // ── 霓虹落日 (Synthwave Sunset) ──────────────────────────
        // 赛博复古未来主义：合成器波霓虹粉紫蓝，落日沉入地平线
        // 高饱和霓虹强调色，深紫底色，张扬的怀旧未来感
        Theme(
            id: "synthwave-sunset",
            name: "霓虹落日",
            appearance: .dark,
            palette: Palette(
                rosewater: "#ff9de6", flamingo: "#ff8bd0", pink: "#ff7edb", mauve: "#b26df8",
                red: "#fe4450", maroon: "#f97e72", peach: "#ff8b39", yellow: "#fede5d",
                green: "#72f1b8", teal: "#36f9f6", sky: "#36f9f6", sapphire: "#5b4bc4",
                blue: "#6d77ff", lavender: "#c5b1f8",
                text: "#e4dcf7", subtext1: "#cbc3e3", subtext0: "#a99fc9",
                overlay2: "#857e9e", overlay1: "#6a6382", overlay0: "#544e68",
                surface2: "#443d58", surface1: "#37304a", surface0: "#2e2640",
                base: "#241b2f", mantle: "#1d1526", crust: "#16101d"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "落日沉入合成器波，赛博复古未来的高饱和霓虹",
            stars: nil,
            compatibility: .ansiPartial,
            variants: nil,
            promptSegments: [
                PromptSegment(color: "#fede5d", ink: "#241b2f"),
                PromptSegment(color: "#f97e72", ink: "#241b2f"),
                PromptSegment(color: "#ff7edb", ink: "#241b2f"),
                PromptSegment(color: "#b26df8", ink: "#241b2f"),
                PromptSegment(color: "#5b4bc4", ink: "#f0edfd"),
            ]
        ),

        // ── 磷光 (Phosphor Green) ────────────────────────────────
        // 老 CRT 显示器意象：单色磷光绿，从亮到暗走五档
        // red/maroon 用低饱和灼痕红维持错误语义，不破坏单色观感
        Theme(
            id: "phosphor-green",
            name: "磷光",
            appearance: .dark,
            palette: Palette(
                rosewater: "#eafbdd", flamingo: "#bdf3ab", pink: "#d6fbc4", mauve: "#8fd9a8",
                red: "#c96f5f", maroon: "#a85a4c", peach: "#c9e77a", yellow: "#d8f0a0",
                green: "#5fce62", teal: "#4fbf7e", sky: "#7fe0a8", sapphire: "#3aa869",
                blue: "#2fa64e", lavender: "#9ceb8b",
                text: "#86e29b", subtext1: "#74c987", subtext0: "#62b073",
                overlay2: "#4f9760", overlay1: "#3d7e4d", overlay0: "#2f653e",
                surface2: "#234c2f", surface1: "#1a3a24", surface0: "#12291a",
                base: "#0b120c", mantle: "#080e09", crust: "#050a06"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "老 CRT 的单色磷光绿，从亮到暗走五档的安静",
            stars: nil,
            compatibility: .ansiPartial,
            variants: nil,
            promptSegments: [
                PromptSegment(color: "#d6fbc4", ink: "#0b120c"),
                PromptSegment(color: "#9ceb8b", ink: "#0b120c"),
                PromptSegment(color: "#5fce62", ink: "#0b120c"),
                PromptSegment(color: "#2fa64e", ink: "#0b120c"),
                PromptSegment(color: "#176b39", ink: "#e7fbe9"),
            ]
        ),

        // ── 墨与朱 (Ink & Vermilion) ─────────────────────────────
        // 宣纸到浓墨的灰阶意境，只允许一枚朱印跳出来
        // green/blue 为极低饱和松绿/黛蓝，维持语义不夺墨色
        Theme(
            id: "ink-vermilion",
            name: "墨与朱",
            appearance: .dark,
            palette: Palette(
                rosewater: "#e8b4a8", flamingo: "#dfa08f", pink: "#d98a80", mauve: "#a89a90",
                red: "#e34234", maroon: "#c2382c", peach: "#d07850", yellow: "#c8b078",
                green: "#8a9a78", teal: "#7a9488", sky: "#8ba0a4", sapphire: "#6a8090",
                blue: "#5f7488", lavender: "#a09888",
                text: "#d8d2c4", subtext1: "#b8b2a4", subtext0: "#97917f",
                overlay2: "#7a746a", overlay1: "#635e54", overlay0: "#504b43",
                surface2: "#403c35", surface1: "#322f29", surface0: "#27241f",
                base: "#191713", mantle: "#141210", crust: "#0f0d0b"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "宣纸到浓墨的灰阶，只允许一枚朱印跳出来",
            stars: nil,
            compatibility: .ansiPartial,
            variants: nil,
            promptSegments: [
                PromptSegment(color: "#ece7da", ink: "#191713"),
                PromptSegment(color: "#e34234", ink: "#fdf6ec"),
                PromptSegment(color: "#b0a99b", ink: "#191713"),
                PromptSegment(color: "#7a746a", ink: "#f2efe8"),
                PromptSegment(color: "#403c35", ink: "#e8e3d7"),
            ],
            accent: "#e34234"  // 朱印：green/blue 全是灰调，朱红必须在 ls 里出场
        ),

        // ── 琉璃 (Jewel Tones) ───────────────────────────────────
        // 丝绒夜里的宝石切面：红宝、紫晶、蓝宝、翡翠，浓而不闹
        // 深紫底色衬托宝石般浓郁的高饱和强调色
        Theme(
            id: "jewel-tones",
            name: "琉璃",
            appearance: .dark,
            palette: Palette(
                rosewater: "#f9a8d4", flamingo: "#ef86bd", pink: "#e05e9e", mauve: "#8f4bbf",
                red: "#c9366b", maroon: "#a52d58", peach: "#e08a4e", yellow: "#d9b84a",
                green: "#12967f", teal: "#23b39a", sky: "#7dd3fc", sapphire: "#3f77e0",
                blue: "#4b86ef", lavender: "#b490e0",
                text: "#e6ddf2", subtext1: "#c9bedd", subtext0: "#a99cc0",
                overlay2: "#877a9e", overlay1: "#6a5f80", overlay0: "#544a66",
                surface2: "#423a52", surface1: "#342c42", surface0: "#281f35",
                base: "#17111f", mantle: "#120d19", crust: "#0d0913"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "丝绒夜里的宝石切面，浓而不闹",
            stars: nil,
            compatibility: .ansiPartial,
            variants: nil,
            promptSegments: [
                PromptSegment(color: "#c9366b", ink: "#fdf0f5"),
                PromptSegment(color: "#8f4bbf", ink: "#f8f0fd"),
                PromptSegment(color: "#3f77e0", ink: "#eef4fe"),
                PromptSegment(color: "#12967f", ink: "#e9fdf8"),
                PromptSegment(color: "#0c5c66", ink: "#e2f7fa"),
            ]
        ),

        // ── 焦糖 (Caramel) ───────────────────────────────────────
        // 奶泡到浓缩的暖棕单色阶，冬夜写代码的那杯
        // 浅色变体见 soda-pop：同一杯饮品的白天镜像
        Theme(
            id: "caramel",
            name: "焦糖",
            appearance: .dark,
            palette: Palette(
                rosewater: "#f0e0cb", flamingo: "#e6cdb0", pink: "#dfc0a8", mauve: "#b08968",
                red: "#c25e45", maroon: "#a04e3a", peach: "#d99a5b", yellow: "#e0b878",
                green: "#a0a065", teal: "#8f9a78", sky: "#b0a488", sapphire: "#8a7a5e",
                blue: "#9c8464", lavender: "#c4a888",
                text: "#e9d9c8", subtext1: "#cfbca6", subtext0: "#b29e87",
                overlay2: "#93816c", overlay1: "#786754", overlay0: "#614f3f",
                surface2: "#4b3c2e", surface1: "#3a2d21", surface0: "#2d2118",
                base: "#211711", mantle: "#1a110c", crust: "#120b07"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "奶泡到浓缩的暖棕单色阶，冬夜写代码的那杯",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["soda-pop"],
            promptSegments: [
                PromptSegment(color: "#f0e0cb", ink: "#211711"),
                PromptSegment(color: "#ddbd94", ink: "#211711"),
                PromptSegment(color: "#c39566", ink: "#211711"),
                PromptSegment(color: "#9c6b42", ink: "#faf2e8"),
                PromptSegment(color: "#64402a", ink: "#f3e6d8"),
            ]
        ),

        // ── 汽水 (Soda Pop) ──────────────────────────────────────
        // 柠檬蜜桃西瓜葡萄苏打，高糖气泡感的浅色
        // 深色变体见 caramel：同一杯饮品的夜晚镜像
        Theme(
            id: "soda-pop",
            name: "汽水",
            appearance: .light,
            palette: Palette(
                rosewater: "#e8896f", flamingo: "#f07a5e", pink: "#d81159", mauve: "#7048b6",
                red: "#ef476f", maroon: "#d81159", peach: "#f78c2a", yellow: "#cf9605",
                green: "#0f8a6d", teal: "#0aa08a", sky: "#118ab2", sapphire: "#0e6ba8",
                blue: "#2660c9", lavender: "#9a6fe0",
                text: "#574f68", subtext1: "#6a627c", subtext0: "#7d7590",
                overlay2: "#948da4", overlay1: "#aaa3b8", overlay0: "#beb8ca",
                surface2: "#d8d2e0", surface1: "#ece5ea", surface0: "#f5eee6",
                base: "#fffaf0", mantle: "#f7f0e4", crust: "#efe6d8"
            ),
            toolNames: [
                "bat": "ansi",
                "delta": "ansi",
            ],
            category: .original,
            description: "柠檬蜜桃西瓜葡萄苏打，高糖气泡感的浅色",
            stars: nil,
            compatibility: .ansiPartial,
            variants: ["caramel"],
            promptSegments: [
                PromptSegment(color: "#ffd166", ink: "#4a3305"),
                PromptSegment(color: "#ff9770", ink: "#4d2410"),
                PromptSegment(color: "#ff70a6", ink: "#4d1026"),
                PromptSegment(color: "#b388eb", ink: "#241243"),
                PromptSegment(color: "#118ab2", ink: "#f4fbff"),
            ]
        ),
    ]
}
