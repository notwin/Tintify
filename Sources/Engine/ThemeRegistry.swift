// Sources/Engine/ThemeRegistry.swift
import Foundation

/// Singleton registry of all built-in color themes.
final class ThemeRegistry {
    static let shared = ThemeRegistry()

    /// All built-in themes.
    let allThemes: [Theme]

    private init() {
        allThemes = Self.builtInThemes()
    }

    /// Look up a theme by its identifier.
    func theme(id: String) -> Theme? {
        allThemes.first { $0.id == id }
    }

    /// Return themes matching the given appearance.
    func themes(for appearance: Theme.Appearance) -> [Theme] {
        allThemes.filter { $0.appearance == appearance }
    }

    // MARK: - Built-in Themes

    private static func builtInThemes() -> [Theme] {
        [
            // ── Catppuccin ──────────────────────────────────────────
            Theme(
                id: "catppuccin-mocha",
                name: "Catppuccin Mocha",
                appearance: .dark,
                palette: Palette(
                    rosewater: "#f5e0dc", flamingo: "#f2cdcd", pink: "#f5c2e7", mauve: "#cba6f7",
                    red: "#f38ba8", maroon: "#eba0ac", peach: "#fab387", yellow: "#f9e2af",
                    green: "#a6e3a1", teal: "#94e2d5", sky: "#89dceb", sapphire: "#74c7ec",
                    blue: "#89b4fa", lavender: "#b4befe",
                    text: "#cdd6f4", subtext1: "#bac2de", subtext0: "#a6adc8",
                    overlay2: "#9399b2", overlay1: "#7f849c", overlay0: "#6c7086",
                    surface2: "#585b70", surface1: "#45475a", surface0: "#313244",
                    base: "#1e1e2e", mantle: "#181825", crust: "#11111b"
                )
            ),
            Theme(
                id: "catppuccin-macchiato",
                name: "Catppuccin Macchiato",
                appearance: .dark,
                palette: Palette(
                    rosewater: "#f4dbd6", flamingo: "#f0c6c6", pink: "#f5bde6", mauve: "#c6a0f6",
                    red: "#ed8796", maroon: "#ee99a0", peach: "#f5a97f", yellow: "#eed49f",
                    green: "#a6da95", teal: "#8bd5ca", sky: "#91d7e3", sapphire: "#7dc4e4",
                    blue: "#8aadf4", lavender: "#b7bdf8",
                    text: "#cad3f5", subtext1: "#b8c0e0", subtext0: "#a5adcb",
                    overlay2: "#939ab7", overlay1: "#8087a2", overlay0: "#6e738d",
                    surface2: "#5b6078", surface1: "#494d64", surface0: "#363a4f",
                    base: "#24273a", mantle: "#1e2030", crust: "#181926"
                )
            ),
            Theme(
                id: "catppuccin-frappe",
                name: "Catppuccin Frappé",
                appearance: .dark,
                palette: Palette(
                    rosewater: "#f2d5cf", flamingo: "#eebebe", pink: "#f4b8e4", mauve: "#ca9ee6",
                    red: "#e78284", maroon: "#ea999c", peach: "#ef9f76", yellow: "#e5c890",
                    green: "#a6d189", teal: "#81c8be", sky: "#99d1db", sapphire: "#85c1dc",
                    blue: "#8caaee", lavender: "#babbf1",
                    text: "#c6d0f5", subtext1: "#b5bfe2", subtext0: "#a5adce",
                    overlay2: "#949cbb", overlay1: "#838ba7", overlay0: "#737994",
                    surface2: "#626880", surface1: "#51576d", surface0: "#414559",
                    base: "#303446", mantle: "#292c3c", crust: "#232634"
                )
            ),
            Theme(
                id: "catppuccin-latte",
                name: "Catppuccin Latte",
                appearance: .light,
                palette: Palette(
                    rosewater: "#dc8a78", flamingo: "#dd7878", pink: "#ea76cb", mauve: "#8839ef",
                    red: "#d20f39", maroon: "#e64553", peach: "#fe640b", yellow: "#df8e1d",
                    green: "#40a02b", teal: "#179299", sky: "#04a5e5", sapphire: "#209fb5",
                    blue: "#1e66f5", lavender: "#7287fd",
                    text: "#4c4f69", subtext1: "#5c5f77", subtext0: "#6c6f85",
                    overlay2: "#7c7f93", overlay1: "#8c8fa1", overlay0: "#9ca0b0",
                    surface2: "#acb0be", surface1: "#bcc0cc", surface0: "#ccd0da",
                    base: "#eff1f5", mantle: "#e6e9ef", crust: "#dce0e8"
                )
            ),

            // ── Tokyo Night ─────────────────────────────────────────
            Theme(
                id: "tokyo-night",
                name: "Tokyo Night",
                appearance: .dark,
                palette: Palette(
                    rosewater: "#f7768e", flamingo: "#f7768e", pink: "#bb9af7", mauve: "#bb9af7",
                    red: "#f7768e", maroon: "#f7768e", peach: "#ff9e64", yellow: "#e0af68",
                    green: "#9ece6a", teal: "#73daca", sky: "#7dcfff", sapphire: "#7aa2f7",
                    blue: "#7aa2f7", lavender: "#c0caf5",
                    text: "#c0caf5", subtext1: "#a9b1d6", subtext0: "#9aa5ce",
                    overlay2: "#565f89", overlay1: "#414868", overlay0: "#3b4261",
                    surface2: "#33374c", surface1: "#292e42", surface0: "#24283b",
                    base: "#1a1b26", mantle: "#16161e", crust: "#13131a"
                )
            ),
            Theme(
                id: "tokyo-night-light",
                name: "Tokyo Night Light",
                appearance: .light,
                palette: Palette(
                    rosewater: "#8c4351", flamingo: "#8c4351", pink: "#7847bd", mauve: "#7847bd",
                    red: "#8c4351", maroon: "#8c4351", peach: "#965027", yellow: "#8f5e15",
                    green: "#33635c", teal: "#33635c", sky: "#166775", sapphire: "#34548a",
                    blue: "#34548a", lavender: "#343b58",
                    text: "#343b58", subtext1: "#4c505e", subtext0: "#5a5f72",
                    overlay2: "#6e7191", overlay1: "#8990b3", overlay0: "#9699a3",
                    surface2: "#b4b5b9", surface1: "#c4c8da", surface0: "#d5d6db",
                    base: "#d5d6db", mantle: "#e1e2e7", crust: "#e9e9ec"
                )
            ),

            // ── Nord ────────────────────────────────────────────────
            Theme(
                id: "nord",
                name: "Nord",
                appearance: .dark,
                palette: Palette(
                    rosewater: "#d08770", flamingo: "#d08770", pink: "#b48ead", mauve: "#b48ead",
                    red: "#bf616a", maroon: "#bf616a", peach: "#d08770", yellow: "#ebcb8b",
                    green: "#a3be8c", teal: "#8fbcbb", sky: "#88c0d0", sapphire: "#81a1c1",
                    blue: "#5e81ac", lavender: "#b48ead",
                    text: "#eceff4", subtext1: "#e5e9f0", subtext0: "#d8dee9",
                    overlay2: "#4c566a", overlay1: "#434c5e", overlay0: "#3b4252",
                    surface2: "#434c5e", surface1: "#3b4252", surface0: "#2e3440",
                    base: "#2e3440", mantle: "#292e39", crust: "#242933"
                )
            ),

            // ── Gruvbox ─────────────────────────────────────────────
            Theme(
                id: "gruvbox-dark",
                name: "Gruvbox Dark",
                appearance: .dark,
                palette: Palette(
                    rosewater: "#d65d0e", flamingo: "#d65d0e", pink: "#d3869b", mauve: "#b16286",
                    red: "#cc241d", maroon: "#fb4934", peach: "#d65d0e", yellow: "#d79921",
                    green: "#98971a", teal: "#689d6a", sky: "#83a598", sapphire: "#458588",
                    blue: "#458588", lavender: "#d3869b",
                    text: "#ebdbb2", subtext1: "#d5c4a1", subtext0: "#bdae93",
                    overlay2: "#a89984", overlay1: "#928374", overlay0: "#7c6f64",
                    surface2: "#504945", surface1: "#3c3836", surface0: "#32302f",
                    base: "#282828", mantle: "#1d2021", crust: "#1a1a1a"
                )
            ),
            Theme(
                id: "gruvbox-light",
                name: "Gruvbox Light",
                appearance: .light,
                palette: Palette(
                    rosewater: "#af3a03", flamingo: "#af3a03", pink: "#b16286", mauve: "#8f3f71",
                    red: "#9d0006", maroon: "#cc241d", peach: "#af3a03", yellow: "#b57614",
                    green: "#79740e", teal: "#427b58", sky: "#076678", sapphire: "#076678",
                    blue: "#076678", lavender: "#8f3f71",
                    text: "#3c3836", subtext1: "#504945", subtext0: "#665c54",
                    overlay2: "#7c6f64", overlay1: "#928374", overlay0: "#a89984",
                    surface2: "#d5c4a1", surface1: "#ebdbb2", surface0: "#f2e5bc",
                    base: "#fbf1c7", mantle: "#f9f5d7", crust: "#f2e5bc"
                )
            ),

            // ── Dracula ─────────────────────────────────────────────
            Theme(
                id: "dracula",
                name: "Dracula",
                appearance: .dark,
                palette: Palette(
                    rosewater: "#ff79c6", flamingo: "#ff79c6", pink: "#ff79c6", mauve: "#bd93f9",
                    red: "#ff5555", maroon: "#ff6e6e", peach: "#ffb86c", yellow: "#f1fa8c",
                    green: "#50fa7b", teal: "#8be9fd", sky: "#8be9fd", sapphire: "#6272a4",
                    blue: "#6272a4", lavender: "#bd93f9",
                    text: "#f8f8f2", subtext1: "#e2e2dc", subtext0: "#bfbfb9",
                    overlay2: "#6272a4", overlay1: "#565a6e", overlay0: "#44475a",
                    surface2: "#44475a", surface1: "#383a4a", surface0: "#313241",
                    base: "#282a36", mantle: "#22232e", crust: "#1c1d27"
                )
            ),
        ]
    }
}
