// Sources/Settings/AboutPane.swift

import SwiftUI

/// About pane showing app info, supported tools, and links.
struct AboutPane: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.3.0"
    }

    private let supportedTools = [
        "Ghostty", "Starship", "bat", "fzf", "delta",
        "eza", "lazygit", "tmux", "vim", "zsh-syntax-highlighting"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
                       let iconImage = NSImage(contentsOf: iconURL) {
                        Image(nsImage: iconImage)
                            .resizable()
                            .frame(width: 80, height: 80)
                    } else {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)
                    }

                    Text("Tintify")
                        .font(.title.bold())

                    Text("v\(appVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("macOS 终端主题管理器")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider().padding(.horizontal, 40)

                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("支持的工具")
                            .font(.headline)
                        FlowLayout(spacing: 6) {
                            ForEach(supportedTools, id: \.self) { tool in
                                Text(tool)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .padding(8)
                }

                GroupBox {
                    VStack(spacing: 0) {
                        LinkRow(icon: "globe", title: "GitHub 仓库", subtitle: "查看源代码和文档")
                        Divider()
                        LinkRow(icon: "ladybug", title: "反馈问题", subtitle: "报告 Bug 或提交功能建议")
                    }
                }

                Text("Copyright \u{00A9} 2026 notwin")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(24)
        }
    }
}

/// A simple horizontal flow layout for tags.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }

        return CGSize(width: width, height: y + maxHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
    }
}

/// A row showing an icon, title, and subtitle for about page links.
struct LinkRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
    }
}
