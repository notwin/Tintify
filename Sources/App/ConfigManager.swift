// Sources/App/ConfigManager.swift
import Foundation
import AppKit
import UniformTypeIdentifiers

/// Handles export and import of Tintify configuration.
@MainActor
struct ConfigManager {

    struct TintifyConfig: Codable {
        let version: String
        let currentThemeId: String
        let darkThemeId: String
        let lightThemeId: String
        let followSystemAppearance: Bool
        let disabledTools: [String]
        let toolPaths: [String: String]
    }

    /// Export current settings to a user-chosen JSON file.
    static func exportConfig() {
        let settings = AppSettings.shared
        let config = TintifyConfig(
            version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            currentThemeId: settings.currentThemeId,
            darkThemeId: settings.darkThemeId,
            lightThemeId: settings.lightThemeId,
            followSystemAppearance: settings.followSystemAppearance,
            disabledTools: Array(settings.disabledTools),
            toolPaths: settings.toolPaths
        )

        guard let data = try? JSONEncoder().encode(config),
              let json = String(data: data, encoding: .utf8) else { return }

        let panel = NSSavePanel()
        panel.title = "导出 Tintify 配置"
        panel.nameFieldStringValue = "tintify-config.json"
        panel.allowedContentTypes = [.json]

        if panel.runModal() == .OK, let url = panel.url {
            try? json.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    /// Import settings from a user-chosen JSON file.
    static func importConfig() {
        let panel = NSOpenPanel()
        panel.title = "导入 Tintify 配置"
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false

        guard panel.runModal() == .OK, let url = panel.url else { return }

        guard let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(TintifyConfig.self, from: data) else { return }

        let settings = AppSettings.shared
        settings.currentThemeId = config.currentThemeId
        settings.darkThemeId = config.darkThemeId
        settings.lightThemeId = config.lightThemeId
        settings.followSystemAppearance = config.followSystemAppearance
        settings.disabledTools = Set(config.disabledTools)
        settings.toolPaths = config.toolPaths

        // Apply the imported theme
        if let theme = ThemeRegistry.shared.theme(id: config.currentThemeId) {
            let result = ThemeEngine().apply(theme: theme)
            NotificationManager.shared.notify(result: result)
        }
    }
}
