// Sources/App/MenuBarManager.swift

import AppKit
import SwiftUI

/// Owns the NSStatusItem and builds the dropdown menu for Tintify.
@MainActor
final class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem?
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
        let menu = NSMenu()
        menu.delegate = self
        statusItem?.menu = menu
    }

    /// Tear down and recreate the menu to reflect current state.
    func rebuildMenu() {
        if let menu = statusItem?.menu { populate(menu) }
    }

    // MARK: - Menu Construction

    private func populate(_ menu: NSMenu) {
        menu.removeAllItems()

        // Header: 当前主题名
        let currentTheme = registry.theme(id: settings.currentThemeId)
        let headerItem = NSMenuItem()
        headerItem.title = currentTheme?.name ?? L("未设置主题")
        headerItem.isEnabled = false
        menu.addItem(headerItem)

        // Info: 工具数量
        let infoItem = NSMenuItem()
        infoItem.title = L("已配置 \(ThemeEngine.allAdapters.count) 个工具")
        infoItem.isEnabled = false
        menu.addItem(infoItem)

        menu.addItem(.separator())

        // 快速回退
        if let prevId = settings.previousThemeId,
           let prevTheme = registry.theme(id: prevId),
           prevId != settings.currentThemeId {
            let rollbackItem = NSMenuItem(
                title: L("↩ 回到上一个: \(prevTheme.name)"),
                action: #selector(rollbackTheme(_:)),
                keyEquivalent: ""
            )
            rollbackItem.target = self
            menu.addItem(rollbackItem)
            menu.addItem(.separator())
        }

        // 分组子菜单
        for category in ThemeCategory.allCases {
            let themes = registry.themes(for: category)
            let submenuItem = NSMenuItem(title: category.displayName, action: nil, keyEquivalent: "")
            let submenu = NSMenu()

            for theme in themes {
                let item = NSMenuItem(
                    title: theme.name,
                    action: #selector(themeSelected(_:)),
                    keyEquivalent: ""
                )
                item.target = self
                item.representedObject = theme.id
                item.state = theme.id == settings.currentThemeId ? .on : .off
                submenu.addItem(item)
            }

            submenuItem.submenu = submenu
            menu.addItem(submenuItem)
        }

        menu.addItem(.separator())

        // Follow System Appearance
        let followItem = NSMenuItem(
            title: L("跟随系统外观"),
            action: #selector(toggleFollowSystem(_:)),
            keyEquivalent: ""
        )
        followItem.target = self
        followItem.state = settings.followSystemAppearance ? .on : .off
        menu.addItem(followItem)

        menu.addItem(.separator())

        // Settings
        let settingsItem = NSMenuItem(
            title: L("设置..."),
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        // Quit
        let quitItem = NSMenuItem(
            title: L("退出 Tintify"),
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
    }

    // MARK: - Actions

    @objc private func themeSelected(_ sender: NSMenuItem) {
        guard let themeId = sender.representedObject as? String,
              let theme = registry.theme(id: themeId) else { return }
        ThemeApplicationService.apply(theme: theme)
        rebuildMenu()
    }

    @objc private func rollbackTheme(_ sender: NSMenuItem) {
        guard let prevId = settings.previousThemeId,
              let theme = registry.theme(id: prevId) else { return }
        ThemeApplicationService.apply(theme: theme)
        rebuildMenu()
    }

    @objc private func toggleFollowSystem(_ sender: NSMenuItem) {
        settings.followSystemAppearance.toggle()
        rebuildMenu()
    }

    private var settingsWindow: NSWindow?

    @objc private func openSettings() {
        if let window = settingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        } else {
            let hostingController = NSHostingController(rootView: SettingsView())
            let window = NSWindow(contentViewController: hostingController)
            window.title = "Tintify Settings"
            window.setContentSize(NSSize(width: 800, height: 600))
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.minSize = NSSize(width: 700, height: 500)
            window.maxSize = NSSize(width: 1200, height: 900)
            window.center()
            window.isReleasedWhenClosed = false  // 关闭时不销毁，下次能复用
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            settingsWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

extension MenuBarManager: NSMenuDelegate {
    /// 每次打开菜单时重建 — 无论主题从哪个入口被应用，菜单永远反映当前状态。
    func menuNeedsUpdate(_ menu: NSMenu) {
        populate(menu)
    }
}
