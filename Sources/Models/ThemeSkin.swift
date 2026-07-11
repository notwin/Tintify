import Foundation

/// 从主题 palette 派生的语义 UI token（hex 字符串）。
/// 设置窗口全部从这里取色，不用系统色——「主题即界面」。
/// palette 是 catppuccin 语义规范：base/surface/text 天生是「底/面/字」，
/// 浅色主题无需特判（latte 的 base 就是浅底）。
struct ThemeSkin: Equatable {
    let windowBg: String
    let sidebarBg: String
    let cardBg: String
    let elevatedBg: String
    let border: String
    let textPrimary: String
    let textSecondary: String
    let accent: String
    let accentInk: String
    let success: String
    let danger: String

    init(theme: Theme) {
        let p = theme.palette
        windowBg = p.base
        sidebarBg = p.mantle
        cardBg = p.surface0
        elevatedBg = p.surface1
        border = p.surface2
        textPrimary = p.text
        textSecondary = p.subtext0
        let accentHex = theme.accent ?? theme.promptSegments.first?.color ?? p.text
        accent = accentHex
        // accent 底上的字色：取与 accent 同色的那段胶囊的 ink（设计稿手挑过对比度）
        accentInk = theme.promptSegments
            .first(where: { $0.color.lowercased() == accentHex.lowercased() })?.ink
            ?? theme.promptSegments.first?.ink
            ?? p.base
        success = p.green
        danger = p.red
    }

    /// 底色是否偏亮（决定窗口 NSAppearance 用 aqua 还是 darkAqua）
    static func isLight(hex: String) -> Bool {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var v: UInt64 = 0
        guard Scanner(string: h).scanHexInt64(&v) else { return false }
        let r = Double((v & 0xFF0000) >> 16) / 255
        let g = Double((v & 0x00FF00) >> 8) / 255
        let b = Double(v & 0x0000FF) / 255
        return 0.2126 * r + 0.7152 * g + 0.0722 * b > 0.5
    }
}
