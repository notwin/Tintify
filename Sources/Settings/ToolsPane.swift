// Sources/Settings/ToolsPane.swift

import SwiftUI

/// Tools pane for customizing per-tool configuration file paths.
struct ToolsPane: View {
    @ObservedObject private var settings = AppSettings.shared

    private let tools: [(name: String, defaultPath: String)] = [
        ("ghostty", "~/Library/Application Support/com.mitchellh.ghostty/config"),
        ("starship", "~/.config/starship.toml"),
        ("bat", "~/.zshrc"),
        ("fzf", "~/.zshrc"),
        ("delta", "~/.gitconfig"),
        ("eza", "~/.config/eza/theme.yml"),
        ("lazygit", "~/Library/Application Support/lazygit/config.yml"),
        ("zsh-syntax-highlighting", "~/.zshrc"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 36))
                        .foregroundStyle(.orange)
                    Text("工具")
                        .font(.title2.bold())
                    Text("配置文件路径（留空使用默认路径）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)

                GroupBox {
                    VStack(spacing: 0) {
                        ForEach(Array(tools.enumerated()), id: \.offset) { idx, tool in
                            if idx > 0 { Divider() }
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(tool.name).font(.body.bold())
                                    Text(tool.defaultPath).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                TextField("自定义路径", text: Binding(
                                    get: { settings.toolPaths[tool.name] ?? "" },
                                    set: { val in
                                        if val.isEmpty {
                                            settings.toolPaths.removeValue(forKey: tool.name)
                                        } else {
                                            settings.toolPaths[tool.name] = val
                                        }
                                    }
                                ))
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 200)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}
