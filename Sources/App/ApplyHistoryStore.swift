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
        if let data = try? Data(contentsOf: storageURL),
           let saved = try? JSONDecoder().decode([ApplyResult].self, from: data) {
            history = saved
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
            NSLog("[Tintify] 应用记录写盘失败：\(error.localizedDescription)")
        }
    }
}
