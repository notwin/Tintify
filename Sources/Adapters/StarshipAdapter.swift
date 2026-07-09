// Sources/Adapters/StarshipAdapter.swift
import Foundation

/// Adapter for the Starship prompt.
struct StarshipAdapter: ToolAdapter {
    let toolName = "starship"

    /// Palette names Tintify itself generates (built-in theme ids). Only
    /// `[palettes.*]` sections whose name is in this set — or matches the
    /// palette being applied — are removed; anything else is user-authored
    /// and must be preserved.
    let knownPaletteNames: Set<String>

    init(knownPaletteNames: Set<String> = []) {
        self.knownPaletteNames = knownPaletteNames
    }

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.config/starship.toml"
    }

    /// Write palette reference and color definitions into starship.toml.
    ///
    /// Args:
    ///   theme: The theme to apply.
    ///   configPath: Optional override path.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath
        let paletteName = theme.id.replacingOccurrences(of: "-", with: "_")

        // Set the palette reference line (must sit in the TOML top-level area,
        // before the first [section] — replaceLine would append to EOF and
        // silently land inside the last section).
        try ConfigWriter.replaceTopLevelKey(
            in: path,
            key: "palette",
            line: "palette = \"\(paletteName)\""
        )

        // Remove only Tintify-known [palettes.*] sections to avoid accumulation,
        // preserving any user-authored palettes.
        try removeKnownPaletteSections(in: path, currentPaletteName: paletteName)

        // Build the palette section with all 26 colors.
        let p = theme.palette
        let section = """
            [palettes.\(paletteName)]
            rosewater = "\(p.rosewater)"
            flamingo = "\(p.flamingo)"
            pink = "\(p.pink)"
            mauve = "\(p.mauve)"
            red = "\(p.red)"
            maroon = "\(p.maroon)"
            peach = "\(p.peach)"
            yellow = "\(p.yellow)"
            green = "\(p.green)"
            teal = "\(p.teal)"
            sky = "\(p.sky)"
            sapphire = "\(p.sapphire)"
            blue = "\(p.blue)"
            lavender = "\(p.lavender)"
            text = "\(p.text)"
            subtext1 = "\(p.subtext1)"
            subtext0 = "\(p.subtext0)"
            overlay2 = "\(p.overlay2)"
            overlay1 = "\(p.overlay1)"
            overlay0 = "\(p.overlay0)"
            surface2 = "\(p.surface2)"
            surface1 = "\(p.surface1)"
            surface0 = "\(p.surface0)"
            base = "\(p.base)"
            mantle = "\(p.mantle)"
            crust = "\(p.crust)"
            """

        try ConfigWriter.replaceTOMLSection(
            in: path,
            sectionPrefix: "[palettes.\(paletteName)]",
            newContent: section
        )
    }

    /// Remove [palettes.*] sections whose name is known to Tintify (or is the
    /// palette currently being applied). Sections with unrecognized names are
    /// left untouched — they were authored by the user.
    private func removeKnownPaletteSections(in path: String, currentPaletteName: String) throws {
        guard FileManager.default.fileExists(atPath: path) else { return }
        let content = try String(contentsOfFile: path, encoding: .utf8)
        var lines = content.components(separatedBy: "\n")

        var i = 0
        while i < lines.count {
            if lines[i].hasPrefix("[palettes.") {
                var name = lines[i].dropFirst("[palettes.".count)
                if name.hasSuffix("]") {
                    name = name.dropLast()
                }
                // Remove from this header to the next top-level section or EOF
                var end = i + 1
                while end < lines.count && !lines[end].hasPrefix("[") {
                    end += 1
                }
                if knownPaletteNames.contains(String(name)) || String(name) == currentPaletteName {
                    lines.removeSubrange(i..<end)
                    // Don't increment i — check the same index again
                    continue
                }
                i = end
            } else {
                i += 1
            }
        }

        // Remove trailing blank lines
        while lines.last?.isEmpty == true && lines.count > 1 {
            lines.removeLast()
        }

        try ConfigWriter.atomicWrite(lines.joined(separator: "\n"), to: path)
    }
}
