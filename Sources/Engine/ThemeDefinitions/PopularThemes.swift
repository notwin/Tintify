// Sources/Engine/ThemeDefinitions/PopularThemes.swift
import Foundation

/// 热门推荐主题：Catppuccin 4 + Dracula + Solarized 2
enum PopularThemes {
    static let all: [Theme] = [
        Theme(
            id: "catppuccin-mocha", name: "Catppuccin Mocha", appearance: .dark,
            palette: Palette(
                rosewater: "#f5e0dc", flamingo: "#f2cdcd", pink: "#f5c2e7", mauve: "#cba6f7",
                red: "#f38ba8", maroon: "#eba0ac", peach: "#fab387", yellow: "#f9e2af",
                green: "#a6e3a1", teal: "#94e2d5", sky: "#89dceb", sapphire: "#74c7ec",
                blue: "#89b4fa", lavender: "#b4befe",
                text: "#cdd6f4", subtext1: "#bac2de", subtext0: "#a6adc8",
                overlay2: "#9399b2", overlay1: "#7f849c", overlay0: "#6c7086",
                surface2: "#585b70", surface1: "#45475a", surface0: "#313244",
                base: "#1e1e2e", mantle: "#181825", crust: "#11111b"),
            toolNames: [:], category: .popular,
            description: "最受欢迎的柔和暖色方案，低对比护眼", stars: "18.8k",
            compatibility: .full, variants: ["catppuccin-macchiato", "catppuccin-frappe", "catppuccin-latte"]),
        Theme(
            id: "catppuccin-macchiato", name: "Catppuccin Macchiato", appearance: .dark,
            palette: Palette(
                rosewater: "#f4dbd6", flamingo: "#f0c6c6", pink: "#f5bde6", mauve: "#c6a0f6",
                red: "#ed8796", maroon: "#ee99a0", peach: "#f5a97f", yellow: "#eed49f",
                green: "#a6da95", teal: "#8bd5ca", sky: "#91d7e3", sapphire: "#7dc4e4",
                blue: "#8aadf4", lavender: "#b7bdf8",
                text: "#cad3f5", subtext1: "#b8c0e0", subtext0: "#a5adcb",
                overlay2: "#939ab7", overlay1: "#8087a2", overlay0: "#6e738d",
                surface2: "#5b6078", surface1: "#494d64", surface0: "#363a4f",
                base: "#24273a", mantle: "#1e2030", crust: "#181926"),
            toolNames: [:], category: .popular,
            description: "Catppuccin 的中高对比变体", stars: nil,
            compatibility: .full, variants: ["catppuccin-mocha", "catppuccin-frappe", "catppuccin-latte"]),
        Theme(
            id: "catppuccin-frappe", name: "Catppuccin Frappe", appearance: .dark,
            palette: Palette(
                rosewater: "#f2d5cf", flamingo: "#eebebe", pink: "#f4b8e4", mauve: "#ca9ee6",
                red: "#e78284", maroon: "#ea999c", peach: "#ef9f76", yellow: "#e5c890",
                green: "#a6d189", teal: "#81c8be", sky: "#99d1db", sapphire: "#85c1dc",
                blue: "#8caaee", lavender: "#babbf1",
                text: "#c6d0f5", subtext1: "#b5bfe2", subtext0: "#a5adce",
                overlay2: "#949cbb", overlay1: "#838ba7", overlay0: "#737994",
                surface2: "#626880", surface1: "#51576d", surface0: "#414559",
                base: "#303446", mantle: "#292c3c", crust: "#232634"),
            toolNames: [:], category: .popular,
            description: "Catppuccin 的中等对比变体", stars: nil,
            compatibility: .full, variants: ["catppuccin-mocha", "catppuccin-macchiato", "catppuccin-latte"]),
        Theme(
            id: "catppuccin-latte", name: "Catppuccin Latte", appearance: .light,
            palette: Palette(
                rosewater: "#dc8a78", flamingo: "#dd7878", pink: "#ea76cb", mauve: "#8839ef",
                red: "#d20f39", maroon: "#e64553", peach: "#fe640b", yellow: "#df8e1d",
                green: "#40a02b", teal: "#179299", sky: "#04a5e5", sapphire: "#209fb5",
                blue: "#1e66f5", lavender: "#7287fd",
                text: "#4c4f69", subtext1: "#5c5f77", subtext0: "#6c6f85",
                overlay2: "#7c7f93", overlay1: "#8c8fa1", overlay0: "#9ca0b0",
                surface2: "#acb0be", surface1: "#bcc0cc", surface0: "#ccd0da",
                base: "#eff1f5", mantle: "#e6e9ef", crust: "#dce0e8"),
            toolNames: [:], category: .popular,
            description: "Catppuccin 唯一的浅色方案，柔和优雅", stars: nil,
            compatibility: .full, variants: ["catppuccin-mocha", "catppuccin-macchiato", "catppuccin-frappe"]),
        Theme(
            id: "dracula", name: "Dracula", appearance: .dark,
            palette: Palette(
                rosewater: "#ff79c6", flamingo: "#ff79c6", pink: "#ff79c6", mauve: "#bd93f9",
                red: "#ff5555", maroon: "#ff6e6e", peach: "#ffb86c", yellow: "#f1fa8c",
                green: "#50fa7b", teal: "#8be9fd", sky: "#8be9fd", sapphire: "#6272a4",
                blue: "#6272a4", lavender: "#bd93f9",
                text: "#f8f8f2", subtext1: "#e2e2dc", subtext0: "#bfbfb9",
                overlay2: "#6272a4", overlay1: "#565a6e", overlay0: "#44475a",
                surface2: "#44475a", surface1: "#383a4a", surface0: "#313241",
                base: "#282a36", mantle: "#22232e", crust: "#1c1d27"),
            toolNames: [:], category: .popular,
            description: "高对比鲜艳配色，紫粉绿的经典组合", stars: "23.2k",
            compatibility: .full, variants: nil),
        Theme(
            id: "solarized-dark", name: "Solarized Dark", appearance: .dark,
            palette: Palette(
                rosewater: "#dc322f", flamingo: "#dc322f", pink: "#d33682", mauve: "#6c71c4",
                red: "#dc322f", maroon: "#cb4b16", peach: "#cb4b16", yellow: "#b58900",
                green: "#859900", teal: "#2aa198", sky: "#2aa198", sapphire: "#268bd2",
                blue: "#268bd2", lavender: "#6c71c4",
                text: "#839496", subtext1: "#93a1a1", subtext0: "#839496",
                overlay2: "#657b83", overlay1: "#586e75", overlay0: "#073642",
                surface2: "#073642", surface1: "#002b36", surface0: "#002b36",
                base: "#002b36", mantle: "#001e26", crust: "#001419"),
            toolNames: ["ghostty": "Solarized Dark - Patched", "bat": "Solarized (dark)", "delta": "Solarized (dark)"],
            category: .popular,
            description: "终端配色始祖，科学设计的精准色彩关系", stars: "15.8k",
            compatibility: .full, variants: ["solarized-light"]),
        Theme(
            id: "solarized-light", name: "Solarized Light", appearance: .light,
            palette: Palette(
                rosewater: "#dc322f", flamingo: "#dc322f", pink: "#d33682", mauve: "#6c71c4",
                red: "#dc322f", maroon: "#cb4b16", peach: "#cb4b16", yellow: "#b58900",
                green: "#859900", teal: "#2aa198", sky: "#2aa198", sapphire: "#268bd2",
                blue: "#268bd2", lavender: "#6c71c4",
                text: "#657b83", subtext1: "#586e75", subtext0: "#657b83",
                overlay2: "#93a1a1", overlay1: "#839496", overlay0: "#eee8d5",
                surface2: "#eee8d5", surface1: "#fdf6e3", surface0: "#fdf6e3",
                base: "#fdf6e3", mantle: "#fdf6e3", crust: "#eee8d5"),
            toolNames: ["ghostty": "Solarized Light - Patched", "bat": "Solarized (light)", "delta": "Solarized (light)"],
            category: .popular,
            description: "最经典的浅色方案，温暖底色舒适阅读", stars: nil,
            compatibility: .full, variants: ["solarized-dark"]),
    ]
}
