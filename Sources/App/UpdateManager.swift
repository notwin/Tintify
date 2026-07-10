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

                // 1b. Verify checksum (skip if release has no .sha256 file)
                if let ok = try await verifyChecksum(dmgPath: dmgPath, dmgURL: url), !ok {
                    try? fm.removeItem(atPath: dmgPath)
                    Log.update.error("校验失败，已中止更新")
                    state = .error(message: L("校验失败，已中止更新"))
                    return
                }

                // 2. Mount DMG
                state = .downloading(progress: L("安装中..."))
                let mountPoint = try await mountDMG(at: dmgPath)

                // 3. Replace app
                let sourceApp = mountPoint + "/Tintify.app"
                let targetApp = "/Applications/Tintify.app"

                guard fm.fileExists(atPath: sourceApp) else {
                    try await unmountDMG(at: mountPoint)
                    Log.update.error("DMG 中未找到 Tintify.app")
                    state = .error(message: L("DMG 中未找到 Tintify.app"))
                    return
                }

                // Atomic replace: stage the copy, then swap. If the copy fails,
                // the old app is untouched; the final move is a same-volume rename.
                let stagingApp = "/Applications/Tintify.app.new"
                if fm.fileExists(atPath: stagingApp) { try? fm.removeItem(atPath: stagingApp) }
                try fm.copyItem(atPath: sourceApp, toPath: stagingApp)
                if fm.fileExists(atPath: targetApp) { try fm.removeItem(atPath: targetApp) }
                try fm.moveItem(atPath: stagingApp, toPath: targetApp)

                // 4. Unmount DMG
                try await unmountDMG(at: mountPoint)

                // 5. Clean up
                try? fm.removeItem(atPath: dmgPath)

                // 6. Relaunch
                relaunch()

            } catch {
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
                              userInfo: [NSLocalizedDescriptionKey: "挂载 DMG 失败"])
            }
            return data
        }.value

        guard let plist = try PropertyListSerialization.propertyList(from: output, format: nil) as? [String: Any],
              let entities = plist["system-entities"] as? [[String: Any]],
              let mountPoint = entities.compactMap({ $0["mount-point"] as? String }).first else {
            throw NSError(domain: "UpdateManager", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "无法解析 DMG 挂载点"])
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

    /// 校验下载的 DMG。返回 nil = release 未附校验文件（跳过），否则为校验结果。
    private func verifyChecksum(dmgPath: String, dmgURL: URL) async throws -> Bool? {
        guard let checksumURL = URL(string: dmgURL.absoluteString + ".sha256") else { return nil }
        let (data, response) = try await URLSession.shared.data(from: checksumURL)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200,
              let text = String(data: data, encoding: .utf8),
              let expected = text.split(separator: " ").first.map({ String($0).lowercased() }) else {
            Log.update.warning("更新：release 未附 sha256 校验文件，跳过校验")
            return nil
        }
        let dmgData = try Data(contentsOf: URL(fileURLWithPath: dmgPath))
        let actual = SHA256.hash(data: dmgData).map { String(format: "%02x", $0) }.joined()
        return actual == expected
    }

    private func relaunch() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        task.arguments = ["-c", "sleep 1; open /Applications/Tintify.app"]
        try? task.run()
        NSApplication.shared.terminate(nil)   // 旧实例先退，1 秒后新实例起——不再重叠
    }
}
