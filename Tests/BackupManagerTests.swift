import Testing
import Foundation
@testable import Tintify

@Test func backupAndRestore() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

    let configFile = tmpDir.appendingPathComponent("config.txt")
    try "original content".write(to: configFile, atomically: true, encoding: .utf8)

    let manager = BackupManager(backupRoot: tmpDir.appendingPathComponent("backups").path)
    let backupId = try manager.backup(files: [configFile.path])

    try "modified content".write(to: configFile, atomically: true, encoding: .utf8)
    #expect(try String(contentsOf: configFile, encoding: .utf8) == "modified content")

    try manager.restore(backupId: backupId)
    #expect(try String(contentsOf: configFile, encoding: .utf8) == "original content")
}

@Test func listBackups() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let configFile = tmpDir.appendingPathComponent("config.txt")
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    try "content".write(to: configFile, atomically: true, encoding: .utf8)

    let manager = BackupManager(backupRoot: tmpDir.appendingPathComponent("backups").path)
    _ = try manager.backup(files: [configFile.path])
    _ = try manager.backup(files: [configFile.path])

    let list = manager.listBackups()
    #expect(list.count == 3)   // 2 个滚动备份 + 1 个 pinned initial 快照
}

@Test func pruneKeepsOnly10() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let configFile = tmpDir.appendingPathComponent("config.txt")
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    try "content".write(to: configFile, atomically: true, encoding: .utf8)

    let manager = BackupManager(backupRoot: tmpDir.appendingPathComponent("backups").path)
    for _ in 0..<12 {
        _ = try manager.backup(files: [configFile.path])
    }

    let list = manager.listBackups()
    #expect(list.count == 10)
}

@Test func backupAndRestorePathWithDoubleUnderscore() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let weirdDir = tmpDir.appendingPathComponent("__pycache__")
    try FileManager.default.createDirectory(at: weirdDir, withIntermediateDirectories: true)

    let configFile = weirdDir.appendingPathComponent("config.txt")
    try "test content".write(to: configFile, atomically: true, encoding: .utf8)

    let manager = BackupManager(backupRoot: tmpDir.appendingPathComponent("backups").path)
    let backupId = try manager.backup(files: [configFile.path])

    try "modified".write(to: configFile, atomically: true, encoding: .utf8)
    try manager.restore(backupId: backupId)

    let restored = try String(contentsOf: configFile, encoding: .utf8)
    #expect(restored == "test content")
}

@Test func listBackupsParsesDatesFromId() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let configFile = tmpDir.appendingPathComponent("config.txt")
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    try "content".write(to: configFile, atomically: true, encoding: .utf8)

    let manager = BackupManager(backupRoot: tmpDir.appendingPathComponent("backups").path)
    _ = try manager.backup(files: [configFile.path])

    let list = manager.listBackups()
    #expect(list.count == 2)   // 1 个滚动备份 + 1 个 pinned initial 快照

    let rolling = try #require(list.first { $0.id != "initial" })
    let timeDiff = abs(rolling.date.timeIntervalSinceNow)
    #expect(timeDiff < 5)
}

@Test func firstBackupCreatesPinnedInitialSnapshot() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).path
    let manager = BackupManager(backupRoot: root)
    let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).path
    try "pristine".write(toFile: file, atomically: true, encoding: .utf8)

    _ = try manager.backup(files: [file])
    try "changed".write(toFile: file, atomically: true, encoding: .utf8)
    // 触发大量备份，验证 initial 不被 prune
    for i in 0..<15 {
        try "v\(i)".write(toFile: file, atomically: true, encoding: .utf8)
        _ = try manager.backup(files: [file])
    }

    let initialDir = (root as NSString).appendingPathComponent("initial")
    #expect(FileManager.default.fileExists(atPath: initialDir))
    let items = try FileManager.default.contentsOfDirectory(atPath: initialDir)
    #expect(items.count == 1)
    let saved = try String(contentsOfFile: (initialDir as NSString).appendingPathComponent(items[0]), encoding: .utf8)
    #expect(saved == "pristine")  // initial 保存的是第一次备份时的内容
}
