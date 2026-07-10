// Sources/Adapters/EzaAdapter.swift
import Foundation

/// Adapter for eza (modern ls replacement).
struct EzaAdapter: ToolAdapter {
    let id: ToolID = .eza

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

    func detectInstalled() -> Bool {
        ToolDetection.findExecutable("eza")
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

        let yaml = buildYAML(palette: p, accent: theme.accent, lsColors: LsThemeColors.colors(for: theme))
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
            Log.adapter.warning("eza: 检测到 \(legacyConfigPath)，eza 实际读取的是 Application Support 路径")
        }
    }

    /// Build the eza theme YAML from a palette.
    ///
    /// theme.yml 是「叠加」语义：解析后与 eza 内置默认主题逐字段合并，
    /// 没写的段会透出默认 ANSI 色，只写 foreground 也清不掉默认的
    /// bold/underline——所以 file_type 必须整段写、带下划线默认值的键
    /// 要显式 is_underline: false。
    ///
    /// Args:
    ///   palette: The color palette to use.
    ///   accent: 主题点睛色；定义了就让 executable 用它出场。
    ///   lsColors: 设计稿「ls 三色」，按扩展名落到 html/docx/pptx 族。
    ///
    /// Returns:
    ///   The full YAML string.
    private func buildYAML(palette p: Palette, accent: String?, lsColors: [String]) -> String {
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
              block_device:
                foreground: "\(p.peach)"
              char_device:
                foreground: "\(p.peach)"
              socket:
                foreground: "\(p.mauve)"
              special:
                foreground: "\(p.yellow)"
              executable:
                foreground: "\(accent ?? p.green)"
                is_bold: true
              mount_point:
                foreground: "\(p.blue)"
                is_bold: true
                is_underline: false

            file_type:
              image:
                foreground: "\(p.mauve)"
              video:
                foreground: "\(p.mauve)"
                is_bold: true
              music:
                foreground: "\(p.sky)"
              lossless:
                foreground: "\(p.sky)"
                is_bold: true
              crypto:
                foreground: "\(p.maroon)"
              document:
                foreground: "\(p.lavender)"
              compressed:
                foreground: "\(p.red)"
              temp:
                foreground: "\(p.overlay1)"
              compiled:
                foreground: "\(p.peach)"
              build:
                foreground: "\(p.yellow)"
                is_bold: true
                is_underline: false
              source:
                foreground: "\(p.yellow)"

            extensions:
              html:
                filename:
                  foreground: "\(lsColors[0])"
              htm:
                filename:
                  foreground: "\(lsColors[0])"
              docx:
                filename:
                  foreground: "\(lsColors[1])"
              doc:
                filename:
                  foreground: "\(lsColors[1])"
              pptx:
                filename:
                  foreground: "\(lsColors[2])"
              ppt:
                filename:
                  foreground: "\(lsColors[2])"

            perms:
              user_read:
                foreground: "\(p.yellow)"
              user_write:
                foreground: "\(p.red)"
              user_execute_file:
                foreground: "\(p.green)"
                is_underline: false
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
                foreground: "\(p.overlay2)"

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
                foreground: "\(p.overlay1)"
              conflicted:
                foreground: "\(p.red)"
                is_bold: true

            date:
              foreground: "\(p.subtext0)"
            """
    }
}
