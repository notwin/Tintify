import Testing
import Foundation
@testable import Tintify

private func makeOttyEnv() throws -> (config: String, themesDir: String) {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return (dir.appendingPathComponent("config.toml").path, dir.appendingPathComponent("themes").path)
}

@Test func ottyGeneratesThemeFileAndSetsBothKeys() throws {
    let env = try makeOttyEnv()
    try "theme = \"Rosé Pine\"\ntheme-dark = \"Nord\"\n".write(toFile: env.config, atomically: true, encoding: .utf8)

    let adapter = OttyAdapter(themesDir: env.themesDir)
    let theme = ThemeRegistry.shared.theme(id: "nord")!
    try adapter.apply(theme: theme, configPath: env.config)

    let themeFile = env.themesDir + "/tintify-nord.ottytheme"
    #expect(FileManager.default.fileExists(atPath: themeFile))
    let themeContent = try String(contentsOfFile: themeFile, encoding: .utf8)
    #expect(themeContent.contains("name = \"tintify-nord\""))
    #expect(themeContent.contains("mode = \"dark\""))
    #expect(themeContent.contains("background = \"\(theme.palette.base)\""))
    #expect(themeContent.contains("\"\(theme.palette.red)\""))

    let config = try String(contentsOfFile: env.config, encoding: .utf8)
    #expect(config.contains("theme = \"tintify-nord\""))
    #expect(config.contains("theme-dark = \"tintify-nord\""))
}

@Test func ottyRemovesActiveOverridesKeepsComments() throws {
    let env = try makeOttyEnv()
    let existing = """
    theme = "Rosé Pine"
    foreground = "#e0def4"
    background = "#191724"
    palette-0 = "#26233a"
    # palette-1 = "#f38ba8" (reset to default)
    palette-15 = "#1a1412"
    language = "chinese"
    """
    try existing.write(toFile: env.config, atomically: true, encoding: .utf8)

    let adapter = OttyAdapter(themesDir: env.themesDir)
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: env.config)

    let config = try String(contentsOfFile: env.config, encoding: .utf8)
    #expect(!config.contains("foreground = \"#e0def4\""))              // 活跃覆盖删除
    #expect(!config.contains("palette-0 = ") && !config.contains("palette-15 = "))
    #expect(config.contains("# palette-1 = \"#f38ba8\""))              // 注释行保留
    #expect(config.contains("language = \"chinese\""))                 // 其他配置保留
}

@Test func ottyThemeFileUpdatedOnSecondApply() throws {
    let env = try makeOttyEnv()
    let adapter = OttyAdapter(themesDir: env.themesDir)
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: env.config)
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "dracula")!, configPath: env.config)

    let config = try String(contentsOfFile: env.config, encoding: .utf8)
    #expect(config.contains("theme = \"tintify-dracula\""))
    #expect(!config.contains("tintify-nord\""))  // config 引用已切换（旧主题文件保留无碍）
}
