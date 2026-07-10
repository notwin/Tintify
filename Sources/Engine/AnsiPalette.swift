// Sources/Engine/AnsiPalette.swift
import Foundation

/// 三个终端生成器（ghostty / otty / wezterm）共用的 ANSI 16 色数组。
/// 彩色槽（1-6、9-14）全主题一致；灰阶端按深浅分支——ANSI 黑槽
/// 必须在底色上可见（深色主题取比背景亮的 surface 阶，浅色主题取
/// 深灰），白槽方向与底色相反（浅色主题的 white 是浅灰，同官方
/// catppuccin latte 端口惯例）。
enum AnsiPalette {
    static func colors(for theme: Theme) -> [String] {
        let p = theme.palette
        let dark = theme.appearance == .dark
        return [
            dark ? p.surface1 : p.subtext1,   // 0  black
            p.red,                            // 1  red
            p.green,                          // 2  green
            p.yellow,                         // 3  yellow
            p.blue,                           // 4  blue
            p.pink,                           // 5  magenta
            p.teal,                           // 6  cyan
            dark ? p.subtext1 : p.surface2,   // 7  white
            dark ? p.surface2 : p.subtext0,   // 8  bright black
            p.maroon,                         // 9  bright red
            p.green,                          // 10 bright green
            p.yellow,                         // 11 bright yellow
            p.sapphire,                       // 12 bright blue
            p.mauve,                          // 13 bright magenta
            p.sky,                            // 14 bright cyan
            dark ? p.text : p.surface1,       // 15 bright white
        ]
    }
}
