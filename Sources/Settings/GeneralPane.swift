// Sources/Settings/GeneralPane.swift

import SwiftUI
import LaunchAtLogin

/// General preferences pane: appearance following, theme selection, and launch-at-login.
struct GeneralPane: View {
    @ObservedObject private var settings = AppSettings.shared
    private let registry = ThemeRegistry.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PaneHeader(icon: "paintpalette", color: .blue, title: "通用", subtitle: "主题切换、外观跟随和启动设置")

                GroupBox {
                    VStack(spacing: 0) {
                        Toggle("跟随系统外观", isOn: $settings.followSystemAppearance)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)

                        Divider()

                        HStack {
                            Label("深色主题", systemImage: "moon")
                            Spacer()
                            Picker("", selection: $settings.darkThemeId) {
                                ForEach(registry.themes(for: .dark)) { theme in
                                    Text(theme.name).tag(theme.id)
                                }
                            }
                            .frame(width: 200)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)

                        Divider()

                        HStack {
                            Label("浅色主题", systemImage: "sun.max")
                            Spacer()
                            Picker("", selection: $settings.lightThemeId) {
                                ForEach(registry.themes(for: .light)) { theme in
                                    Text(theme.name).tag(theme.id)
                                }
                            }
                            .frame(width: 200)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                    }
                }

                GroupBox {
                    LaunchAtLogin.Toggle("开机自动启动")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                }

                GroupBox {
                    VStack(spacing: 0) {
                        Button {
                            ConfigManager.exportConfig()
                        } label: {
                            HStack {
                                Label("导出配置", systemImage: "square.and.arrow.up")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)

                        Divider()

                        Button {
                            ConfigManager.importConfig()
                        } label: {
                            HStack {
                                Label("导入配置", systemImage: "square.and.arrow.down")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                    }
                }
            }
            .padding(24)
        }
    }
}
