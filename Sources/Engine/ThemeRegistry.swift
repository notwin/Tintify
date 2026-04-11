// Sources/Engine/ThemeRegistry.swift
import Foundation

/// Singleton registry of all built-in color themes.
final class ThemeRegistry {
    static let shared = ThemeRegistry()

    /// All built-in themes.
    let allThemes: [Theme]

    private init() {
        allThemes = PopularThemes.all + TimelessThemes.all + TrendingThemes.all + OriginalThemes.all
    }

    /// Look up a theme by its identifier.
    func theme(id: String) -> Theme? {
        allThemes.first { $0.id == id }
    }

    /// Return themes matching the given appearance.
    func themes(for appearance: Theme.Appearance) -> [Theme] {
        allThemes.filter { $0.appearance == appearance }
    }

    /// Return themes matching the given category.
    func themes(for category: ThemeCategory) -> [Theme] {
        allThemes.filter { $0.category == category }
    }
}
