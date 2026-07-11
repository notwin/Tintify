// Sources/Settings/ThemeGridCard.swift
import SwiftUI

/// 网格里的迷你终端卡：整卡浸在主题自己的 base 色里，点击试穿。
struct ThemeGridCard: View {
    @EnvironmentObject var skinModel: SkinModel
    let theme: Theme
    let isCurrent: Bool
    let onTap: () -> Void

    private var isPreviewing: Bool { skinModel.previewTheme?.id == theme.id }

    var body: some View {
        let skin = skinModel.skin
        VStack(alignment: .leading, spacing: 0) {
            TerminalPreview(theme: theme, embedded: true)
            HStack(spacing: 4) {
                Text(theme.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: theme.palette.text))
                    .lineLimit(1)
                Spacer(minLength: 4)
                if theme.appearance == .light {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(Color(hex: theme.palette.yellow))
                }
                if isCurrent {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(hex: theme.palette.green))
                }
            }
            .padding(.horizontal, 9)
            .padding(.bottom, 8)
        }
        .background(Color(hex: theme.palette.base))
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .strokeBorder(
                    isCurrent ? skin.accentColor
                        : isPreviewing ? skin.accentColor
                        : skin.borderColor.opacity(theme.appearance == .light ? 1 : 0.6),
                    style: StrokeStyle(lineWidth: isCurrent || isPreviewing ? 2 : 1,
                                       dash: isPreviewing && !isCurrent ? [4, 3] : [])
                )
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(theme.name)
        .accessibilityAddTraits(.isButton)
    }
}
