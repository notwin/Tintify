// Backup and restore manager for configuration files.

import Foundation

/// Metadata about a single backup snapshot.
struct BackupInfo: Identifiable {
    let id: String
    let date: Date
    let path: String
}

/// Manages file backups with automatic pruning to keep at most 10 snapshots.
final class BackupManager {
    let backupRoot: String
    private let fm = FileManager.default
    private let maxBackups = 10
    private static let dateFormat = "yyyyMMdd-HHmmss-SSS"
    private static let dateFormatLength = 19

    init(backupRoot: String = NSHomeDirectory() + "/.tintify/backups") {
        self.backupRoot = backupRoot
    }

    /// Create a backup of the given files and return a unique backup ID.
    ///
    /// Args:
    ///     files: Absolute paths to files that should be backed up.
    ///
    /// Returns:
    ///     A unique string identifier for the created backup.
    func backup(files: [String]) throws -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Self.dateFormat
        let backupId = formatter.string(from: Date()) + "-" + UUID().uuidString.prefix(8)
        let backupDir = (backupRoot as NSString).appendingPathComponent(backupId)

        try fm.createDirectory(atPath: backupDir, withIntermediateDirectories: true)

        // initial 快照增量补齐：每个文件第一次被 Tintify 触碰前的原始状态永久保留，
        // 已存在的文件绝不覆盖，滚动淘汰也不能吃掉它
        let initialDir = (backupRoot as NSString).appendingPathComponent("initial")
        try fm.createDirectory(atPath: initialDir, withIntermediateDirectories: true)
        for file in files where fm.fileExists(atPath: file) {
            let encoded = file.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? file
            let dest = (initialDir as NSString).appendingPathComponent(encoded)
            if !fm.fileExists(atPath: dest) {
                try fm.copyItem(atPath: file, toPath: dest)
            }
        }

        try copyFiles(files, into: backupDir)

        prune()
        return backupId
    }

    /// Copy each existing file into `dir`, percent-encoding its path as the destination name.
    private func copyFiles(_ files: [String], into dir: String) throws {
        for file in files where fm.fileExists(atPath: file) {
            let encoded = file.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? file
            let dest = (dir as NSString).appendingPathComponent(encoded)
            try fm.copyItem(atPath: file, toPath: dest)
        }
    }

    /// Restore files from a previously created backup.
    ///
    /// Args:
    ///     backupId: The identifier returned by a prior call to `backup(files:)`.
    func restore(backupId: String) throws {
        let backupDir = (backupRoot as NSString).appendingPathComponent(backupId)
        let items = try fm.contentsOfDirectory(atPath: backupDir)

        for item in items {
            let originalPath = item.removingPercentEncoding ?? item
            let backupFile = (backupDir as NSString).appendingPathComponent(item)

            let parentDir = (originalPath as NSString).deletingLastPathComponent
            if !fm.fileExists(atPath: parentDir) {
                try fm.createDirectory(atPath: parentDir, withIntermediateDirectories: true)
            }

            if fm.fileExists(atPath: originalPath) {
                try fm.removeItem(atPath: originalPath)
            }
            try fm.copyItem(atPath: backupFile, toPath: originalPath)
        }
    }

    /// List all existing backups, sorted newest first.
    ///
    /// Returns:
    ///     An array of ``BackupInfo`` describing each available backup.
    func listBackups() -> [BackupInfo] {
        guard let items = try? fm.contentsOfDirectory(atPath: backupRoot) else { return [] }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Self.dateFormat

        return items.sorted().reversed().compactMap { name in
            let path = (backupRoot as NSString).appendingPathComponent(name)
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue else {
                return nil
            }

            // 从备份 ID 解析日期，格式: "yyyyMMdd-HHmmss-SSS-xxxxxxxx"
            // 取前 19 个字符作为日期部分
            let dateString = String(name.prefix(Self.dateFormatLength))
            let date: Date
            if let parsed = dateFormatter.date(from: dateString) {
                date = parsed
            } else if let attrs = try? fm.attributesOfItem(atPath: path),
                      let modDate = attrs[.modificationDate] as? Date {
                date = modDate
            } else {
                date = Date()
            }

            return BackupInfo(id: name, date: date, path: path)
        }
    }

    /// Remove oldest backups so that at most ``maxBackups`` remain.
    private func prune() {
        let backups = listBackups()
        guard backups.count > maxBackups else { return }
        for old in backups[maxBackups...] where old.id != "initial" {
            try? fm.removeItem(atPath: old.path)
        }
    }
}
