// Tests/ApplyHistoryStoreTests.swift
import Testing
import Foundation
@testable import Tintify

@MainActor
@Test func historyStorePersistsAndReloads() throws {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString).appendingPathComponent("history.json")

    let store = ApplyHistoryStore(storageURL: url)
    let theme = ThemeRegistry.shared.theme(id: "nord")!
    store.record(ApplyResult(theme: theme, timestamp: Date(), toolResults: [
        ToolResult(toolName: "bat", status: .success, message: nil, configPath: "/tmp/x")
    ]))

    #expect(store.history.count == 1)
    // 重新加载（模拟重启）
    let reloaded = ApplyHistoryStore(storageURL: url)
    #expect(reloaded.history.count == 1)
    #expect(reloaded.history[0].theme.id == "nord")
    #expect(reloaded.history[0].toolResults[0].status == .success)
}

@MainActor
@Test func historyStoreCapsAtFifty() throws {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString).appendingPathComponent("history.json")
    let store = ApplyHistoryStore(storageURL: url)
    let theme = ThemeRegistry.shared.theme(id: "nord")!
    for _ in 0..<55 {
        store.record(ApplyResult(theme: theme, timestamp: Date(), toolResults: []))
    }
    #expect(store.history.count == 50)
}

@MainActor
@Test func reloadPicksUpExternalWrites() throws {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString).appendingPathComponent("history.json")
    let store = ApplyHistoryStore(storageURL: url)
    #expect(store.history.isEmpty)

    // 模拟另一个进程写入同一文件
    let other = ApplyHistoryStore(storageURL: url)
    other.record(ApplyResult(theme: ThemeRegistry.shared.theme(id: "nord")!,
                             timestamp: Date(), toolResults: []))

    store.reload()
    #expect(store.history.count == 1)
}
