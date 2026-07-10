// Sources/Adapters/OttyAdapter.swift
import Foundation

/// Adapter for the otty terminal emulator.
///
/// 每个主题生成一份 themes/tintify-<id>.ottytheme（meta.name 与文件名一致，
/// otty 按 meta.name 匹配），config.toml 的 theme 和 theme-dark 写同一个值——
/// 深浅切换统一由 Tintify 的跟随系统外观负责。
struct OttyAdapter: ToolAdapter {
    let id: ToolID = .otty
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

        // otty 不监听配置文件，写完必须通知运行中的实例重载才会换色。
        // 仅真实 apply（无路径覆盖）时触发，测试传入 configPath 不会走到这里。
        if configPath == nil {
            reloadRunningApp()
        }
    }

    /// 尽力而为地让运行中的 otty 重载配置（`otty-cli config reload`）。
    /// fire-and-forget：不阻塞 apply，app 未运行或命令失败只记日志。
    private func reloadRunningApp() {
        let cli = "/Applications/Otty.app/Contents/MacOS/otty-cli"
        guard FileManager.default.fileExists(atPath: cli) else { return }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: cli)
        process.arguments = ["config", "reload", "-q"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        process.terminationHandler = { p in
            if p.terminationStatus != 0 {
                Log.adapter.info("otty: config reload 退出码 \(p.terminationStatus)（app 可能未运行）")
            }
        }
        do {
            try process.run()
        } catch {
            Log.adapter.info("otty: 无法执行 otty-cli reload：\(error.localizedDescription)")
        }
    }

    /// 16 色 ANSI 槽位统一走 AnsiPalette（三个终端生成器共用，
    /// 深浅主题的灰阶端在那里分支）。
    private func buildOttyTheme(theme: Theme, name: String) -> String {
        let p = theme.palette
        let mode = theme.appearance == .dark ? "dark" : "light"
        let ansi = AnsiPalette.colors(for: theme)
        let rows = stride(from: 0, to: 16, by: 4).map { i in
            "    " + ansi[i..<i+4].map { "\"\($0)\"" }.joined(separator: ", ") + ","
        }.joined(separator: "\n")
        return """
            [meta]
            name = "\(name)"
            mode = "\(mode)"

            [terminal]
            foreground = "\(p.text)"
            background = "\(p.base)"
            palette = [
            \(rows)
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
