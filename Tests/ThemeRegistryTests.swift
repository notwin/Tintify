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
    #expect(all.count == 25)
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
