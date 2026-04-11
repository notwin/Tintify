// Sources/Engine/ThemeEngine.swift

import Foundation

/// Orchestrates applying a theme across all registered tool adapters.
@MainActor
final class ThemeEngine {
    let adapters: [ToolAdapter]
    let backupManager: BackupManager
    let pathOverrides: [String: String]

    /// All available adapter constructors — adapters are created on demand.
    static let adapterFactories: [() -> ToolAdapter] = [
        { GhosttyAdapter() },
        { StarshipAdapter() },
        { BatAdapter() },
        { FzfAdapter() },
        { DeltaAdapter() },
        { EzaAdapter() },
        { LazygitAdapter() },
        { ZshHighlightAdapter() },
        { TmuxAdapter() },
        { VimAdapter() },
        { WezTermAdapter() },
    ]

    /// Create a new engine.
    ///
    /// Args:
    ///     adapters: Tool adapters to apply themes to. Defaults to all built-in adapters (lazy-created).
    ///     backupManager: Manager used to snapshot configs before writing.
    ///     pathOverrides: Per-tool config path overrides keyed by ``ToolAdapter/toolName``.
    init(
        adapters: [ToolAdapter]? = nil,
        backupManager: BackupManager = BackupManager(),
        pathOverrides: [String: String] = [:]
    ) {
        self.adapters = adapters ?? Self.adapterFactories.map { $0() }
        self.backupManager = backupManager
        self.pathOverrides = pathOverrides
    }

    /// Apply a theme to every adapter, backing up affected config files first.
    @discardableResult
    func apply(theme: Theme) -> ApplyResult {
        // Backup — best effort
        let configPaths = adapters.map { adapter -> String in
            let settingsPath = AppSettings.shared.resolvedPath(for: adapter.toolName)
            return pathOverrides[adapter.toolName] ?? settingsPath ?? adapter.defaultConfigPath
        }
        let uniquePaths = Array(Set(configPaths))
        _ = try? backupManager.backup(files: uniquePaths)

        var toolResults: [ToolResult] = []

        for adapter in adapters {
            // Skip disabled tools
            if AppSettings.shared.disabledTools.contains(adapter.toolName) {
                toolResults.append(ToolResult(
                    toolName: adapter.toolName,
                    status: .skipped,
                    message: "已禁用",
                    configPath: ""
                ))
                continue
            }

            // Resolve path: explicit pathOverrides > user-set toolPaths > adapter default.
            let settingsPath = AppSettings.shared.resolvedPath(for: adapter.toolName)
            let resolvedConfigPath = pathOverrides[adapter.toolName] ?? settingsPath
            let path = resolvedConfigPath ?? adapter.defaultConfigPath
            do {
                try adapter.apply(theme: theme, configPath: resolvedConfigPath)
                toolResults.append(ToolResult(
                    toolName: adapter.toolName,
                    status: .success,
                    message: nil,
                    configPath: path
                ))
            } catch {
                toolResults.append(ToolResult(
                    toolName: adapter.toolName,
                    status: .failed,
                    message: error.localizedDescription,
                    configPath: path
                ))
            }
        }

        // 保存上一个主题 ID（仅当切换到不同主题时）
        if AppSettings.shared.currentThemeId != theme.id {
            AppSettings.shared.previousThemeId = AppSettings.shared.currentThemeId
        }
        AppSettings.shared.currentThemeId = theme.id

        return ApplyResult(
            theme: theme,
            timestamp: Date(),
            toolResults: toolResults
        )
    }
}
