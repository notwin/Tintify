// Sources/Settings/SkinStyle.swift
import SwiftUI
import AppKit

// MARK: - Color hex initializer（自 ThemesPane.swift 迁入，逻辑不变）

extension Color {
    /// Create a Color from a hex string (with or without leading `#`).
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard hex.count == 6 else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        guard scanner.scanHexInt64(&rgbValue) else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255
        let b = Double(rgbValue & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - ThemeSkin 的 SwiftUI Color 访问器

extension ThemeSkin {
    var windowBgColor: Color { Color(hex: windowBg) }
    var sidebarBgColor: Color { Color(hex: sidebarBg) }
    var cardBgColor: Color { Color(hex: cardBg) }
    var elevatedBgColor: Color { Color(hex: elevatedBg) }
    var borderColor: Color { Color(hex: border) }
    var textPrimaryColor: Color { Color(hex: textPrimary) }
    var textSecondaryColor: Color { Color(hex: textSecondary) }
    var accentColor: Color { Color(hex: accent) }
    var accentInkColor: Color { Color(hex: accentInk) }
    var successColor: Color { Color(hex: success) }
    var dangerColor: Color { Color(hex: danger) }
}

// MARK: - NSWindow 换肤（透明标题栏 + 底色跟随，skin 变化时重染）

struct WindowSkinApplier: NSViewRepresentable {
    let skin: ThemeSkin

    func makeNSView(context: Context) -> NSView { NSView() }

    func updateNSView(_ view: NSView, context: Context) {
        let hex = skin.windowBg
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.titlebarAppearsTransparent = true
            // 标题文字由系统按 NSAppearance 着色、不吃 skin，深色皮肤+浅色系统会隐身；
            // 侧边栏已有品牌名，直接隐藏标题，同时让系统 chrome 跟随皮肤明暗
            window.titleVisibility = .hidden
            window.appearance = NSAppearance(named: ThemeSkin.isLight(hex: hex) ? .aqua : .darkAqua)
            window.backgroundColor = NSColor(Color(hex: hex))
        }
    }
}

// MARK: - 皮肤化容器与控件

/// 圆角卡容器，替代 GroupBox。行间分隔用 SkinDivider。
struct SkinCard<Content: View>: View {
    @EnvironmentObject var skinModel: SkinModel
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .background(skinModel.skin.cardBgColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(skinModel.skin.borderColor, lineWidth: 1)
            )
    }
}

struct SkinDivider: View {
    @EnvironmentObject var skinModel: SkinModel
    var body: some View {
        skinModel.skin.borderColor.frame(height: 1)
    }
}

/// 自绘开关：轨道 accent / elevated，滑块 accentInk / textSecondary。
/// 只画「label + 轨道」，不自带 Spacer——需要开关靠右的行由调用方自己排
/// （样式内的贪婪 Spacer 会和行里的 Spacer 抢空间，把行内开关挤到行中间）。
struct SkinToggleStyle: ToggleStyle {
    let skin: ThemeSkin

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.label
            Capsule()
                .fill(configuration.isOn ? skin.accentColor : skin.elevatedBgColor)
                .overlay(
                    Circle()
                        .fill(configuration.isOn ? skin.accentInkColor : skin.textSecondaryColor)
                        .padding(3)
                        .frame(maxWidth: .infinity,
                               alignment: configuration.isOn ? .trailing : .leading)
                )
                .frame(width: 34, height: 20)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) { configuration.isOn.toggle() }
        }
    }
}

/// 主按钮：accent 底 + accentInk 字。
struct SkinPrimaryButtonStyle: ButtonStyle {
    let skin: ThemeSkin

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(skin.accentInkColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 5)
            .background(skin.accentColor.opacity(configuration.isPressed ? 0.75 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .contentShape(Rectangle())
    }
}

/// 次按钮：描边 + 次要字色。
struct SkinSecondaryButtonStyle: ButtonStyle {
    let skin: ThemeSkin

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12))
            .foregroundStyle(skin.textSecondaryColor)
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .background(skin.elevatedBgColor.opacity(configuration.isPressed ? 1 : 0.001))
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(skin.borderColor, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .contentShape(Rectangle())
    }
}
