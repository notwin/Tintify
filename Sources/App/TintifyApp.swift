// Sources/App/TintifyApp.swift

import SwiftUI

@main
enum TintifyMain {
    static func main() {
        let args = CommandLine.arguments
        if args.count > 1, args[1] == "cli" {
            CLIRunner.run(Array(args.dropFirst(2)))  // 不返回
        }
        TintifyApp.main()
    }
}

struct TintifyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 空 scene — 纯菜单栏 app，设置窗口由 MenuBarManager 手动管理
        Settings {
            EmptyView()
        }
    }
}

/// Application delegate that owns the menu bar and appearance monitor.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let menuBarManager = MenuBarManager()
    private var appearanceMonitor: SystemAppearanceMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set app icon explicitly (fixes notification icon for ad-hoc signed apps)
        if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
           let icon = NSImage(contentsOf: iconURL) {
            NSApplication.shared.applicationIconImage = icon
        }

        // Show onboarding for first-time users
        if !AppSettings.shared.onboardingCompleted {
            showOnboarding()
        }
        menuBarManager.setup()
        UpdateManager.shared.checkForUpdate()
        appearanceMonitor = SystemAppearanceMonitor { [weak self] isDark in
            guard AppSettings.shared.followSystemAppearance else { return }
            let themeId = isDark
                ? AppSettings.shared.darkThemeId
                : AppSettings.shared.lightThemeId
            guard let theme = ThemeRegistry.shared.theme(id: themeId) else { return }
            ThemeApplicationService.apply(theme: theme)
            self?.menuBarManager.rebuildMenu()
        }

        // CLI 进程应用主题后通知 GUI 刷新（defaults 已被外部进程修改）
        DistributedNotificationCenter.default().addObserver(
            forName: .init(CLIRunner.externalChangeNotification),
            object: nil, queue: .main
        ) { _ in
            MainActor.assumeIsolated {
                AppSettings.shared.reload()
            }
        }
    }

    /// 关闭最后一个窗口时不退出 app（菜单栏 app 应该继续运行）
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    private func showOnboarding() {
        let onboardingView = OnboardingView {
            // Close onboarding window when done
            NSApplication.shared.windows
                .first { $0.title == "Tintify 欢迎" }?
                .close()
        }

        let hostingController = NSHostingController(rootView: onboardingView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Tintify 欢迎"
        window.setContentSize(NSSize(width: 480, height: 560))
        window.styleMask = [.titled, .closable]
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
