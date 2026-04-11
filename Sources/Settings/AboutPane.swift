// Sources/Settings/AboutPane.swift

import SwiftUI

/// About pane showing app name, version, and description.
struct AboutPane: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.2.0"
    }

    var body: some View {
        VStack(spacing: 16) {
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
                .foregroundStyle(.secondary)

            Text("macOS 终端主题管理器")
                .foregroundStyle(.secondary)

            Divider().padding(.horizontal, 40)

            Text("一键统一 Ghostty、Starship、bat、fzf、delta、eza、lazygit、tmux、vim 的配色主题。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)

            Text("Copyright \u{00A9} 2026 notwin")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
