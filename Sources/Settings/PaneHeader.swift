// Sources/Settings/PaneHeader.swift
import SwiftUI

/// Shared header component for all settings panes.
struct PaneHeader: View {
    @EnvironmentObject var skinModel: SkinModel
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        let skin = skinModel.skin
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(skin.accentColor)
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(skin.textPrimaryColor)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(skin.textSecondaryColor)
        }
        .padding(.top, 30)   // 透明标题栏让位
        .padding(.bottom, 8)
    }
}
