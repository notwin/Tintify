// Sources/App/UpdateManager.swift
import Foundation
import AppKit
import CryptoKit

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
            Log.update.error("无效的 URL")
            state = .error(message: L("无效的 URL"))
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
                    Log.update.error("网络请求失败")
                    state = .error(message: L("网络请求失败"))
                    return
                }

                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tagName = json["tag_name"] as? String else {
                    Log.update.error("解析失败")
                    state = .error(message: L("解析失败"))
                    return
                }

                let remoteVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName

                if UpdateManager.isNewer(remote: remoteVersion, current: currentVersion) {
                    state = .available(version: remoteVersion)
                } else {
                    state = .upToDate
                }
            } catch {
                Log.update.error("检查失败：\(error.localizedDescription)")
                state = .error(message: L("检查失败：\(error.localizedDescription)"))
            }
        }
    }

    /// Download the latest DMG, mount it, replace the app, and relaunch.
    func performUpdate(version: String) {
        state = .downloading(progress: L("下载中..."))

        let dmgURL = "https://github.com/\(owner)/\(repo)/releases/download/v\(version)/Tintify-\(version).dmg"
        guard let url = URL(string: dmgURL) else {
            Log.update.error("下载地址无效")
            state = .error(message: L("下载地址无效"))
            return
        }

        Task {
            var mountPoint: String?
            do {
                // 1. Download DMG
                state = .downloading(progress: L("下载中..."))
                let (tempURL, response) = try await URLSession.shared.download(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    Log.update.error("下载失败")
                    state = .error(message: L("下载失败"))
                    return
                }

                let dmgPath = NSTemporaryDirectory() + "Tintify-\(version).dmg"
                let fm = FileManager.default
                if fm.fileExists(atPath: dmgPath) {
                    try fm.removeItem(atPath: dmgPath)
                }
                try fm.moveItem(at: tempURL, to: URL(fileURLWithPath: dmgPath))

                // 1b. Verify checksum (fail-closed：校验文件不可达或不匹配都中止)
                if !(await verifyChecksum(dmgPath: dmgPath, dmgURL: url)) {
                    try? fm.removeItem(atPath: dmgPath)
                    Log.update.error("校验失败，已中止更新")
                    state = .error(message: L("校验失败，已中止更新"))
                    return
                }

                // 2. Mount DMG
                state = .downloading(progress: L("安装中..."))
                mountPoint = try await mountDMG(at: dmgPath)

                // 3. Replace app
                let sourceApp = mountPoint! + "/Tintify.app"
                let targetApp = "/Applications/Tintify.app"

                guard fm.fileExists(atPath: sourceApp) else {
                    try await unmountDMG(at: mountPoint!)
                    mountPoint = nil
                    Log.update.error("DMG 中未找到 Tintify.app")
                    state = .error(message: L("DMG 中未找到 Tintify.app"))
                    return
                }

                // 原子替换：replaceItemAt 失败时原 app 仍在，不会出现「已删未恢复」窗口
                let stagingApp = "/Applications/Tintify.app.new"
                if fm.fileExists(atPath: stagingApp) { try? fm.removeItem(atPath: stagingApp) }
                try fm.copyItem(atPath: sourceApp, toPath: stagingApp)
                if fm.fileExists(atPath: targetApp) {
                    _ = try fm.replaceItemAt(
                        URL(fileURLWithPath: targetApp),
                        withItemAt: URL(fileURLWithPath: stagingApp),
                        backupItemName: nil,
                        options: [])
                } else {
                    try fm.moveItem(atPath: stagingApp, toPath: targetApp)
                }

                // 4. Unmount DMG
                try await unmountDMG(at: mountPoint!)
                mountPoint = nil

                // 5. Clean up
                try? fm.removeItem(atPath: dmgPath)

                // 6. Relaunch
                relaunch()

            } catch {
                // 失败路径统一清理：卸载残留挂载点，避免泄漏
                if let mp = mountPoint { try? await unmountDMG(at: mp) }
                Log.update.error("更新失败：\(error.localizedDescription)")
                state = .error(message: L("更新失败：\(error.localizedDescription)"))
            }
        }
    }

    // MARK: - Private

    nonisolated static func isNewer(remote: String, current: String) -> Bool {
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

    private func mountDMG(at path: String) async throws -> String {
        let output: Data = try await Task.detached {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
            process.arguments = ["attach", path, "-nobrowse", "-quiet", "-plist"]
            let pipe = Pipe()
            process.standardOutput = pipe
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else {
                throw NSError(domain: "UpdateManager", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: L("挂载 DMG 失败")])
            }
            return data
        }.value

        guard let plist = try PropertyListSerialization.propertyList(from: output, format: nil) as? [String: Any],
              let entities = plist["system-entities"] as? [[String: Any]],
              let mountPoint = entities.compactMap({ $0["mount-point"] as? String }).first else {
            throw NSError(domain: "UpdateManager", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: L("无法解析 DMG 挂载点")])
        }
        return mountPoint
    }

    private func unmountDMG(at mountPoint: String) async throws {
        try await Task.detached {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
            process.arguments = ["detach", mountPoint, "-quiet"]
            try process.run()
            process.waitUntilExit()
        }.value
    }

    /// 校验下载的 DMG。fail-closed：校验文件不可达或不匹配都返回 false。
    private func verifyChecksum(dmgPath: String, dmgURL: URL) async -> Bool {
        guard let checksumURL = URL(string: dmgURL.absoluteString + ".sha256") else { return false }
        guard let (data, response) = try? await URLSession.shared.data(from: checksumURL),
              let http = response as? HTTPURLResponse, http.statusCode == 200,
              let text = String(data: data, encoding: .utf8),
              let expected = text.split(separator: " ").first.map({ String($0).lowercased() }) else {
            Log.update.error("更新：无法获取 sha256 校验文件，已中止（fail-closed）")
            return false
        }
        guard let dmgData = try? Data(contentsOf: URL(fileURLWithPath: dmgPath)) else { return false }
        let actual = SHA256.hash(data: dmgData).map { String(format: "%02x", $0) }.joined()
        return actual == expected
    }

    private func relaunch() {
        let pid = ProcessInfo.processInfo.processIdentifier
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        // 轮询当前 PID 是否已退出，确保旧实例终止后再 open——
        // 否则 open 会激活仍在运行的旧实例，新版永不启动。
        let script = """
        for i in $(seq 1 50); do kill -0 \(pid) 2>/dev/null || break; sleep 0.1; done
        sleep 0.3
        open /Applications/Tintify.app
        """
        task.arguments = ["-c", script]
        try? task.run()
        NSApplication.shared.terminate(nil)
    }
}
