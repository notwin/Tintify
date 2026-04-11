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
                $0.description.lowercased().contains(query)
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
                            Text(category.rawValue)
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
                    TextField("搜索主题名...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(6)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)

                Picker("", selection: $appearanceFilter) {
                    Text("全部").tag(Theme.Appearance?.none)
                    Text("暗色").tag(Theme.Appearance?.some(.dark))
                    Text("浅色").tag(Theme.Appearance?.some(.light))
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
                        title: "无匹配主题",
                        subtitle: "试试调整搜索词或过滤条件"
                    )
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredThemes) { theme in
                            ThemeCard(
                                theme: theme,
                                isActive: theme.id == settings.currentThemeId,
                                onApply: { theme in
                                    let result = ThemeEngine().apply(theme: theme)
                                    NotificationManager.shared.notify(result: result)
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

// MARK: - Color hex initializer

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
