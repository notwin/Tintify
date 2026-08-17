// Sources/Adapters/KittyAdapter.swift
import Foundation

/// Adapter for the kitty terminal emulator.
///
/// kitty 的"内置主题"靠 themes kitten 联网下载、不随安装包分发，
/// 主题名映射不可靠——所以全部主题统一从 palette 生成颜色行，
/// 直接写进 kitty.conf 的 TINTIFY 标记块（kitty 后行覆盖前行，
/// 块在文件尾部即可压过用户已有的 include current-theme.conf）。
struct KittyAdapter: ToolAdapter {
    let id: ToolID = .kitty

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.config/kitty/kitty.conf"
    }

    func detectInstalled() -> Bool {
        ToolDetection.findExecutable("kitty")
            || FileManager.default.fileExists(atPath: "/Applications/kitty.app")
    }

    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath

        let parentDir = (path as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: parentDir, withIntermediateDirectories: true)

        let p = theme.palette
        // 16 色 ANSI 槽位统一走 AnsiPalette（终端生成器共用）
        let ansi = AnsiPalette.colors(for: theme)
        let colorLines = ansi.enumerated()
            .map { "color\($0.offset) \($0.element)" }
            .joined(separator: "\n")
        let content = """
            foreground \(p.text)
            background \(p.base)
            cursor \(p.rosewater)
            cursor_text_color \(p.base)
            selection_background \(p.surface1)
            selection_foreground \(p.text)
            \(colorLines)
            """

        try ConfigWriter.writeMarkerBlock(to: path, content: content)

        // kitty 不监听配置文件，SIGUSR1 让运行中实例重载（官方文档机制）。
        // 仅真实 apply（无路径覆盖）时触发，测试传入 configPath 不会走到这里。
        if configPath == nil {
            reloadRunningApp()
        }
    }

    /// 尽力而为地给所有 kitty 进程发 SIGUSR1 触发配置重载。
    /// 未安装 kitty 时直接跳过，不白白 fork pkill。
    private func reloadRunningApp() {
        guard detectInstalled() else { return }
        ReloadNotifier.fire(executable: "/usr/bin/pkill", arguments: ["-USR1", "-x", "kitty"],
                            logPrefix: "kitty: SIGUSR1 重载")
    }
}
