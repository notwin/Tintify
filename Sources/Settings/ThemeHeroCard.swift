// Sources/Settings/ThemeHeroCard.swift
import SwiftUI

/// 主题页顶部 Hero：放大预览 + 详情 + 应用按钮。展示试穿主题（无试穿则当前主题）。
struct ThemeHeroCard: View {
    @EnvironmentObject var skinModel: SkinModel
    let onApply: (Theme) -> Void

    private var displayed: Theme { skinModel.previewTheme ?? skinModel.currentTheme }
    private var isCurrent: Bool { displayed.id == skinModel.currentTheme.id }

    var body: some View {
        let skin = skinModel.skin
        let theme = displayed
        HStack(alignment: .top, spacing: 14) {
            // 左：放大终端预览 + 主色板条
            VStack(spacing: 6) {
                TerminalPreview(theme: theme, scale: 1.6)
                HStack(spacing: 3) {
                    let swatches = [
                        theme.palette.red, theme.palette.peach, theme.palette.yellow,
                        theme.palette.green, theme.palette.blue, theme.palette.mauve,
                        theme.palette.text,
                    ]
                    ForEach(Array(swatches.enumerated()), id: \.offset) { _, hex in
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color(hex: hex))
                            .frame(height: 9)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(L("配色预览：\(theme.name)"))
            }
            .frame(width: 330)

            // 右：详情 + 操作
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(theme.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(skin.textPrimaryColor)
                    if isCurrent {
                        Text(L("✓ 使用中"))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(skin.successColor)
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(skin.successColor.opacity(0.15))
                            .clipShape(Capsule())
                    } else {
                        Text(L("试穿中 · 未应用"))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(skin.accentColor)
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(skin.accentColor.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 6) {
                    Text(theme.localizedDescription)
                    if let stars = theme.stars {
                        Text("★ \(stars)")
                    }
                    Text(theme.appearance == .dark ? L("暗色") : L("浅色"))
                }
                .font(.system(size: 11))
                .foregroundStyle(skin.textSecondaryColor)

                // 变体 chips：点击试穿该变体
                if let variants = theme.variants, !variants.isEmpty {
                    HStack(spacing: 5) {
                        ForEach(variants, id: \.self) { variantId in
                            if let variant = ThemeRegistry.shared.theme(id: variantId) {
                                Button {
                                    skinModel.previewTheme =
                                        variant.id == skinModel.currentTheme.id ? nil : variant
                                } label: {
                                    Text(variant.name).font(.system(size: 10))
                                }
                                .buttonStyle(SkinSecondaryButtonStyle(skin: skin))
                            }
                        }
                    }
                    .padding(.top, 2)
                }

                Spacer(minLength: 8)

                HStack(spacing: 8) {
                    Button(isCurrent ? L("重新应用") : L("应用这套")) {
                        onApply(theme)
                    }
                    .buttonStyle(SkinPrimaryButtonStyle(skin: skin))

                    if !isCurrent {
                        Text(L("Esc 还原"))
                            .font(.system(size: 10))
                            .foregroundStyle(skin.textSecondaryColor)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(skin.cardBgColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(skin.accentColor, lineWidth: isCurrent ? 1 : 2)
        )
    }
}
