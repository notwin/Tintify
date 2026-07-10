import Testing
import Foundation
@testable import Tintify

// MARK: - 生成器

@Test func tmThemeGeneratorMapsCoreScopes() throws {
    let theme = ThemeRegistry.shared.theme(id: "ink-vermilion")!
    let xml = TmThemeGenerator.generate(palette: theme.palette)

    // 必须是合法 plist
    let data = xml.data(using: .utf8)!
    let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
    let root = try #require(plist as? [String: Any])
    let settings = try #require(root["settings"] as? [[String: Any]])

    // 全局设置：背景/前景来自色板
    let global = try #require(settings.first?["settings"] as? [String: Any])
    #expect(global["background"] as? String == theme.palette.base)
    #expect(global["foreground"] as? String == theme.palette.text)

    // 核心 scope 映射（catppuccin 官方蓝本）：注释斜体、字符串绿、关键字 mauve
    func rule(containing scope: String) -> [String: Any]? {
        settings.first { ($0["scope"] as? String)?.contains(scope) == true }
    }
    let comment = try #require(rule(containing: "comment"))
    #expect((comment["settings"] as? [String: Any])?["foreground"] as? String == theme.palette.overlay2)
    #expect((comment["settings"] as? [String: Any])?["fontStyle"] as? String == "italic")

    let string = try #require(rule(containing: "string, punctuation.definition.string"))
    #expect((string["settings"] as? [String: Any])?["foreground"] as? String == theme.palette.green)

    // 关键字规则用显式空 fontStyle 切断继承（蓝本的 ∅ 语义）
    let keyword = try #require(rule(containing: "keyword,"))
    #expect((keyword["settings"] as? [String: Any])?["foreground"] as? String == theme.palette.mauve)
    #expect((keyword["settings"] as? [String: Any])?["fontStyle"] as? String == "")

    // diff scope 是 delta 的关键，必须带 .diff 完整后缀
    let inserted = try #require(rule(containing: "markup.inserted.diff"))
    #expect((inserted["settings"] as? [String: Any])?["foreground"] as? String == theme.palette.green)
    #expect(rule(containing: "markup.deleted.diff") != nil)
    #expect(rule(containing: "markup.changed.diff") != nil)
}

// MARK: - 安装器

@Test func tmThemeInstallerRebuildsOnlyOnChange() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).path
    var rebuilds = 0
    let installer = TmThemeInstaller(themesDir: tmpDir, rebuildCache: { rebuilds += 1 })

    let ink = ThemeRegistry.shared.theme(id: "ink-vermilion")!
    try installer.install(theme: ink)
    #expect(FileManager.default.fileExists(atPath: tmpDir + "/tintify.tmTheme"))
    #expect(rebuilds == 1)

    try installer.install(theme: ink)          // 内容没变，不重建
    #expect(rebuilds == 1)

    try installer.install(theme: ThemeRegistry.shared.theme(id: "soda-pop")!)  // 变了，重建
    #expect(rebuilds == 2)
}

// MARK: - 适配器接线

@Test func batUsesGeneratedThemeForPartialThemes() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let zshrc = tmpDir.appendingPathComponent(".zshrc").path
    try "# rc".write(toFile: zshrc, atomically: true, encoding: .utf8)

    let installer = TmThemeInstaller(themesDir: tmpDir.appendingPathComponent("themes").path, rebuildCache: {})
    let adapter = BatAdapter(installer: installer)
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "ink-vermilion")!, configPath: zshrc)

    let rc = try String(contentsOfFile: zshrc, encoding: .utf8)
    #expect(rc.contains("export BAT_THEME=\"tintify\""))       // 不再是 ansi
    #expect(FileManager.default.fileExists(atPath: tmpDir.appendingPathComponent("themes/tintify.tmTheme").path))
}

@Test func batKeepsBuiltinNameForFullThemes() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let zshrc = tmpDir.appendingPathComponent(".zshrc").path
    try "# rc".write(toFile: zshrc, atomically: true, encoding: .utf8)

    let installer = TmThemeInstaller(themesDir: tmpDir.appendingPathComponent("themes").path, rebuildCache: {})
    let adapter = BatAdapter(installer: installer)
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: zshrc)

    let rc = try String(contentsOfFile: zshrc, encoding: .utf8)
    #expect(rc.contains("export BAT_THEME=\"\(mocha.nameForTool("bat"))\""))
    #expect(!FileManager.default.fileExists(atPath: tmpDir.appendingPathComponent("themes/tintify.tmTheme").path))
}

@Test func batFallsBackToAnsiWhenInstallFails() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let zshrc = tmpDir.appendingPathComponent(".zshrc").path
    try "# rc".write(toFile: zshrc, atomically: true, encoding: .utf8)

    struct Boom: Error {}
    let installer = TmThemeInstaller(
        themesDir: tmpDir.appendingPathComponent("themes").path,
        rebuildCache: { throw Boom() }
    )
    let adapter = BatAdapter(installer: installer)
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "ink-vermilion")!, configPath: zshrc)

    let rc = try String(contentsOfFile: zshrc, encoding: .utf8)
    #expect(rc.contains("export BAT_THEME=\"ansi\""))          // 安装失败仍可用
}

// MARK: - 主题定义守护

@Test func partialThemesGenerateBatAndDelta() {
    for theme in ThemeRegistry.shared.allThemes where theme.compatibility != .full {
        #expect(theme.themeSource(for: .bat) == .generate(name: theme.name), "\(theme.id) 的 bat 应走生成")
        #expect(theme.themeSource(for: .delta) == .generate(name: theme.name), "\(theme.id) 的 delta 应走生成")
    }
    // 全兼容主题维持内置名
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    if case .generate = mocha.themeSource(for: .bat) {
        Issue.record("全兼容主题不应走生成")
    }
}
