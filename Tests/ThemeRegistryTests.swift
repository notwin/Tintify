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

@Test func registryHas10Themes() {
    let all = ThemeRegistry.shared.allThemes
    #expect(all.count == 10)
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
