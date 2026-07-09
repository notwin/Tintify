// Sources/Adapters/OttyAdapter.swift
import Foundation

/// Adapter for the otty terminal emulator.
///
/// 每个主题生成一份 themes/tintify-<id>.ottytheme（meta.name 与文件名一致，
/// otty 按 meta.name 匹配），config.toml 的 theme 和 theme-dark 写同一个值——
/// 深浅切换统一由 Tintify 的跟随系统外观负责。
struct OttyAdapter: ToolAdapter {
    let toolName = "otty"
    let themesDir: String

    init(themesDir: String = NSHomeDirectory() + "/.config/otty/themes") {
        self.themesDir = themesDir
    }

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.config/otty/config.toml"
    }

    func detectInstalled() -> Bool {
        FileManager.default.fileExists(atPath: "/Applications/Otty.app")
    }

    func apply(theme: Theme, configPath: String? = nil) throws {
        let config = configPath ?? defaultConfigPath
        try FileManager.default.createDirectory(atPath: themesDir, withIntermediateDirectories: true)

        let themeName = "tintify-\(theme.id)"
        let themeFile = (themesDir as NSString).appendingPathComponent("\(themeName).ottytheme")
        try ConfigWriter.atomicWrite(buildOttyTheme(theme: theme, name: themeName), to: themeFile)

        // 清掉会盖住任何主题的硬编码覆盖行（幂等；注释行不动）
        try removeHardcodedOverrides(in: config)

        try ConfigWriter.replaceLine(in: config, prefix: "theme = ", newLine: "theme = \"\(themeName)\"")
        try ConfigWriter.replaceLine(in: config, prefix: "theme-dark = ", newLine: "theme-dark = \"\(themeName)\"")
    }

    /// 16 色 ANSI 顺序遵循 otty 现存 .ottytheme 惯例（ansi0 用 surface1 而非 crust，
    /// 保证黑色槽在深底上可见），与用户 themes 目录里的 catppuccin-mocha.ottytheme 一致。
    private func buildOttyTheme(theme: Theme, name: String) -> String {
        let p = theme.palette
        let mode = theme.appearance == .dark ? "dark" : "light"
        return """
            [meta]
            name = "\(name)"
            mode = "\(mode)"

            [terminal]
            foreground = "\(p.text)"
            background = "\(p.base)"
            palette = [
                "\(p.surface1)", "\(p.red)", "\(p.green)", "\(p.yellow)",
                "\(p.blue)", "\(p.pink)", "\(p.teal)", "\(p.subtext1)",
                "\(p.surface2)", "\(p.maroon)", "\(p.green)", "\(p.yellow)",
                "\(p.sapphire)", "\(p.mauve)", "\(p.sky)", "\(p.text)",
            ]
            """
    }

    /// 删除 config.toml 中未注释的 foreground/background/palette-0..15 覆盖行。
    private func removeHardcodedOverrides(in path: String) throws {
        guard FileManager.default.fileExists(atPath: path) else { return }
        let content = try String(contentsOfFile: path, encoding: .utf8)
        var lines = content.components(separatedBy: "\n")

        lines.removeAll { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("#") { return false }
            if trimmed.hasPrefix("foreground =") || trimmed.hasPrefix("foreground=") { return true }
            if trimmed.hasPrefix("background =") || trimmed.hasPrefix("background=") { return true }
            if trimmed.hasPrefix("palette-") {
                let rest = trimmed.dropFirst("palette-".count)
                let digits = rest.prefix(while: { $0.isNumber })
                if let n = Int(digits), (0...15).contains(n) { return true }
            }
            return false
        }

        try ConfigWriter.atomicWrite(lines.joined(separator: "\n"), to: path)
    }
}
