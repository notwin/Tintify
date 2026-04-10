// Sources/App/TintifyApp.swift
import SwiftUI

@main
struct TintifyApp: App {
    var body: some Scene {
        MenuBarExtra("Tintify", systemImage: "paintpalette") {
            Text("Tintify is running")
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        Settings {
            Text("Settings placeholder")
        }
    }
}
