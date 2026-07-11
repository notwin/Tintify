// Sources/Settings/ThemesPane.swift
import SwiftUI

/// Theme gallery pane with category tabs, search, and filter.
struct ThemesPane: View {
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
        VStack(spacing: 0) {
            // 分类 Tab 栏
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
                                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? .primary : .secondary)
                            Text("\(count)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(isSelected ? .white : .secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                                .cornerRadius(4)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                        .cornerRadius(6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            // 搜索 + 过滤栏
            HStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField(L("搜索主题名..."), text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(6)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)

                Picker("", selection: $appearanceFilter) {
                    Text(L("全部")).tag(Theme.Appearance?.none)
                    Text(L("暗色")).tag(Theme.Appearance?.some(.dark))
                    Text(L("浅色")).tag(Theme.Appearance?.some(.light))
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            // 主题列表
            ScrollView {
                if filteredThemes.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: L("无匹配主题"),
                        subtitle: L("试试调整搜索词或过滤条件")
                    )
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredThemes) { theme in
                            ThemeCard(
                                theme: theme,
                                isActive: theme.id == settings.currentThemeId,
                                onApply: { theme in
                                    ThemeApplicationService.apply(theme: theme)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
    }
}
