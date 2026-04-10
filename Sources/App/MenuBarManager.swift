// Sources/App/MenuBarManager.swift

import AppKit
import SwiftUI

/// Owns the NSStatusItem and builds the dropdown menu for Tintify.
final class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem?
    private let engine = ThemeEngine()
    private let registry = ThemeRegistry.shared
    private let settings = AppSettings.shared

    /// Create the status item and attach the initial menu.
    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(
            systemSymbolName: "paintpalette",
            accessibilityDescription: "Tintify"
        )
        statusItem?.button?.image?.size = NSSize(width: 18, height: 18)
        statusItem?.menu = buildMenu()
    }

    /// Tear down and recreate the menu to reflect current state.
    func rebuildMenu() {
        statusItem?.menu = buildMenu()
    }

    // MARK: - Menu Construction

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let currentTheme = registry.theme(id: settings.currentThemeId)
        let headerItem = NSMenuItem()
        headerItem.title = currentTheme?.name ?? "No Theme"
        headerItem.isEnabled = false
        menu.addItem(headerItem)

        let infoItem = NSMenuItem()
        infoItem.title = "\(engine.adapters.count) tools synced"
        infoItem.isEnabled = false
        menu.addItem(infoItem)

        menu.addItem(.separator())

        for theme in registry.allThemes {
            let item = NSMenuItem(
                title: theme.name,
                action: #selector(themeSelected(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = theme.id
            item.state = theme.id == settings.currentThemeId ? .on : .off
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let followItem = NSMenuItem(
            title: "Follow System Appearance",
            action: #selector(toggleFollowSystem(_:)),
            keyEquivalent: ""
        )
        followItem.target = self
        followItem.state = settings.followSystemAppearance ? .on : .off
        menu.addItem(followItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        let quitItem = NSMenuItem(
            title: "Quit Tintify",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    // MARK: - Actions

    @objc private func themeSelected(_ sender: NSMenuItem) {
        guard let themeId = sender.representedObject as? String,
              let theme = registry.theme(id: themeId) else { return }
        try? engine.apply(theme: theme)
        rebuildMenu()
    }

    @objc private func toggleFollowSystem(_ sender: NSMenuItem) {
        settings.followSystemAppearance.toggle()
        rebuildMenu()
    }

    @objc private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
