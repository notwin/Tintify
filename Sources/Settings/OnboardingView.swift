// Sources/Settings/OnboardingView.swift
import SwiftUI

/// First-run onboarding window.
struct OnboardingView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var selectedThemeId: String = "catppuccin-mocha"
    @State private var detectedTools: [String: Bool] = [:]
    let onComplete: () -> Void

    private let quickThemes = [
        "catppuccin-mocha", "dracula", "nord",
        "one-dark", "tokyo-night", "rose-pine"
    ]

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
                   let iconImage = NSImage(contentsOf: iconURL) {
                    Image(nsImage: iconImage)
                        .resizable()
                        .frame(width: 64, height: 64)
                } else {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)
                }
                Text("欢迎使用 Tintify")
                    .font(.title.bold())
                Text("一键统一终端工具的配色主题")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Tool detection
            VStack(alignment: .leading, spacing: 8) {
                Text("已检测到的工具")
                    .font(.headline)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 6) {
                    ForEach(Array(detectedTools.keys.sorted()), id: \.self) { tool in
                        let installed = detectedTools[tool] ?? false
                        HStack(spacing: 6) {
                            Toggle("", isOn: Binding(
                                get: { !settings.disabledTools.contains(tool) },
                                set: { enabled in
                                    if enabled {
                                        settings.disabledTools.remove(tool)
                                    } else {
                                        settings.disabledTools.insert(tool)
                                    }
                                }
                            ))
                            .toggleStyle(.switch)
                            .controlSize(.small)
                            .labelsHidden()

                            Text(tool)
                                .font(.caption)
                            if !installed {
                                Text("未安装")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
            }

            Divider()

            // Theme selection
            VStack(alignment: .leading, spacing: 8) {
                Text("选择一个主题")
                    .font(.headline)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 8) {
                    ForEach(quickThemes, id: \.self) { themeId in
                        if let theme = ThemeRegistry.shared.theme(id: themeId) {
                            Button {
                                selectedThemeId = themeId
                            } label: {
                                VStack(spacing: 4) {
                                    // Color swatches
                                    HStack(spacing: 2) {
                                        ForEach([
                                            theme.palette.red, theme.palette.green,
                                            theme.palette.blue, theme.palette.mauve,
                                            theme.palette.yellow, theme.palette.text,
                                        ], id: \.self) { hex in
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color(hex: hex))
                                                .frame(height: 8)
                                        }
                                    }
                                    Text(theme.name)
                                        .font(.caption.bold())
                                        .foregroundStyle(.primary)
                                }
                                .padding(8)
                                .background(selectedThemeId == themeId ? Color.accentColor.opacity(0.15) : Color(.controlBackgroundColor))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(selectedThemeId == themeId ? Color.accentColor : Color(NSColor.separatorColor), lineWidth: selectedThemeId == themeId ? 2 : 1)
                                )
                                .cornerRadius(6)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Spacer()

            // Start button
            Button {
                if let theme = ThemeRegistry.shared.theme(id: selectedThemeId) {
                    ThemeApplicationService.apply(theme: theme)
                }
                AppSettings.shared.onboardingCompleted = true
                onComplete()
            } label: {
                Text("开始使用")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
        .frame(width: 480, height: 560)
        .onAppear {
            detectTools()
        }
    }

    private func detectTools() {
        for adapter in ThemeEngine.allAdapters {
            let installed = adapter.detectInstalled()
            detectedTools[adapter.toolName] = installed
            if !installed {
                settings.disabledTools.insert(adapter.toolName)
            }
        }
    }
}
