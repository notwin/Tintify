// Sources/Adapters/ZshHighlightAdapter.swift
import Foundation

/// Adapter for zsh-syntax-highlighting.
///
/// This is a no-op adapter: zsh-syntax-highlighting reads colors
/// from the terminal's ANSI palette, so no config file is needed.
struct ZshHighlightAdapter: ToolAdapter {
    let toolName = "zsh-syntax-highlighting"

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.zshrc"
    }

    /// No-op: zsh-syntax-highlighting inherits ANSI colors from the terminal.
    ///
    /// Args:
    ///   theme: Unused.
    ///   configPath: Unused.
    func apply(theme: Theme, configPath: String? = nil) throws {
        // Intentionally empty — ANSI colors come from the terminal emulator.
    }
}
