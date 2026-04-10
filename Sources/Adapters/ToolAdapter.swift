// Sources/Adapters/ToolAdapter.swift
import Foundation

/// Protocol that every CLI-tool adapter must conform to.
protocol ToolAdapter {
    /// Machine-readable tool identifier (e.g. "ghostty", "bat").
    var toolName: String { get }

    /// Default config file path when the user has not overridden it.
    var defaultConfigPath: String { get }

    /// Apply the given theme, writing to `configPath` (or `resolvedPath` if nil).
    ///
    /// Args:
    ///   theme: The theme to apply.
    ///   configPath: Optional override path; defaults to `resolvedPath`.
    func apply(theme: Theme, configPath: String?) throws

    /// Return `true` if the tool appears to be installed.
    func detectInstalled() -> Bool
}

extension ToolAdapter {
    /// Path resolved from user overrides or the adapter default.
    var resolvedPath: String {
        AppSettings.shared.resolvedPath(for: toolName) ?? defaultConfigPath
    }

    /// Default installation check: the resolved config file exists.
    func detectInstalled() -> Bool {
        FileManager.default.fileExists(atPath: resolvedPath)
    }
}
