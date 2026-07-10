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

    private static func showError(_ message: String) {
        Log.engine.error("\(message)")
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .warning
        alert.runModal()
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
              let json = String(data: data, encoding: .utf8) else {
            showError("导出失败：配置编码错误")
            return
        }

        let panel = NSSavePanel()
        panel.title = "导出 Tintify 配置"
        panel.nameFieldStringValue = "tintify-config.json"
        panel.allowedContentTypes = [.json]

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try json.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                showError("导出失败：\(error.localizedDescription)")
            }
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
              let config = try? JSONDecoder().decode(TintifyConfig.self, from: data) else {
            showError("导入失败：文件格式无效")
            return
        }

        let registry = ThemeRegistry.shared
        for themeId in [config.currentThemeId, config.darkThemeId, config.lightThemeId] {
            guard registry.theme(id: themeId) != nil else {
                showError("导入失败：配置引用了不存在的主题 \(themeId)")
                return
            }
        }

        let settings = AppSettings.shared
        settings.darkThemeId = config.darkThemeId
        settings.lightThemeId = config.lightThemeId
        settings.followSystemAppearance = config.followSystemAppearance
        settings.disabledTools = Set(config.disabledTools)
        settings.toolPaths = config.toolPaths

        // Apply the imported theme
        ThemeApplicationService.apply(themeId: config.currentThemeId)
    }
}
