import Testing
import Foundation
@testable import Tintify

private func tmpConf(_ content: String) throws -> String {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".conf")
    try content.write(to: tmp, atomically: true, encoding: .utf8)
    return tmp.path
}

@Test func kittyWritesColorsInMarkerBlock() throws {
    let path = try tmpConf("""
    font_family JetBrainsMono Nerd Font
    font_size 14
    """)
    let theme = ThemeRegistry.shared.theme(id: "nord")!
    try KittyAdapter().apply(theme: theme, configPath: path)

    let content = try String(contentsOfFile: path, encoding: .utf8)
    #expect(content.contains("# === TINTIFY START ==="))
    #expect(content.contains("foreground \(theme.palette.text)"))
    #expect(content.contains("background \(theme.palette.base)"))
    #expect(content.contains("cursor \(theme.palette.rosewater)"))
    #expect(content.contains("cursor_text_color \(theme.palette.base)"))
    #expect(content.contains("selection_background \(theme.palette.surface1)"))
    #expect(content.contains("selection_foreground \(theme.palette.text)"))
    let ansi = AnsiPalette.colors(for: theme)
    for i in 0..<16 {
        #expect(content.contains("color\(i) \(ansi[i])"))
    }
    // 用户已有配置不动
    #expect(content.contains("font_family JetBrainsMono Nerd Font"))
}

@Test func kittyCreatesFileWhenMissing() throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let path = dir.appendingPathComponent("kitty.conf").path

    try KittyAdapter().apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: path)

    let content = try String(contentsOfFile: path, encoding: .utf8)
    #expect(content.contains("# === TINTIFY START ==="))
    #expect(content.contains("# === TINTIFY END ==="))
}

@Test func kittyReplacesExistingBlock() throws {
    let path = try tmpConf("""
    font_size 14
    # === TINTIFY START ===
    background #000000
    # === TINTIFY END ===
    """)
    let theme = ThemeRegistry.shared.theme(id: "dracula")!
    try KittyAdapter().apply(theme: theme, configPath: path)

    let content = try String(contentsOfFile: path, encoding: .utf8)
    #expect(!content.contains("#000000"))
    #expect(content.components(separatedBy: "TINTIFY START").count == 2)
    #expect(content.contains("background \(theme.palette.base)"))
}
