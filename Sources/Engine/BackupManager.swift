// Backup and restore manager for configuration files.

import Foundation

/// Metadata about a single backup snapshot.
struct BackupInfo: Identifiable {
    let id: String
    let date: Date
    let path: String
    let themeId: String?
}

/// Manages file backups with automatic pruning to keep at most 10 snapshots.
final class BackupManager {
    let backupRoot: String
    private let fm = FileManager.default
    private let maxBackups = 10
    private static let dateFormat = "yyyyMMdd-HHmmss-SSS"
    private static let dateFormatLength = 19
    private static func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }

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
    func backup(files: [String], themeId: String? = nil) throws -> String {
        let formatter = Self.makeDateFormatter()
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
        // 记录备份文件对应的主题，供还原时同步 currentThemeId
        if let themeId {
            let metaPath = (backupDir as NSString).appendingPathComponent(".tintify-theme")
            try? themeId.write(toFile: metaPath, atomically: true, encoding: .utf8)
        }

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
    /// 先把全部备份文件复制到临时目录（读阶段），全部就绪后再覆盖原文件（写阶段）。
    /// 读阶段失败不会动原文件，避免中途失败留下半还原的不一致状态。
    ///
    /// Args:
    ///     backupId: The identifier returned by a prior call to `backup(files:)`.
    func restore(backupId: String) throws {
        try Self.validateBackupId(backupId)
        let backupDir = (backupRoot as NSString).appendingPathComponent(backupId)
        let items = try fm.contentsOfDirectory(atPath: backupDir)

        // 读阶段：全部备份文件复制到临时目录，任何失败都不动原文件
        let staging = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString).path
        try fm.createDirectory(atPath: staging, withIntermediateDirectories: true)
        defer { try? fm.removeItem(atPath: staging) }

        var restores: [(staged: String, original: String)] = []
        for item in items {
            let originalPath = item.removingPercentEncoding ?? item
            let backupFile = (backupDir as NSString).appendingPathComponent(item)
            guard fm.fileExists(atPath: backupFile) else { continue }
            let staged = (staging as NSString).appendingPathComponent(item)
            try fm.copyItem(atPath: backupFile, toPath: staged)
            restores.append((staged, originalPath))
        }

        // 写阶段：用暂存副本覆盖原文件
        for r in restores {
            let parentDir = (r.original as NSString).deletingLastPathComponent
            if !fm.fileExists(atPath: parentDir) {
                try fm.createDirectory(atPath: parentDir, withIntermediateDirectories: true)
            }
            if fm.fileExists(atPath: r.original) {
                try fm.removeItem(atPath: r.original)
            }
            try fm.copyItem(atPath: r.staged, toPath: r.original)
        }
    }

    /// 校验 backupId 格式，拒绝含路径分隔符/`..` 的输入以防路径穿越。
    private static func validateBackupId(_ backupId: String) throws {
        let valid = backupId == "initial"
            || backupId.range(of: #"^\d{8}-\d{6}-\d{3}-[0-9A-Fa-f]{8}$"#, options: .regularExpression) != nil
        guard valid else {
            throw NSError(domain: "BackupManager", code: 3,
                          userInfo: [NSLocalizedDescriptionKey: "无效的备份 ID: \(backupId)"])
        }
    }

    /// List all existing backups, sorted newest first.
    ///
    /// Returns:
    ///     An array of ``BackupInfo`` describing each available backup.
    func listBackups() -> [BackupInfo] {
        guard let items = try? fm.contentsOfDirectory(atPath: backupRoot) else { return [] }

        let dateFormatter = Self.makeDateFormatter()

        return items.sorted().reversed().compactMap { name -> BackupInfo? in
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

            let themeId = try? String(
                contentsOfFile: (path as NSString).appendingPathComponent(".tintify-theme"),
                encoding: .utf8)
            return BackupInfo(id: name, date: date, path: path, themeId: themeId)
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
