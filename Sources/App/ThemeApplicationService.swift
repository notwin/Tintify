// Sources/App/ThemeApplicationService.swift
import Foundation

/// 应用主题的唯一入口：快照设置 → 引擎 → 状态更新 → 历史 → 通知。
/// 所有 UI/CLI 调用点都走这里，保证行为一致。
@MainActor
enum ThemeApplicationService {
    /// 返回 nil 表示 themeId 不存在。
    @discardableResult
    static func apply(themeId: String) -> ApplyResult? {
        guard let theme = ThemeRegistry.shared.theme(id: themeId) else { return nil }
        return apply(theme: theme)
    }

    @discardableResult
    static func apply(theme: Theme) -> ApplyResult {
        let settings = AppSettings.shared
        let expandedPaths = settings.toolPaths.mapValues { ($0 as NSString).expandingTildeInPath }
        let engine = ThemeEngine(pathOverrides: expandedPaths, disabledTools: settings.disabledTools)
        let result = engine.apply(theme: theme)

        // 至少一个工具成功才算切换成功（语义自原 ThemeEngine 迁入）
        if result.successCount > 0 {
            if settings.currentThemeId != theme.id {
                settings.previousThemeId = settings.currentThemeId
            }
            settings.currentThemeId = theme.id
        }

        ApplyHistoryStore.shared.record(result)
        NotificationManager.shared.notify(result: result)
        return result
    }
}
