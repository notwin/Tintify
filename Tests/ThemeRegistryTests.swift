// Tests/ThemeRegistryTests.swift
import Testing
@testable import Tintify

@Test func themeHas26Colors() {
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")
    #expect(mocha != nil)
    #expect(mocha!.name == "Catppuccin Mocha")
    #expect(mocha!.appearance == .dark)
    #expect(mocha!.palette.base == "#1e1e2e")
    #expect(mocha!.palette.text == "#cdd6f4")
    #expect(mocha!.palette.red == "#f38ba8")
}

@Test func registryHas25Themes() {
    let all = ThemeRegistry.shared.allThemes
    #expect(all.count == 31)
}

@Test func darkAndLightThemesExist() {
    let dark = ThemeRegistry.shared.themes(for: .dark)
    let light = ThemeRegistry.shared.themes(for: .light)
    #expect(dark.count >= 6)
    #expect(light.count >= 3)
}

@Test func themeHasCategoryAndDescription() {
    let theme = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    #expect(theme.category == .popular)
    #expect(!theme.description.isEmpty)
    #expect(theme.compatibility == .full)
}

@Test func themesGroupedByCategory() {
    let grouped = ThemeRegistry.shared.themes(for: .popular)
    #expect(grouped.count >= 5)
}

@Test func trendingThemesHaveAnsiPartial() {
    let trending = ThemeRegistry.shared.themes(for: .trending)
    let ansiThemes = trending.filter { $0.compatibility == .ansiPartial }
    #expect(ansiThemes.count >= 7)
}

@Test func verifiedToolNamesAreNotRegressed() throws {
    let registry = ThemeRegistry.shared
    #expect(registry.theme(id: "solarized-dark")?.toolNames["ghostty"] == "Solarized Dark Patched")
    #expect(registry.theme(id: "solarized-light")?.toolNames["ghostty"] == "iTerm2 Solarized Light")
    #expect(registry.theme(id: "rose-pine")?.toolNames["ghostty"] == "Rose Pine")
    #expect(registry.theme(id: "rose-pine-moon")?.toolNames["ghostty"] == "Rose Pine Moon")
    #expect(registry.theme(id: "rose-pine-dawn")?.toolNames["ghostty"] == "Rose Pine Dawn")
    #expect(registry.theme(id: "gruvbox-dark")?.toolNames["wezterm"] == "GruvboxDark")
    #expect(registry.theme(id: "gruvbox-light")?.toolNames["wezterm"] == "GruvboxLight")
}

@Test func everyThemeHasFivePromptSegmentsWithValidHex() throws {
    for theme in ThemeRegistry.shared.allThemes {
        #expect(theme.promptSegments.count == 5, "主题 \(theme.id) 的渐变段数不是 5")
        for seg in theme.promptSegments {
            #expect(seg.color.wholeMatch(of: #/#[0-9a-fA-F]{6}/#) != nil, "主题 \(theme.id) 渐变色 \(seg.color) 非法")
            #expect(seg.ink.wholeMatch(of: #/#[0-9a-fA-F]{6}/#) != nil, "主题 \(theme.id) 字色 \(seg.ink) 非法")
        }
    }
}

@Test func registryHasSixNewOriginalThemes() throws {
    let registry = ThemeRegistry.shared
    #expect(registry.allThemes.count == 31)
    for id in ["synthwave-sunset", "phosphor-green", "ink-vermilion", "jewel-tones", "caramel", "soda-pop"] {
        let theme = registry.theme(id: id)
        #expect(theme != nil, "缺少新主题 \(id)")
        #expect(theme?.category == .original)
        #expect(theme?.compatibility == .ansiPartial)
        #expect(theme?.toolNames["bat"] == "ansi")
    }
    #expect(registry.theme(id: "caramel")?.variants == ["soda-pop"])
    #expect(registry.theme(id: "soda-pop")?.variants == ["caramel"])
    #expect(registry.theme(id: "soda-pop")?.appearance == .light)
}

@Test func themeSourceDistinguishesBuiltinFromGenerated() {
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!   // .full、无 ghostty 键
    let neon = ThemeRegistry.shared.theme(id: "neon-city")!            // 原创
    let monokai = ThemeRegistry.shared.theme(id: "monokai")!           // 有显式 ghostty 名

    #expect(monokai.themeSource(for: .ghostty) == .builtin(name: "Monokai Pro"))
    #expect(mocha.themeSource(for: .ghostty) == .builtin(name: mocha.nameForTool("ghostty")))
    #expect(neon.themeSource(for: .ghostty) == .generate(name: neon.nameForTool("ghostty")))
    #expect(neon.themeSource(for: .wezterm) == .generate(name: neon.nameForTool("wezterm")))

    // 全量不变量：原创主题对依赖主题名的工具必须走 generate
    for theme in ThemeRegistry.shared.allThemes where theme.category == .original {
        if case .builtin = theme.themeSource(for: .ghostty) {
            Issue.record("原创主题 \(theme.id) 不应对 ghostty 用内置名")
        }
    }
}
