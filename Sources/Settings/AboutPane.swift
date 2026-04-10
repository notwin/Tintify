// Sources/Settings/AboutPane.swift

import SwiftUI

/// About pane showing app name, version, and description.
struct AboutPane: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Tintify")
                .font(.title.bold())

            Text("v1.0.0")
                .foregroundStyle(.secondary)

            Text("macOS 终端主题管理器")
                .foregroundStyle(.secondary)

            Divider().padding(.horizontal, 40)

            Text("一键统一 Ghostty、Starship、bat、fzf、delta、eza、lazygit 的配色主题。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
