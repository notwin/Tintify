// Sources/Settings/EmptyStateView.swift
import SwiftUI

/// Shared empty state component with icon, title, and subtitle.
struct EmptyStateView: View {
    @EnvironmentObject var skinModel: SkinModel
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        let skin = skinModel.skin
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(skin.textSecondaryColor)
            Text(title)
                .font(.headline)
                .foregroundStyle(skin.textSecondaryColor)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(skin.textSecondaryColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
