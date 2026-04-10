// Sources/Models/Theme.swift
import Foundation

/// Theme category for grouping in the UI.
enum ThemeCategory: String, Codable, Hashable, CaseIterable {
    case popular = "热门推荐"
    case timeless = "经典永恒"
    case trending = "新锐之选"
}

/// Tool compatibility level.
enum ThemeCompatibility: String, Codable, Hashable {
    case full          // 所有工具都有原生命名主题
    case ansiPartial   // bat/delta 使用 ansi 回退
}

/// A color theme consisting of 26 named palette colors and metadata.
struct Theme: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let appearance: Appearance
    let palette: Palette
    let toolNames: [String: String]
    let category: ThemeCategory
    let description: String
    let stars: String?
    let compatibility: ThemeCompatibility
    let variants: [String]?

    enum Appearance: String, Codable, Hashable {
        case dark, light
    }

    /// 获取指定工具的主题名，不存在则回退到 name
    func nameForTool(_ tool: String) -> String {
        toolNames[tool] ?? name
    }
}

/// The 26 semantic color slots shared by every theme.
struct Palette: Codable, Hashable {
    let rosewater, flamingo, pink, mauve: String
    let red, maroon, peach, yellow: String
    let green, teal, sky, sapphire: String
    let blue, lavender: String
    let text, subtext1, subtext0: String
    let overlay2, overlay1, overlay0: String
    let surface2, surface1, surface0: String
    let base, mantle, crust: String
}
