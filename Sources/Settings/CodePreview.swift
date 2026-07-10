// Sources/Settings/CodePreview.swift
import SwiftUI

/// A mini terminal preview showing themed prompt, ls output, and code snippet.
struct CodePreview: View {
    let palette: Palette

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Prompt + ls output
            HStack(spacing: 0) {
                Text("$ ").foregroundStyle(Color(hex: palette.green))
                Text("ls -la").foregroundStyle(Color(hex: palette.text))
            }

            HStack(spacing: 8) {
                Label("Documents", systemImage: "folder.fill")
                    .foregroundStyle(Color(hex: palette.blue))
                Label("src", systemImage: "folder.fill")
                    .foregroundStyle(Color(hex: palette.blue))
                Text("main.py")
                    .foregroundStyle(Color(hex: palette.green))
            }
            .labelStyle(.titleOnly)

            Text(" ").frame(height: 2)

            HStack(spacing: 0) {
                Text("fn ").foregroundStyle(Color(hex: palette.mauve))
                Text("main").foregroundStyle(Color(hex: palette.blue))
                Text("() {").foregroundStyle(Color(hex: palette.text))
            }
            HStack(spacing: 0) {
                Text("  let ").foregroundStyle(Color(hex: palette.mauve))
                Text("x").foregroundStyle(Color(hex: palette.flamingo))
                Text(" = ").foregroundStyle(Color(hex: palette.sky))
                Text("\"hello\"").foregroundStyle(Color(hex: palette.green))
            }
            HStack(spacing: 0) {
                Text("  print").foregroundStyle(Color(hex: palette.yellow))
                Text("(x)").foregroundStyle(Color(hex: palette.text))
            }
            Text("}").foregroundStyle(Color(hex: palette.text))
        }
        .font(.system(size: 8, design: .monospaced))
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: palette.base))
        .cornerRadius(4)
        .accessibilityHidden(true)
    }
}
