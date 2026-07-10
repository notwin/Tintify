// Sources/Settings/ThemeCard.swift
import SwiftUI

/// A theme card showing preview, metadata, and apply button — always fully expanded.
struct ThemeCard: View {
    let theme: Theme
    let isActive: Bool
    let onApply: (Theme) -> Void

    @State private var previewVariantId: String?
    @State private var isHovered = false

    private var displayTheme: Theme {
        if let variantId = previewVariantId {
            return ThemeRegistry.shared.theme(id: variantId) ?? theme
        }
        return theme
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 左侧：终端预览（提示符胶囊 + ls，与设计稿一致）
            TerminalPreview(theme: displayTheme)
                .frame(width: 200)

            // 右侧：信息 + 操作
            VStack(alignment: .leading, spacing: 6) {
                // 主题名 + 应用按钮
                HStack {
                    Text(displayTheme.name)
                        .font(.body.bold())
                    Spacer()
                    if isActive {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    Button(L("应用")) {
                        onApply(displayTheme)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                // 推荐理由
                Text(theme.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // 色板预览条
                HStack(spacing: 4) {
                    let swatches = [
                        displayTheme.palette.red, displayTheme.palette.peach,
                        displayTheme.palette.yellow, displayTheme.palette.green,
                        displayTheme.palette.blue, displayTheme.palette.mauve,
                        displayTheme.palette.lavender, displayTheme.palette.text,
                    ]
                    ForEach(Array(swatches.enumerated()), id: \.offset) { _, hex in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: hex))
                            .frame(height: 10)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(L("配色预览：\(theme.name)"))

                // Stars + 标签（bat/delta 现在也吃生成主题，ANSI 回退徽章已无意义）
                HStack(spacing: 8) {
                    if let stars = theme.stars {
                        Label(stars, systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                    TagView(text: theme.appearance == .dark ? L("暗色") : L("浅色"))
                }

                // 变体切换
                if let variants = theme.variants, !variants.isEmpty {
                    HStack(spacing: 4) {
                        VariantButton(
                            title: theme.name,
                            isSelected: previewVariantId == nil
                        ) {
                            previewVariantId = nil
                        }
                        ForEach(variants, id: \.self) { variantId in
                            if let variant = ThemeRegistry.shared.theme(id: variantId) {
                                VariantButton(
                                    title: variant.name,
                                    isSelected: previewVariantId == variantId
                                ) {
                                    previewVariantId = variantId
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isActive ? Color.accentColor.opacity(0.15) : Color(.controlBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isActive ? Color.accentColor : Color(NSColor.separatorColor),
                    lineWidth: isActive ? 2 : 1
                )
        )
        .cornerRadius(8)
        .shadow(color: .black.opacity(isHovered ? 0.1 : 0.04), radius: isHovered ? 6 : 2, y: isHovered ? 2 : 1)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contentShape(Rectangle())
    }
}

/// Small tag badge.
struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.secondary.opacity(0.15))
            .cornerRadius(4)
    }
}

/// Variant selection button.
struct VariantButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 9))
                .lineLimit(1)
        }
        .buttonStyle(.bordered)
        .controlSize(.mini)
        .tint(isSelected ? .accentColor : nil)
    }
}
