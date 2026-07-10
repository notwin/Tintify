import Testing
import Foundation
@testable import Tintify

private func luminance(_ hex: String) -> Double {
    let r = Double(Int(hex.dropFirst().prefix(2), radix: 16) ?? 0)
    let g = Double(Int(hex.dropFirst(3).prefix(2), radix: 16) ?? 0)
    let b = Double(Int(hex.dropFirst(5).prefix(2), radix: 16) ?? 0)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
}

@Test func ansiGrayscaleSlotsFollowAppearance() {
    // ANSI 黑/白槽必须在任何主题的背景上可见且方向正确：
    // 深色主题黑槽比背景亮；浅色主题黑槽是深色、白槽是浅灰
    for theme in ThemeRegistry.shared.allThemes {
        let slots = AnsiPalette.colors(for: theme)
        #expect(slots.count == 16)
        let bg = luminance(theme.palette.base)
        #expect(slots[0] != theme.palette.base, "\(theme.id) 槽0 == 背景")
        if theme.appearance == .dark {
            #expect(luminance(slots[0]) > bg, "\(theme.id) 深色黑槽应比背景亮")
            #expect(luminance(slots[8]) > luminance(slots[0]), "\(theme.id) 亮黑应比黑亮")
        } else {
            #expect(luminance(slots[0]) < bg, "\(theme.id) 浅色黑槽应是深色")
            #expect(luminance(slots[8]) < bg, "\(theme.id) 浅色亮黑应是深色")
            #expect(luminance(slots[7]) > luminance(slots[0]), "\(theme.id) 白槽应比黑槽亮")
        }
    }
}

@Test func generatorsShareAnsiPalette() throws {
    // ghostty / otty / wezterm 的 16 色必须来自同一构建器（此前槽 0/8 三家分叉）
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let theme = ThemeRegistry.shared.theme(id: "soda-pop")!   // 浅色，验证分支
    let slots = AnsiPalette.colors(for: theme)

    let ghosttyDir = tmpDir.appendingPathComponent("ghostty-themes").path
    let ghostty = GhosttyAdapter(customThemesDir: ghosttyDir)
    let ghosttyConfig = tmpDir.appendingPathComponent("ghostty-config").path
    try "theme = x".write(toFile: ghosttyConfig, atomically: true, encoding: .utf8)
    try ghostty.apply(theme: theme, configPath: ghosttyConfig)
    let ghosttyTheme = try String(contentsOfFile: ghosttyDir + "/\(theme.name)", encoding: .utf8)
    #expect(ghosttyTheme.contains("palette = 0=\(slots[0])"))
    #expect(ghosttyTheme.contains("palette = 8=\(slots[8])"))
    #expect(ghosttyTheme.contains("palette = 15=\(slots[15])"))

    let ottyThemes = tmpDir.appendingPathComponent("otty-themes").path
    let otty = OttyAdapter(themesDir: ottyThemes)
    try otty.apply(theme: theme, configPath: tmpDir.appendingPathComponent("otty.toml").path)
    let ottyTheme = try String(contentsOfFile: ottyThemes + "/tintify-\(theme.id).ottytheme", encoding: .utf8)
    #expect(ottyTheme.contains("\"\(slots[0])\", \"\(slots[1])\""))
    #expect(ottyTheme.contains("\"\(slots[8])\", \"\(slots[9])\""))

    let wezConfig = tmpDir.appendingPathComponent("wezterm.lua").path
    try "local config = {}\nreturn config\n".write(toFile: wezConfig, atomically: true, encoding: .utf8)
    try WezTermAdapter().apply(theme: theme, configPath: wezConfig)
    let wez = try String(contentsOfFile: wezConfig, encoding: .utf8)
    #expect(wez.contains("ansi = {\"\(slots[0])\""))
    #expect(wez.contains("brights = {\"\(slots[8])\""))
}
