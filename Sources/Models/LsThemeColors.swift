// Sources/Models/LsThemeColors.swift
import Foundation

/// 设计稿速查表的「ls 三色」（html / docx / pptx）。
/// 主题卡预览（TerminalPreview）与 eza 的 extensions 段共用这份数据，
/// 保证 设计稿 = 预览卡 = 真实终端渲染 三者一致。
/// 未列出的主题回退 blue/green/pink——T1 暮紫同款取色手法。
enum LsThemeColors {
    static let overrides: [String: [String]] = [
        "catppuccin-mocha": ["#89b4fa", "#a6e3a1", "#f5c2e7"],
        "rose-pine": ["#9ccfd8", "#f6c177", "#eb6f92"],
        "tokyo-night": ["#7aa2f7", "#9ece6a", "#bb9af7"],
        "kanagawa-wave": ["#7e9cd8", "#98bb6c", "#dca561"],
        "nord": ["#88c0d0", "#a3be8c", "#b48ead"],
        "everforest-dark": ["#7fbbb3", "#a7c080", "#dbbc7f"],
        "gruvbox-dark": ["#83a598", "#b8bb26", "#fabd2f"],
        "rose-pine-dawn": ["#56949f", "#ea9d34", "#b4637a"],
        "synthwave-sunset": ["#36f9f6", "#72f1b8", "#fede5d"],
        "phosphor-green": ["#9ceb8b", "#5fce62", "#d6fbc4"],
        "ink-vermilion": ["#d8d2c4", "#e34234", "#97917f"],
        "jewel-tones": ["#7dd3fc", "#6ee7b7", "#f9a8d4"],
        "caramel": ["#ddbd94", "#c39566", "#f0e0cb"],
        "soda-pop": ["#d81159", "#0f8a6d", "#7048b6"],
    ]

    static func colors(for theme: Theme) -> [String] {
        overrides[theme.id] ?? [theme.palette.blue, theme.palette.green, theme.palette.pink]
    }
}
