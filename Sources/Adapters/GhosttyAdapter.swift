// Sources/Adapters/GhosttyAdapter.swift
import Foundation

/// Adapter for the Ghostty terminal emulator.
struct GhosttyAdapter: ToolAdapter {
    let toolName = "ghostty"

    var defaultConfigPath: String {
        NSHomeDirectory() + "/Library/Application Support/com.mitchellh.ghostty/config"
    }

    /// Write `theme = <id>` into the Ghostty config.
    ///
    /// Args:
    ///   theme: The theme to apply.
    ///   configPath: Optional override path.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath
        try ConfigWriter.replaceLine(
            in: path,
            prefix: "theme = ",
            newLine: "theme = \(theme.nameForTool(toolName))"
        )
    }
}
