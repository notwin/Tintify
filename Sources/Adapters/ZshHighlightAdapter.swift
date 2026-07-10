// Sources/Adapters/ZshHighlightAdapter.swift
import Foundation

/// Adapter for zsh-syntax-highlighting.
///
/// This is a no-op adapter: zsh-syntax-highlighting reads colors
/// from the terminal's ANSI palette, so no config file is needed.
struct ZshHighlightAdapter: ToolAdapter {
    let id: ToolID = .zshSyntaxHighlighting

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.zshrc"
    }

    func detectInstalled() -> Bool {
        FileManager.default.fileExists(atPath: "/opt/homebrew/share/zsh-syntax-highlighting")
            || FileManager.default.fileExists(atPath: "/usr/local/share/zsh-syntax-highlighting")
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
