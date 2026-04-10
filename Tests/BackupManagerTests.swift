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
    #expect(list.count == 2)
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
