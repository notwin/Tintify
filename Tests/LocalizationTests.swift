import Testing
import Foundation
@testable import Tintify

@Test func stringCatalogProvidesEnglishTranslations() throws {
    #expect(Bundle.module.localizations.contains("en"))
    // 用 en.lproj 的编译产物直接取一条种子字符串的英译
    let enPath = try #require(Bundle.module.path(forResource: "en", ofType: "lproj"))
    let enBundle = try #require(Bundle(path: enPath))
    let translated = enBundle.localizedString(forKey: "热门推荐", value: nil, table: nil)
    #expect(translated == "Popular")
}

@Test func appLayerStringsHaveEnglishTranslations() throws {
    let enPath = try #require(Bundle.module.path(forResource: "en", ofType: "lproj"))
    let enBundle = try #require(Bundle(path: enPath))

    #expect(enBundle.localizedString(forKey: "已禁用", value: nil, table: nil) == "Disabled")
    #expect(enBundle.localizedString(forKey: "主题切换失败", value: nil, table: nil) == "Theme switch failed")
    #expect(enBundle.localizedString(forKey: "校验失败，已中止更新", value: nil, table: nil) == "Checksum mismatch, update aborted")
}

@Test func settingsPaneTitleHasEnglishTranslation() throws {
    let enPath = try #require(Bundle.module.path(forResource: "en", ofType: "lproj"))
    let enBundle = try #require(Bundle(path: enPath))

    #expect(enBundle.localizedString(forKey: "通用", value: nil, table: nil) == "General")
}

@Test func themeDescriptionHasEnglishTranslation() throws {
    let enPath = try #require(Bundle.module.path(forResource: "en", ofType: "lproj"))
    let enBundle = try #require(Bundle(path: enPath))

    let translated = enBundle.localizedString(forKey: "北极冰蓝色调，冷静克制的极简风格", value: nil, table: nil)
    #expect(translated == "Arctic ice-blue tones — a calm, restrained minimalist style")
}
