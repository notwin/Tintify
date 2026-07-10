// Sources/App/NotificationManager.swift
import Foundation
import UserNotifications

/// Sends macOS notifications for theme application results.
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    /// Whether UNUserNotificationCenter is available (requires a valid bundle).
    private let notificationsAvailable: Bool

    private var notificationSetupDone = false

    private override init() {
        notificationsAvailable = Bundle.main.bundleIdentifier != nil
        super.init()
    }

    /// Lazily set up notification center on first use.
    private func ensureSetup() {
        guard notificationsAvailable, !notificationSetupDone else { return }
        notificationSetupDone = true
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    /// Send a notification for the result.
    func notify(result: ApplyResult) {
        guard notificationsAvailable else { return }

        let content = UNMutableNotificationContent()

        if result.failedCount == 0 {
            content.title = "已切换到 \(result.theme.name)"
            content.body = "\(result.successCount)/\(result.toolResults.count) 工具已更新 · 新终端窗口自动生效"
            content.sound = .default
        } else if result.successCount == 0 {
            content.title = "主题切换失败"
            content.body = "\(result.toolResults.count) 个工具均未更新"
            content.sound = .defaultCritical
        } else {
            content.title = "已切换到 \(result.theme.name)"
            content.body = "\(result.summary) · 新终端窗口自动生效"
            content.sound = .default
        }

        ensureSetup()

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    /// Show notifications even when app is in foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
