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
        formatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
        let backupId = formatter.string(from: Date()) + "-" + UUID().uuidString.prefix(8)
        let backupDir = (backupRoot as NSString).appendingPathComponent(backupId)

        try fm.createDirectory(atPath: backupDir, withIntermediateDirectories: true)

        for file in files where fm.fileExists(atPath: file) {
            let dest = (backupDir as NSString).appendingPathComponent(
                file.replacingOccurrences(of: "/", with: "__")
            )
            try fm.copyItem(atPath: file, toPath: dest)
        }

        prune()
        return backupId
    }

    /// Restore files from a previously created backup.
    ///
    /// Args:
    ///     backupId: The identifier returned by a prior call to `backup(files:)`.
    func restore(backupId: String) throws {
        let backupDir = (backupRoot as NSString).appendingPathComponent(backupId)
        let items = try fm.contentsOfDirectory(atPath: backupDir)

        for item in items {
            let originalPath = item.replacingOccurrences(of: "__", with: "/")
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

        return items.sorted().reversed().compactMap { name in
            let path = (backupRoot as NSString).appendingPathComponent(name)
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue else {
                return nil
            }
            return BackupInfo(id: name, date: Date(), path: path)
        }
    }

    /// Remove oldest backups so that at most ``maxBackups`` remain.
    private func prune() {
        let backups = listBackups()
        guard backups.count > maxBackups else { return }
        for old in backups[maxBackups...] {
            try? fm.removeItem(atPath: old.path)
        }
    }
}
