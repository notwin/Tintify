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
