// Sources/Settings/ThemesPane.swift

import SwiftUI

/// Theme gallery pane with clickable theme cards.
struct ThemesPane: View {
    @ObservedObject private var settings = AppSettings.shared
    private let registry = ThemeRegistry.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Image(systemName: "theatermasks")
                        .font(.system(size: 36))
                        .foregroundStyle(.purple)
                    Text("主题")
                        .font(.title2.bold())
                    Text("点击主题卡片切换")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 12) {
                    ForEach(registry.allThemes) { theme in
                        ThemeCard(
                            theme: theme,
                            isActive: theme.id == settings.currentThemeId
                        ) {
                            ThemeEngine().apply(theme: theme)
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}

/// A compact card showing a theme's color swatches, name, and appearance.
struct ThemeCard: View {
    let theme: Theme
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 3) {
                ForEach([
                    theme.palette.red, theme.palette.peach,
                    theme.palette.yellow, theme.palette.green,
                    theme.palette.blue, theme.palette.mauve,
                ], id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 16, height: 16)
                }
            }

            Text(theme.name)
                .font(.caption.bold())

            Text(theme.appearance == .dark ? "深色" : "浅色")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isActive ? Color.accentColor.opacity(0.1) : Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isActive ? Color.accentColor : Color.secondary.opacity(0.2),
                    lineWidth: isActive ? 2 : 1
                )
        )
        .cornerRadius(8)
        .onTapGesture(perform: onTap)
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
