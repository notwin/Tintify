// Sources/Adapters/GhosttyAdapter.swift
import Foundation

/// Adapter for the Ghostty terminal emulator.
struct GhosttyAdapter: ToolAdapter {
    let id: ToolID = .ghostty

    /// Custom themes directory for themes not built into Ghostty.
    let customThemesDir: String

    init(customThemesDir: String = NSHomeDirectory() + "/.config/ghostty/themes") {
        self.customThemesDir = customThemesDir
    }

    var defaultConfigPath: String {
        NSHomeDirectory() + "/Library/Application Support/com.mitchellh.ghostty/config"
    }

    func detectInstalled() -> Bool {
        FileManager.default.fileExists(atPath: defaultConfigPath)
    }

    /// Write `theme = <name>` into the Ghostty config.
    ///
    /// When `theme.themeSource(for: .ghostty)` resolves to `.generate`, a custom theme file
    /// is written to ~/.config/ghostty/themes/ first.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath

        switch theme.themeSource(for: .ghostty) {
        case .generate(let name):
            try generateCustomTheme(theme: theme, name: name)
            try ConfigWriter.replaceLine(in: path, prefix: "theme = ", newLine: "theme = \(name)")
        case .builtin(let name):
            try ConfigWriter.replaceLine(in: path, prefix: "theme = ", newLine: "theme = \(name)")
        }
    }

    /// Generate a Ghostty custom theme file from the palette.
    private func generateCustomTheme(theme: Theme, name: String) throws {
        let fm = FileManager.default
        if !fm.fileExists(atPath: customThemesDir) {
            try fm.createDirectory(atPath: customThemesDir, withIntermediateDirectories: true)
        }

        let p = theme.palette
        // 16 色 ANSI 槽位统一走 AnsiPalette（三个终端生成器共用）
        let ansi = AnsiPalette.colors(for: theme)
        let paletteLines = ansi.enumerated()
            .map { "palette = \($0.offset)=\($0.element)" }
            .joined(separator: "\n")
        let content = """
            \(paletteLines)
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
