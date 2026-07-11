import Foundation
import Combine

/// 设置窗口的皮肤状态：当前主题 + 试穿态。
/// 试穿只染窗口——不碰 ThemeApplicationService、不碰菜单栏、不碰任何终端配置。
@MainActor
final class SkinModel: ObservableObject {
    /// 试穿中的主题（nil = 未试穿）。永不落盘。
    @Published var previewTheme: Theme?

    private var cancellable: AnyCancellable?

    init() {
        // 切主题 / 跟随系统外观变化时刷新窗口配色
        cancellable = AppSettings.shared.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
    }

    var currentTheme: Theme {
        ThemeRegistry.shared.theme(id: AppSettings.shared.currentThemeId)
            ?? ThemeRegistry.shared.allThemes[0]
    }

    var isPreviewing: Bool { previewTheme != nil }

    /// 窗口当前应穿的皮肤：试穿优先
    var skin: ThemeSkin { ThemeSkin(theme: previewTheme ?? currentTheme) }
}
