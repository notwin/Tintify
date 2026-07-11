import Testing
import Foundation
@testable import Tintify

/// WCAG 相对亮度（塌缩守护用，不是严格 WCAG 审计）
private func luminance(_ hex: String) -> Double {
    let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    var v: UInt64 = 0
    Scanner(string: h).scanHexInt64(&v)
    func lin(_ c: Double) -> Double {
        let s = c / 255
        return s <= 0.03928 ? s / 12.92 : pow((s + 0.055) / 1.055, 2.4)
    }
    return 0.2126 * lin(Double((v & 0xFF0000) >> 16))
         + 0.7152 * lin(Double((v & 0x00FF00) >> 8))
         + 0.0722 * lin(Double(v & 0x0000FF))
}

private func contrastRatio(_ a: String, _ b: String) -> Double {
    let (hi, lo) = (max(luminance(a), luminance(b)), min(luminance(a), luminance(b)))
    return (hi + 0.05) / (lo + 0.05)
}

@Test func skinMapsPaletteSlots() {
    let theme = ThemeRegistry.shared.theme(id: "rose-pine")!
    let skin = ThemeSkin(theme: theme)
    #expect(skin.windowBg == theme.palette.base)
    #expect(skin.sidebarBg == theme.palette.mantle)
    #expect(skin.cardBg == theme.palette.surface0)
    #expect(skin.elevatedBg == theme.palette.surface1)
    #expect(skin.border == theme.palette.surface2)
    #expect(skin.textPrimary == theme.palette.text)
    #expect(skin.textSecondary == theme.palette.subtext0)
    #expect(skin.success == theme.palette.green)
    #expect(skin.danger == theme.palette.red)
}

@Test func skinAccentUsesThemeAccentAndMatchingInk() {
    // ink-vermilion 的 accent(#e34234) 是第 2 段胶囊 → ink 必须取那一段的 #fdf6ec
    let ink = ThemeSkin(theme: ThemeRegistry.shared.theme(id: "ink-vermilion")!)
    #expect(ink.accent == "#e34234")
    #expect(ink.accentInk == "#fdf6ec")
    // 无 accent 的主题回落到第 1 段渐变色
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    let skin = ThemeSkin(theme: mocha)
    #expect(skin.accent == mocha.promptSegments[0].color)
    #expect(skin.accentInk == mocha.promptSegments[0].ink)
}

@Test func allThemesProduceReadableSkins() {
    for theme in ThemeRegistry.shared.allThemes {
        let skin = ThemeSkin(theme: theme)
        // 所有 token 是合法 hex
        for token in [skin.windowBg, skin.sidebarBg, skin.cardBg, skin.elevatedBg,
                      skin.border, skin.textPrimary, skin.textSecondary,
                      skin.accent, skin.accentInk, skin.success, skin.danger] {
            #expect(token.wholeMatch(of: #/#[0-9a-fA-F]{6}/#) != nil,
                    "主题 \(theme.id) 有非法 token \(token)")
        }
        // 正文可读（28 套实测最低 ~4.9，阈值 4.0 防未来新主题塌缩）
        #expect(contrastRatio(skin.windowBg, skin.textPrimary) >= 4.0,
                "主题 \(theme.id) 正文对比度塌缩")
        // accent 底上的字可读（实测最低 ~3.2，阈值 2.5）
        #expect(contrastRatio(skin.accent, skin.accentInk) >= 2.5,
                "主题 \(theme.id) accent 字色塌缩")
        // 卡片必须能和窗口底区分（早前灰阶塌缩修复的守护）
        #expect(skin.cardBg.lowercased() != skin.windowBg.lowercased(),
                "主题 \(theme.id) cardBg 与 windowBg 塌缩")
    }
}

@Test func isLightMatchesThemeAppearance() {
    // 窗口 NSAppearance 的明暗判定必须与主题声明的深浅一致
    for theme in ThemeRegistry.shared.allThemes {
        let expected = theme.appearance == .light
        #expect(ThemeSkin.isLight(hex: theme.palette.base) == expected,
                "主题 \(theme.id) 的 base \(theme.palette.base) 明暗判定与 appearance 不符")
    }
}
