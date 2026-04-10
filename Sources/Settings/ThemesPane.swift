// Sources/Settings/ThemesPane.swift
import SwiftUI

/// Theme gallery pane with grouped cards and collapsible sections.
struct ThemesPane: View {
    @ObservedObject private var settings = AppSettings.shared
    private let registry = ThemeRegistry.shared

    @State private var expandedSections: Set<ThemeCategory> = Set(ThemeCategory.allCases)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Image(systemName: "theatermasks")
                        .font(.system(size: 36))
                        .foregroundStyle(.purple)
                    Text("主题")
                        .font(.title2.bold())
                    Text("\(registry.allThemes.count) 个内置主题，按分组浏览")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)

                ForEach(ThemeCategory.allCases, id: \.self) { category in
                    ThemeSectionView(
                        category: category,
                        themes: registry.themes(for: category),
                        currentThemeId: settings.currentThemeId,
                        isExpanded: expandedSections.contains(category),
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if expandedSections.contains(category) {
                                    expandedSections.remove(category)
                                } else {
                                    expandedSections.insert(category)
                                }
                            }
                        },
                        onApply: { theme in
                            let result = ThemeEngine().apply(theme: theme)
                            NotificationManager.shared.notify(result: result)
                        }
                    )
                }
            }
            .padding(24)
        }
    }
}

/// A collapsible section of theme cards.
struct ThemeSectionView: View {
    let category: ThemeCategory
    let themes: [Theme]
    let currentThemeId: String
    let isExpanded: Bool
    let onToggle: () -> Void
    let onApply: (Theme) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .frame(width: 12)
                    Text(category.rawValue)
                        .font(.headline)
                    Text("(\(themes.count))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 12) {
                    ForEach(themes) { theme in
                        ThemeCard(
                            theme: theme,
                            isActive: theme.id == currentThemeId,
                            onApply: onApply
                        )
                    }
                }
                .transition(.opacity)
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
