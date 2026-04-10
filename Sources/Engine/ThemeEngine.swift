// Sources/Engine/ThemeEngine.swift

import Foundation

/// Orchestrates applying a theme across all registered tool adapters.
final class ThemeEngine {
    let adapters: [ToolAdapter]
    let backupManager: BackupManager
    let pathOverrides: [String: String]

    /// Create a new engine.
    ///
    /// Args:
    ///     adapters: Tool adapters to apply themes to. Defaults to all built-in adapters.
    ///     backupManager: Manager used to snapshot configs before writing.
    ///     pathOverrides: Per-tool config path overrides keyed by ``ToolAdapter/toolName``.
    init(
        adapters: [ToolAdapter]? = nil,
        backupManager: BackupManager = BackupManager(),
        pathOverrides: [String: String] = [:]
    ) {
        self.adapters = adapters ?? [
            GhosttyAdapter(),
            StarshipAdapter(),
            BatAdapter(),
            FzfAdapter(),
            DeltaAdapter(),
            EzaAdapter(),
            LazygitAdapter(),
            ZshHighlightAdapter(),
        ]
        self.backupManager = backupManager
        self.pathOverrides = pathOverrides
    }

    /// Apply a theme to every adapter, backing up affected config files first.
    ///
    /// Args:
    ///     theme: The theme to apply across all tools.
    ///
    /// Raises:
    ///     Any file-system or adapter error encountered during application.
    func apply(theme: Theme) throws {
        let configPaths = adapters.map { pathOverrides[$0.toolName] ?? $0.defaultConfigPath }
        let uniquePaths = Array(Set(configPaths))
        _ = try backupManager.backup(files: uniquePaths)

        for adapter in adapters {
            let path = pathOverrides[adapter.toolName]
            try adapter.apply(theme: theme, configPath: path)
        }

        AppSettings.shared.currentThemeId = theme.id
    }
}
