// Sources/Models/Theme.swift
import Foundation

/// Theme category for grouping in the UI. rawValue 是持久化标识（进 history.json），显示走 displayName。
enum ThemeCategory: String, Codable, Hashable, CaseIterable, Sendable {
    case popular, timeless, trending, original

    /// UI 显示名（Task 5 接入本地化后包 L()）。
    var displayName: String {
        switch self {
        case .popular: "热门推荐"
        case .timeless: "经典永恒"
        case .trending: "新锐之选"
        case .original: "Tintify 原创"
        }
    }

    /// 兼容旧版中文 rawValue（v1.8.0 及以前写入的 history.json）。
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        if let value = ThemeCategory(rawValue: raw) {
            self = value
            return
        }
        switch raw {
        case "热门推荐": self = .popular
        case "经典永恒": self = .timeless
        case "新锐之选": self = .trending
        case "Tintify 原创": self = .original
        default:
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "未知的主题分类：\(raw)"))
        }
    }
}

/// Tool compatibility level.
enum ThemeCompatibility: String, Codable, Hashable, Sendable {
    case full          // 所有工具都有原生命名主题
    case ansiPartial   // bat/delta 使用 ansi 回退
}

/// A color theme consisting of 26 named palette colors and metadata.
struct Theme: Identifiable, Codable, Hashable, Sendable {
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
    let promptSegments: [PromptSegment]

    enum Appearance: String, Codable, Hashable {
        case dark, light
    }

    /// 获取指定工具的主题名，不存在则回退到 name
    func nameForTool(_ tool: String) -> String {
        toolNames[tool] ?? name
    }
}

/// 某工具应如何获得这个主题：用内置主题名，还是由 Tintify 生成配色文件。
enum ToolThemeSource: Equatable {
    case builtin(name: String)
    case generate(name: String)
}

extension Theme {
    func themeSource(for tool: ToolID) -> ToolThemeSource {
        if let name = toolNames[tool.rawValue] { return .builtin(name: name) }
        if compatibility == .full { return .builtin(name: nameForTool(tool.rawValue)) }
        return .generate(name: nameForTool(tool.rawValue))
    }
}

/// starship 胶囊渐变的一段：段底色 + 段内文字色（ink 写入 palette 块备用）。
struct PromptSegment: Codable, Hashable, Sendable {
    let color: String
    let ink: String
}

/// The 26 semantic color slots shared by every theme.
struct Palette: Codable, Hashable, Sendable {
    let rosewater, flamingo, pink, mauve: String
    let red, maroon, peach, yellow: String
    let green, teal, sky, sapphire: String
    let blue, lavender: String
    let text, subtext1, subtext0: String
    let overlay2, overlay1, overlay0: String
    let surface2, surface1, surface0: String
    let base, mantle, crust: String
}
