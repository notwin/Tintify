// Sources/Adapters/EzaAdapter.swift
import Foundation

/// Adapter for eza (modern ls replacement).
struct EzaAdapter: ToolAdapter {
    let toolName = "eza"

    var defaultConfigPath: String {
        NSHomeDirectory() + "/Library/Application Support/eza/theme.yml"
    }

    /// Write full YAML theme file with colors mapped from the palette.
    ///
    /// Creates parent directories if they do not exist.
    ///
    /// Args:
    ///   theme: The theme to apply.
    ///   configPath: Optional override path.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath
        let p = theme.palette

        // Ensure parent directory exists.
        let dir = (path as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(
            atPath: dir, withIntermediateDirectories: true
        )

        // Remove symlink if present so we write a real file, not overwrite the link target.
        let fm = FileManager.default
        if let _ = try? fm.destinationOfSymbolicLink(atPath: path) {
            try fm.removeItem(atPath: path)
        }

        let yaml = buildYAML(palette: p)
        try yaml.write(toFile: path, atomically: true, encoding: .utf8)
    }

    /// Build the eza theme YAML from a palette.
    ///
    /// Args:
    ///   palette: The color palette to use.
    ///
    /// Returns:
    ///   The full YAML string.
    private func buildYAML(palette p: Palette) -> String {
        return """
            # Tintify-managed eza theme
            filekinds:
              normal:
                foreground: "\(p.text)"
              directory:
                foreground: "\(p.blue)"
                is_bold: true
              symlink:
                foreground: "\(p.teal)"
              pipe:
                foreground: "\(p.mauve)"
              blockdevice:
                foreground: "\(p.peach)"
              chardevice:
                foreground: "\(p.peach)"
              socket:
                foreground: "\(p.mauve)"
              special:
                foreground: "\(p.yellow)"
              executable:
                foreground: "\(p.green)"
                is_bold: true
              mount_point:
                foreground: "\(p.blue)"
                is_bold: true

            perms:
              user_read:
                foreground: "\(p.yellow)"
              user_write:
                foreground: "\(p.red)"
              user_execute_file:
                foreground: "\(p.green)"
              user_execute_other:
                foreground: "\(p.green)"
              group_read:
                foreground: "\(p.yellow)"
              group_write:
                foreground: "\(p.red)"
              group_execute:
                foreground: "\(p.green)"
              other_read:
                foreground: "\(p.yellow)"
              other_write:
                foreground: "\(p.red)"
              other_execute:
                foreground: "\(p.green)"
              special_user_file:
                foreground: "\(p.mauve)"
              special_other:
                foreground: "\(p.mauve)"
              attribute:
                foreground: "\(p.overlay1)"

            size:
              number_byte:
                foreground: "\(p.green)"
              number_kilo:
                foreground: "\(p.green)"
              number_mega:
                foreground: "\(p.yellow)"
              number_giga:
                foreground: "\(p.red)"
              number_huge:
                foreground: "\(p.red)"
                is_bold: true
              unit_byte:
                foreground: "\(p.subtext0)"
              unit_kilo:
                foreground: "\(p.subtext0)"
              unit_mega:
                foreground: "\(p.subtext0)"
              unit_giga:
                foreground: "\(p.subtext0)"
              unit_huge:
                foreground: "\(p.subtext0)"

            git:
              new:
                foreground: "\(p.green)"
              modified:
                foreground: "\(p.yellow)"
              deleted:
                foreground: "\(p.red)"
              renamed:
                foreground: "\(p.teal)"
              ignored:
                foreground: "\(p.overlay0)"
              conflicted:
                foreground: "\(p.red)"
                is_bold: true

            date:
              hour_old:
                foreground: "\(p.green)"
              day_old:
                foreground: "\(p.text)"
              older:
                foreground: "\(p.subtext0)"
            """
    }
}
