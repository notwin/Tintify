// Sources/Settings/GeneralPane.swift

import SwiftUI
import LaunchAtLogin

/// General preferences pane: appearance following, theme selection, and launch-at-login.
struct GeneralPane: View {
    @EnvironmentObject var skinModel: SkinModel
    @ObservedObject private var settings = AppSettings.shared
    private let registry = ThemeRegistry.shared

    var body: some View {
        let skin = skinModel.skin
        ScrollView {
            VStack(spacing: 16) {
                PaneHeader(icon: "paintpalette", title: L("通用"), subtitle: L("主题切换、外观跟随和启动设置"))

                SkinCard {
                    Toggle(L("跟随系统外观"), isOn: $settings.followSystemAppearance)
                        .toggleStyle(SkinToggleStyle(skin: skin))
                        .foregroundStyle(skin.textPrimaryColor)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 12)

                    SkinDivider()

                    themePickerRow(label: L("深色主题"), icon: "moon",
                                   selection: $settings.darkThemeId,
                                   themes: registry.themes(for: .dark), skin: skin)

                    SkinDivider()

                    themePickerRow(label: L("浅色主题"), icon: "sun.max",
                                   selection: $settings.lightThemeId,
                                   themes: registry.themes(for: .light), skin: skin)
                }

                SkinCard {
                    LaunchAtLogin.Toggle(L("开机自动启动"))
                        .toggleStyle(SkinToggleStyle(skin: skin))
                        .foregroundStyle(skin.textPrimaryColor)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 12)
                }

                SkinCard {
                    configRow(title: L("导出配置"), icon: "square.and.arrow.up", skin: skin) {
                        ConfigManager.exportConfig()
                    }
                    SkinDivider()
                    configRow(title: L("导入配置"), icon: "square.and.arrow.down", skin: skin) {
                        ConfigManager.importConfig()
                    }
                }
            }
            .padding(24)
        }
    }

    private func themePickerRow(label: String, icon: String, selection: Binding<String>,
                                themes: [Theme], skin: ThemeSkin) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(skin.textPrimaryColor)
            Spacer()
            Picker("", selection: selection) {
                ForEach(themes) { theme in
                    Text(theme.name).tag(theme.id)
                }
            }
            .tint(skin.accentColor)
            .frame(width: 200)
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
    }

    private func configRow(title: String, icon: String, skin: ThemeSkin,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: icon)
                    .foregroundStyle(skin.textPrimaryColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(skin.textSecondaryColor)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
    }
}
