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
        ("eza", "~/Library/Application Support/eza/theme.yml"),
        ("lazygit", "~/Library/Application Support/lazygit/config.yml"),
        ("zsh-syntax-highlighting", "~/.zshrc"),
        ("tmux", "~/.tmux.conf"),
        ("vim", "~/.vimrc"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PaneHeader(icon: "wrench.and.screwdriver", color: .orange, title: "工具", subtitle: "配置文件路径（留空使用默认路径）")

                GroupBox {
                    VStack(spacing: 0) {
                        ForEach(Array(tools.enumerated()), id: \.offset) { idx, tool in
                            if idx > 0 { Divider() }
                            HStack(spacing: 12) {
                                Toggle("", isOn: Binding(
                                    get: { !settings.disabledTools.contains(tool.name) },
                                    set: { enabled in
                                        if enabled {
                                            settings.disabledTools.remove(tool.name)
                                        } else {
                                            settings.disabledTools.insert(tool.name)
                                        }
                                    }
                                ))
                                .toggleStyle(.switch)
                                .labelsHidden()

                                VStack(alignment: .leading) {
                                    Text(tool.name).font(.body.bold())
                                    Text(tool.defaultPath).font(.caption).foregroundStyle(.secondary)
                                }
                                .opacity(settings.disabledTools.contains(tool.name) ? 0.4 : 1.0)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    TextField("留空使用默认路径", text: Binding(
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
                                    .disabled(settings.disabledTools.contains(tool.name))

                                    if let customPath = settings.toolPaths[tool.name],
                                       !customPath.isEmpty,
                                       !FileManager.default.fileExists(atPath: (customPath as NSString).expandingTildeInPath) {
                                        Label("路径不存在", systemImage: "exclamationmark.triangle.fill")
                                            .font(.caption2)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                .opacity(settings.disabledTools.contains(tool.name) ? 0.4 : 1.0)
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
