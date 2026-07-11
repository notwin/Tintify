// Sources/Settings/ThemesPane.swift
import SwiftUI

/// 主题画廊：分类 chips + 搜索/过滤 + Hero 大卡 + 迷你终端网格。
/// 点网格卡 = 试穿（只染窗口）；Hero 的「应用」才写入终端配置。
struct ThemesPane: View {
    @EnvironmentObject var skinModel: SkinModel
    @ObservedObject private var settings = AppSettings.shared
    private let registry = ThemeRegistry.shared

    @State private var selectedCategory: ThemeCategory = .popular
    @State private var searchText: String = ""
    @State private var appearanceFilter: Theme.Appearance? = nil

    private var filteredThemes: [Theme] {
        var themes = registry.themes(for: selectedCategory)
        if let filter = appearanceFilter {
            themes = themes.filter { $0.appearance == filter }
        }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            themes = themes.filter {
                $0.name.lowercased().contains(query) ||
                $0.localizedDescription.lowercased().contains(query)
            }
        }
        return themes
    }

    var body: some View {
        let skin = skinModel.skin
        VStack(spacing: 0) {
            filterBar(skin: skin)

            ScrollView {
                VStack(spacing: 12) {
                    ThemeHeroCard { theme in
                        ThemeApplicationService.apply(theme: theme)
                        skinModel.previewTheme = nil  // 试穿转正
                    }

                    if filteredThemes.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: L("无匹配主题"),
                            subtitle: L("试试调整搜索词或过滤条件")
                        )
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 190), spacing: 10)],
                            spacing: 10
                        ) {
                            ForEach(filteredThemes) { theme in
                                ThemeGridCard(
                                    theme: theme,
                                    isCurrent: theme.id == settings.currentThemeId
                                ) {
                                    // 再点已试穿的卡 = 取消试穿；点当前主题 = 清试穿
                                    if skinModel.previewTheme?.id == theme.id
                                        || theme.id == settings.currentThemeId {
                                        skinModel.previewTheme = nil
                                    } else {
                                        skinModel.previewTheme = theme
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
        }
    }

    @ViewBuilder
    private func filterBar(skin: ThemeSkin) -> some View {
        // 拆两行：一行装不下「4 分类 + 搜索 + 3 深浅」，最小窗宽下最长的
        // 「Tintify 原创」会被挤到折行，chip 高矮不齐
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(ThemeCategory.allCases, id: \.self) { category in
                    let count = registry.themes(for: category).count
                    let isSelected = selectedCategory == category
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(category.displayName)
                                .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                            Text("\(count)")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .lineLimit(1)
                        .fixedSize()
                        .foregroundStyle(isSelected ? skin.accentInkColor : skin.textSecondaryColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(isSelected ? skin.accentColor : skin.cardBgColor)
                        .clipShape(Capsule())
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }

            HStack(spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 10))
                        .foregroundStyle(skin.textSecondaryColor)
                    TextField(L("搜索主题名..."), text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .foregroundStyle(skin.textPrimaryColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .frame(maxWidth: 260)
                .background(skin.elevatedBgColor)
                .clipShape(Capsule())

                Spacer()

                appearanceChip(nil, label: L("全部"), skin: skin)
                appearanceChip(.dark, label: L("暗色"), skin: skin)
                appearanceChip(.light, label: L("浅色"), skin: skin)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 38)   // 透明标题栏让位
        .padding(.bottom, 10)
    }

    private func appearanceChip(_ value: Theme.Appearance?, label: String, skin: ThemeSkin) -> some View {
        let isSelected = appearanceFilter == value
        return Button {
            appearanceFilter = value
        } label: {
            Text(label)
                .font(.system(size: 11, weight: isSelected ? .bold : .regular))
                .foregroundStyle(isSelected ? skin.accentInkColor : skin.textSecondaryColor)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(isSelected ? skin.accentColor : skin.cardBgColor)
                .clipShape(Capsule())
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
