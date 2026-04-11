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
            HStack(spacing: 0) {
                ForEach(ThemeCategory.allCases, id: \.self) { category in
                    let count = registry.themes(for: category).count
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCategory = category
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(category.rawValue)")
                                .font(.caption.bold())
                            Text("\(count)")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? Color.accentColor.opacity(0.12) : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color.secondary.opacity(0.06))

            Divider()

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
                    Text("Dark").tag(Theme.Appearance?.some(.dark))
                    Text("Light").tag(Theme.Appearance?.some(.light))
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            // 主题列表
            ScrollView {
                if filteredThemes.isEmpty {
                    Text("无匹配主题")
                        .foregroundStyle(.secondary)
                        .padding(40)
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
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255
        let b = Double(rgbValue & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
