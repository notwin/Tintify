// Sources/App/TintifyApp.swift

import SwiftUI

@main
struct TintifyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            Text("Settings placeholder")
                .frame(width: 400, height: 300)
        }
    }
}

/// Application delegate that owns the menu bar and appearance monitor.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let menuBarManager = MenuBarManager()
    private var appearanceMonitor: SystemAppearanceMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarManager.setup()
        appearanceMonitor = SystemAppearanceMonitor { [weak self] isDark in
            guard AppSettings.shared.followSystemAppearance else { return }
            let themeId = isDark
                ? AppSettings.shared.darkThemeId
                : AppSettings.shared.lightThemeId
            guard let theme = ThemeRegistry.shared.theme(id: themeId) else { return }
            try? ThemeEngine().apply(theme: theme)
            self?.menuBarManager.rebuildMenu()
        }
    }
}
