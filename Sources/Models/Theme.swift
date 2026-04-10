// Sources/Models/Theme.swift
import Foundation

/// A color theme consisting of 26 named palette colors and metadata.
struct Theme: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let appearance: Appearance
    let palette: Palette

    enum Appearance: String, Codable, Hashable {
        case dark, light
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
