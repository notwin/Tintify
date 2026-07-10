// Sources/Adapters/EzaAdapter.swift
import Foundation

/// Adapter for eza (modern ls replacement).
struct EzaAdapter: ToolAdapter {
    let toolName = "eza"

    /// Path to the legacy config location an older Tintify version wrote to.
    /// On macOS eza actually reads the Application Support path, so a leftover
    /// file here is stale and causes drift confusion.
    let legacyConfigPath: String

    var defaultConfigPath: String {
        NSHomeDirectory() + "/Library/Application Support/eza/theme.yml"
    }

    init(legacyConfigPath: String = NSHomeDirectory() + "/.config/eza/theme.yml") {
        self.legacyConfigPath = legacyConfigPath
    }

    /// Write full YAML theme file with colors mapped from the palette.
    ///
    /// Creates parent directories if they do not exist.
    ///
    /// Args:
    ///   theme: The theme to apply.
    ///   configPath: Optional override path.
    func apply(theme: Theme, configPath: String? = nil) throws {
        // 一次性清理：旧版 Tintify 曾写过 ~/.config/eza/theme.yml，macOS 上 eza
        // 实际读取的是 Application Support 路径，残留会造成双份漂移的困惑
        try removeLegacyThemeIfTintifyManaged()

        let path = configPath ?? defaultConfigPath
        let p = theme.palette

        // Ensure parent directory exists.
        let dir = (path as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(
            atPath: dir, withIntermediateDirectories: true
        )

        let yaml = buildYAML(palette: p)
        try ConfigWriter.atomicWrite(yaml, to: path)
    }

    /// Remove the legacy config file only if it was written by Tintify itself.
    ///
    /// Leaves user-authored files at the legacy path untouched, logging a
    /// hint instead since eza no longer reads from there on macOS.
    private func removeLegacyThemeIfTintifyManaged() throws {
        let fm = FileManager.default
        guard fm.fileExists(atPath: legacyConfigPath),
              let content = try? String(contentsOfFile: legacyConfigPath, encoding: .utf8) else { return }
        if content.hasPrefix("# Tintify-managed eza theme") {
            try fm.removeItem(atPath: legacyConfigPath)
        } else {
            NSLog("[Tintify] eza: 检测到 \(legacyConfigPath)，eza 实际读取的是 Application Support 路径")
        }
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
