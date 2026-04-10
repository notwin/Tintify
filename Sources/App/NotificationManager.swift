// Sources/App/NotificationManager.swift
import Foundation
import UserNotifications

/// Sends macOS notifications for theme application results.
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    /// History of apply results for the ResultsPane.
    private(set) var history: [ApplyResult] = []

    /// Whether UNUserNotificationCenter is available (requires a valid bundle).
    private let notificationsAvailable: Bool

    private override init() {
        // UNUserNotificationCenter crashes without a bundle identifier (SPM debug builds)
        notificationsAvailable = Bundle.main.bundleIdentifier != nil
        super.init()

        if notificationsAvailable {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }

    /// Send a notification and record the result in history.
    func notify(result: ApplyResult) {
        history.insert(result, at: 0)

        guard notificationsAvailable else {
            NSLog("[Tintify] \(result.summary) (notifications unavailable without bundle)")
            return
        }

        let content = UNMutableNotificationContent()

        if result.failedCount == 0 {
            content.title = "已切换到 \(result.theme.name)"
            content.body = "\(result.successCount)/\(result.toolResults.count) 工具已更新"
            content.sound = .default
        } else if result.successCount == 0 {
            content.title = "主题切换失败"
            content.body = "\(result.toolResults.count) 个工具均未更新"
            content.sound = .defaultCritical
        } else {
            content.title = "已切换到 \(result.theme.name)"
            content.body = "\(result.summary)"
            content.sound = .default
        }

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
