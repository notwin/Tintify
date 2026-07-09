// Sources/Engine/ThemeDefinitions/TimelessThemes.swift
import Foundation

/// 经典永恒主题：Monokai + One Dark/Light + Gruvbox 2 + Nord
enum TimelessThemes {
    static let all: [Theme] = [
        Theme(
            id: "monokai", name: "Monokai", appearance: .dark,
            palette: Palette(
                rosewater: "#f92672", flamingo: "#f92672", pink: "#f92672", mauve: "#ae81ff",
                red: "#f92672", maroon: "#f92672", peach: "#fd971f", yellow: "#e6db74",
                green: "#a6e22e", teal: "#66d9ef", sky: "#66d9ef", sapphire: "#66d9ef",
                blue: "#66d9ef", lavender: "#ae81ff",
                text: "#f8f8f2", subtext1: "#e8e8e2", subtext0: "#d8d8d2",
                overlay2: "#75715e", overlay1: "#6a6a5e", overlay0: "#49483e",
                surface2: "#49483e", surface1: "#3e3d32", surface0: "#34342a",
                base: "#272822", mantle: "#221f22", crust: "#1a1a1a"),
            toolNames: ["ghostty": "Monokai Pro", "bat": "Monokai Extended", "delta": "Monokai Extended", "wezterm": "MonokaiPro (Gogh)"],
            category: .timeless,
            description: "Sublime Text 经典配色，鲜艳温暖的代名词", stars: nil,
            compatibility: .full, variants: nil),
        Theme(
            id: "one-dark", name: "One Dark", appearance: .dark,
            palette: Palette(
                rosewater: "#e06c75", flamingo: "#e06c75", pink: "#c678dd", mauve: "#c678dd",
                red: "#e06c75", maroon: "#be5046", peach: "#d19a66", yellow: "#e5c07b",
                green: "#98c379", teal: "#56b6c2", sky: "#56b6c2", sapphire: "#61afef",
                blue: "#61afef", lavender: "#c678dd",
                text: "#abb2bf", subtext1: "#9da5b4", subtext0: "#828997",
                overlay2: "#636d83", overlay1: "#5c6370", overlay0: "#4b5263",
                surface2: "#3e4452", surface1: "#353b45", surface0: "#2c313a",
                base: "#282c34", mantle: "#21252b", crust: "#1b1f23"),
            toolNames: ["ghostty": "Atom One Dark", "bat": "OneHalfDark", "delta": "OneHalfDark", "wezterm": "OneHalfDark"],
            category: .timeless,
            description: "Atom 编辑器经典暗色，干净专业的首选", stars: "4k",
            compatibility: .full, variants: ["one-light"]),
        Theme(
            id: "one-light", name: "One Light", appearance: .light,
            palette: Palette(
                rosewater: "#e45649", flamingo: "#e45649", pink: "#a626a4", mauve: "#a626a4",
                red: "#e45649", maroon: "#ca1243", peach: "#986801", yellow: "#c18401",
                green: "#50a14f", teal: "#0184bc", sky: "#0184bc", sapphire: "#4078f2",
                blue: "#4078f2", lavender: "#a626a4",
                text: "#383a42", subtext1: "#4e5058", subtext0: "#696c77",
                overlay2: "#8c8f98", overlay1: "#a0a1a7", overlay0: "#b4b5ba",
                surface2: "#d3d4d8", surface1: "#e5e5e6", surface0: "#efefef",
                base: "#fafafa", mantle: "#f0f0f0", crust: "#e5e5e5"),
            toolNames: ["ghostty": "Atom One Light", "bat": "OneHalfLight", "delta": "OneHalfLight", "wezterm": "OneHalfLight"],
            category: .timeless,
            description: "程序员最熟悉的浅色配色，清爽明亮", stars: nil,
            compatibility: .full, variants: ["one-dark"]),
        Theme(
            id: "gruvbox-dark", name: "Gruvbox Dark", appearance: .dark,
            palette: Palette(
                rosewater: "#d65d0e", flamingo: "#d65d0e", pink: "#d3869b", mauve: "#b16286",
                red: "#cc241d", maroon: "#fb4934", peach: "#d65d0e", yellow: "#d79921",
                green: "#98971a", teal: "#689d6a", sky: "#83a598", sapphire: "#458588",
                blue: "#458588", lavender: "#d3869b",
                text: "#ebdbb2", subtext1: "#d5c4a1", subtext0: "#bdae93",
                overlay2: "#a89984", overlay1: "#928374", overlay0: "#7c6f64",
                surface2: "#504945", surface1: "#3c3836", surface0: "#32302f",
                base: "#282828", mantle: "#1d2021", crust: "#1a1a1a"),
            toolNames: ["bat": "gruvbox-dark", "delta": "gruvbox-dark", "wezterm": "GruvboxDark"],
            category: .timeless,
            description: "复古暖色调，泥土质感的舒适配色", stars: "13k",
            compatibility: .full, variants: ["gruvbox-light"]),
        Theme(
            id: "gruvbox-light", name: "Gruvbox Light", appearance: .light,
            palette: Palette(
                rosewater: "#af3a03", flamingo: "#af3a03", pink: "#b16286", mauve: "#8f3f71",
                red: "#9d0006", maroon: "#cc241d", peach: "#af3a03", yellow: "#b57614",
                green: "#79740e", teal: "#427b58", sky: "#076678", sapphire: "#076678",
                blue: "#076678", lavender: "#8f3f71",
                text: "#3c3836", subtext1: "#504945", subtext0: "#665c54",
                overlay2: "#7c6f64", overlay1: "#928374", overlay0: "#a89984",
                surface2: "#d5c4a1", surface1: "#ebdbb2", surface0: "#f2e5bc",
                base: "#fbf1c7", mantle: "#f9f5d7", crust: "#f2e5bc"),
            toolNames: ["bat": "gruvbox-light", "delta": "gruvbox-light", "wezterm": "GruvboxLight"],
            category: .timeless,
            description: "Gruvbox 的浅色变体，温暖阳光感", stars: nil,
            compatibility: .full, variants: ["gruvbox-dark"]),
        Theme(
            id: "nord", name: "Nord", appearance: .dark,
            palette: Palette(
                rosewater: "#d08770", flamingo: "#d08770", pink: "#b48ead", mauve: "#b48ead",
                red: "#bf616a", maroon: "#bf616a", peach: "#d08770", yellow: "#ebcb8b",
                green: "#a3be8c", teal: "#8fbcbb", sky: "#88c0d0", sapphire: "#81a1c1",
                blue: "#5e81ac", lavender: "#b48ead",
                text: "#eceff4", subtext1: "#e5e9f0", subtext0: "#d8dee9",
                overlay2: "#4c566a", overlay1: "#434c5e", overlay0: "#3b4252",
                surface2: "#434c5e", surface1: "#3b4252", surface0: "#2e3440",
                base: "#2e3440", mantle: "#292e39", crust: "#242933"),
            toolNames: ["wezterm": "nord"], category: .timeless,
            description: "北极冰蓝色调，冷静克制的极简风格", stars: "6k",
            compatibility: .full, variants: nil),
    ]
}
