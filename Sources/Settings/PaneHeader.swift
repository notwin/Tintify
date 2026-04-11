// Sources/Settings/PaneHeader.swift
import SwiftUI

/// Shared header component for all settings panes.
struct PaneHeader: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(color)
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 8)
    }
}
