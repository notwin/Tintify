// Sources/App/ApplyHistoryStore.swift
import Foundation

/// 应用记录的唯一存储：可观察 + 落盘（~/.tintify/history.json，上限 50 条）。
@MainActor
final class ApplyHistoryStore: ObservableObject {
    static let shared = ApplyHistoryStore()

    @Published private(set) var history: [ApplyResult] = []
    private let storageURL: URL
    private let maxEntries = 50

    init(storageURL: URL = URL(fileURLWithPath: NSHomeDirectory() + "/.tintify/history.json")) {
        self.storageURL = storageURL
        reload()
    }

    /// 从磁盘重读历史（CLI 等外部进程写入后调用）。
    func reload() {
        guard let data = try? Data(contentsOf: storageURL) else { return }
        do {
            history = try JSONDecoder().decode([ApplyResult].self, from: data)
        } catch {
            // 解码失败（schema 漂移/损坏）：备份原文件留证，避免后续 record 覆盖致永久丢失
            Log.history.error("应用记录解码失败，已备份原文件：\(error.localizedDescription)")
            let backupURL = storageURL.deletingPathExtension()
                .appendingPathExtension("corrupted-\(Int(Date().timeIntervalSince1970)).json")
            try? data.write(to: backupURL)
        }
    }

    func record(_ result: ApplyResult) {
        history.insert(result, at: 0)
        if history.count > maxEntries {
            history.removeLast(history.count - maxEntries)
        }
        persist()
    }

    private func persist() {
        do {
            try FileManager.default.createDirectory(
                at: storageURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(history)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            Log.history.error("应用记录写盘失败：\(error.localizedDescription)")
        }
    }
}
