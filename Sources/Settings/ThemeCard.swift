// Sources/Settings/ThemeCard.swift
import SwiftUI

/// A theme card with default state and hover-expanded details.
struct ThemeCard: View {
    let theme: Theme
    let isActive: Bool
    let onApply: (Theme) -> Void

    @State private var isHovered = false
    @State private var previewVariantId: String?

    private var displayTheme: Theme {
        if let variantId = previewVariantId {
            return ThemeRegistry.shared.theme(id: variantId) ?? theme
        }
        return theme
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 色板预览条
            HStack(spacing: 3) {
                ForEach([
                    displayTheme.palette.red, displayTheme.palette.peach,
                    displayTheme.palette.yellow, displayTheme.palette.green,
                    displayTheme.palette.blue, displayTheme.palette.mauve,
                    displayTheme.palette.lavender, displayTheme.palette.text,
                ], id: \.self) { hex in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: hex))
                        .frame(height: 8)
                }
            }

            // 主题名
            Text(displayTheme.name)
                .font(.caption.bold())

            // 推荐理由
            Text(theme.description)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            // Hover 展开区域
            if isHovered {
                VStack(alignment: .leading, spacing: 6) {
                    // Stars + 兼容性
                    HStack(spacing: 8) {
                        if let stars = theme.stars {
                            Label(stars, systemImage: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }
                        Label(
                            theme.compatibility == .full ? "全工具兼容" : "部分 ANSI 回退",
                            systemImage: theme.compatibility == .full ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
                        )
                        .font(.caption2)
                        .foregroundStyle(theme.compatibility == .full ? .green : .orange)
                    }

                    // 风格标签
                    HStack(spacing: 4) {
                        TagView(text: theme.appearance == .dark ? "暗色" : "浅色")
                        TagView(text: theme.category.rawValue)
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
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // 应用按钮
            HStack {
                Spacer()
                Button("应用") {
                    onApply(displayTheme)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isActive ? Color.accentColor.opacity(0.08) : Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isActive ? Color.accentColor : Color.secondary.opacity(0.2),
                    lineWidth: isActive ? 2 : 1
                )
        )
        .cornerRadius(8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
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
