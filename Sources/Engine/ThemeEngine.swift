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
    @discardableResult
    func apply(theme: Theme) -> ApplyResult {
        NSLog("[Tintify] ThemeEngine.apply start: \(theme.id)")

        // Backup — best effort
        let configPaths = adapters.map { pathOverrides[$0.toolName] ?? $0.defaultConfigPath }
        let uniquePaths = Array(Set(configPaths))
        NSLog("[Tintify] backing up \(uniquePaths.count) paths")
        _ = try? backupManager.backup(files: uniquePaths)
        NSLog("[Tintify] backup done")

        var toolResults: [ToolResult] = []

        for adapter in adapters {
            let path = pathOverrides[adapter.toolName] ?? adapter.defaultConfigPath
            NSLog("[Tintify] applying to \(adapter.toolName) at \(path)")
            do {
                try adapter.apply(theme: theme, configPath: pathOverrides[adapter.toolName])
                NSLog("[Tintify] \(adapter.toolName): success")
                toolResults.append(ToolResult(
                    toolName: adapter.toolName,
                    status: .success,
                    message: nil,
                    configPath: path
                ))
            } catch {
                NSLog("[Tintify] \(adapter.toolName): FAILED - \(error)")
                toolResults.append(ToolResult(
                    toolName: adapter.toolName,
                    status: .failed,
                    message: error.localizedDescription,
                    configPath: path
                ))
            }
        }

        AppSettings.shared.currentThemeId = theme.id

        return ApplyResult(
            theme: theme,
            timestamp: Date(),
            toolResults: toolResults
        )
    }
}
