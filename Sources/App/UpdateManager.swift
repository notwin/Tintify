// Sources/App/UpdateManager.swift
import Foundation
import AppKit

/// Checks GitHub Releases for updates and performs in-place app replacement.
@MainActor
final class UpdateManager: ObservableObject {
    static let shared = UpdateManager()

    enum State: Equatable {
        case idle
        case checking
        case upToDate
        case available(version: String)
        case downloading(progress: String)
        case error(message: String)
    }

    @Published var state: State = .idle

    private let owner = "notwin"
    private let repo = "Tintify"

    private var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    private init() {}

    /// Check GitHub for a newer release.
    func checkForUpdate() {
        guard state != .checking else { return }
        state = .checking

        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/releases/latest"
        guard let url = URL(string: urlString) else {
            state = .error(message: "无效的 URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    state = .error(message: "网络请求失败")
                    return
                }

                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tagName = json["tag_name"] as? String else {
                    state = .error(message: "解析失败")
                    return
                }

                let remoteVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName

                if isNewer(remote: remoteVersion, current: currentVersion) {
                    state = .available(version: remoteVersion)
                } else {
                    state = .upToDate
                }
            } catch {
                state = .error(message: "检查失败：\(error.localizedDescription)")
            }
        }
    }

    /// Download the latest DMG, mount it, replace the app, and relaunch.
    func performUpdate(version: String) {
        state = .downloading(progress: "下载中...")

        let dmgURL = "https://github.com/\(owner)/\(repo)/releases/download/v\(version)/Tintify-\(version).dmg"
        guard let url = URL(string: dmgURL) else {
            state = .error(message: "下载地址无效")
            return
        }

        Task {
            do {
                // 1. Download DMG
                state = .downloading(progress: "下载中...")
                let (tempURL, response) = try await URLSession.shared.download(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    state = .error(message: "下载失败")
                    return
                }

                let dmgPath = NSTemporaryDirectory() + "Tintify-\(version).dmg"
                let fm = FileManager.default
                if fm.fileExists(atPath: dmgPath) {
                    try fm.removeItem(atPath: dmgPath)
                }
                try fm.moveItem(at: tempURL, to: URL(fileURLWithPath: dmgPath))

                // 2. Mount DMG
                state = .downloading(progress: "安装中...")
                let mountPoint = try mountDMG(at: dmgPath)

                // 3. Replace app
                let sourceApp = mountPoint + "/Tintify.app"
                let targetApp = "/Applications/Tintify.app"

                guard fm.fileExists(atPath: sourceApp) else {
                    try unmountDMG(at: mountPoint)
                    state = .error(message: "DMG 中未找到 Tintify.app")
                    return
                }

                // Remove old app
                if fm.fileExists(atPath: targetApp) {
                    try fm.removeItem(atPath: targetApp)
                }
                // Copy new app
                try fm.copyItem(atPath: sourceApp, toPath: targetApp)

                // 4. Unmount DMG
                try unmountDMG(at: mountPoint)

                // 5. Clean up
                try? fm.removeItem(atPath: dmgPath)

                // 6. Relaunch
                relaunch()

            } catch {
                state = .error(message: "更新失败：\(error.localizedDescription)")
            }
        }
    }

    // MARK: - Private

    private func isNewer(remote: String, current: String) -> Bool {
        let r = remote.split(separator: ".").compactMap { Int($0) }
        let c = current.split(separator: ".").compactMap { Int($0) }
        for i in 0..<max(r.count, c.count) {
            let rv = i < r.count ? r[i] : 0
            let cv = i < c.count ? c[i] : 0
            if rv > cv { return true }
            if rv < cv { return false }
        }
        return false
    }

    private func mountDMG(at path: String) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        process.arguments = ["attach", path, "-nobrowse", "-quiet", "-mountpoint", "/tmp/tintify-update"]
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw NSError(domain: "UpdateManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "挂载 DMG 失败"])
        }
        return "/tmp/tintify-update"
    }

    private func unmountDMG(at mountPoint: String) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        process.arguments = ["detach", mountPoint, "-quiet"]
        try process.run()
        process.waitUntilExit()
    }

    private func relaunch() {
        let appPath = "/Applications/Tintify.app"
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-n", appPath]
        try? task.run()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApplication.shared.terminate(nil)
        }
    }
}
