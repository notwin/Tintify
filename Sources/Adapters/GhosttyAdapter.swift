// Sources/Adapters/GhosttyAdapter.swift
import Foundation

/// Adapter for the Ghostty terminal emulator.
struct GhosttyAdapter: ToolAdapter {
    let toolName = "ghostty"

    var defaultConfigPath: String {
        NSHomeDirectory() + "/Library/Application Support/com.mitchellh.ghostty/config"
    }

    /// Custom themes directory for themes not built into Ghostty.
    private var customThemesDir: String {
        NSHomeDirectory() + "/.config/ghostty/themes"
    }

    /// Write `theme = <name>` into the Ghostty config.
    ///
    /// For themes without a Ghostty built-in (compatibility == .ansiPartial and no ghostty toolName),
    /// generates a custom theme file in ~/.config/ghostty/themes/.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath
        let themeName = theme.nameForTool(toolName)

        // If this is an original/custom theme (no built-in Ghostty theme), generate a theme file
        if theme.toolNames["ghostty"] == nil && theme.compatibility == .ansiPartial {
            try generateCustomTheme(theme: theme, name: themeName)
        }

        try ConfigWriter.replaceLine(
            in: path,
            prefix: "theme = ",
            newLine: "theme = \(themeName)"
        )
    }

    /// Generate a Ghostty custom theme file from the palette.
    private func generateCustomTheme(theme: Theme, name: String) throws {
        let fm = FileManager.default
        if !fm.fileExists(atPath: customThemesDir) {
            try fm.createDirectory(atPath: customThemesDir, withIntermediateDirectories: true)
        }

        let p = theme.palette
        // Map 26-color palette to Ghostty's 16-color ANSI palette
        let content = """
            palette = 0=\(p.crust)
            palette = 1=\(p.red)
            palette = 2=\(p.green)
            palette = 3=\(p.yellow)
            palette = 4=\(p.blue)
            palette = 5=\(p.pink)
            palette = 6=\(p.teal)
            palette = 7=\(p.subtext1)
            palette = 8=\(p.surface1)
            palette = 9=\(p.maroon)
            palette = 10=\(p.green)
            palette = 11=\(p.yellow)
            palette = 12=\(p.sapphire)
            palette = 13=\(p.mauve)
            palette = 14=\(p.sky)
            palette = 15=\(p.text)
            background = \(p.base)
            foreground = \(p.text)
            cursor-color = \(p.rosewater)
            cursor-text = \(p.base)
            selection-background = \(p.surface1)
            selection-foreground = \(p.text)
            """

        let themePath = (customThemesDir as NSString).appendingPathComponent(name)
        try ConfigWriter.atomicWrite(content, to: themePath)
    }
}
