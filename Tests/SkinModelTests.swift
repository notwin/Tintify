import Testing
@testable import Tintify

// 注意：不写 UserDefaults，只读。currentTheme 是开发机真实设置，测试不依赖它是哪套。

@Test @MainActor func skinFollowsPreviewThenFallsBack() {
    let model = SkinModel()
    let caramel = ThemeRegistry.shared.theme(id: "caramel")!

    #expect(model.isPreviewing == false)
    #expect(model.skin == ThemeSkin(theme: model.currentTheme))

    model.previewTheme = caramel
    #expect(model.isPreviewing == true)
    #expect(model.skin == ThemeSkin(theme: caramel))
    #expect(model.skin.windowBg == "#211711")

    model.previewTheme = nil
    #expect(model.isPreviewing == false)
    #expect(model.skin == ThemeSkin(theme: model.currentTheme))
}

@Test @MainActor func currentThemeAlwaysResolves() {
    // currentThemeId 经 AppSettings 迁移兜底，必能在注册表找到；万一找不到回落第一套
    let model = SkinModel()
    #expect(ThemeRegistry.shared.theme(id: model.currentTheme.id) != nil)
}
