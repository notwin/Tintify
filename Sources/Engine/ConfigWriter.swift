import Foundation

/// ConfigWriter 遇到无法安全处理的文件结构时抛出的错误。
enum ConfigWriterError: LocalizedError, Equatable {
    case corruptedMarkers(path: String)

    var errorDescription: String? {
        switch self {
        case .corruptedMarkers(let path):
            return "配置文件中的 TINTIFY 标记不完整（START/END 不成对）：\(path)。请手动删除残留的标记行后重试。"
        }
    }
}

/// Utility for safely reading and writing marker-delimited blocks in config files.
enum ConfigWriter {
    static let startMarker = "# === TINTIFY START ==="
    static let endMarker = "# === TINTIFY END ==="

    /// Insert or replace a TINTIFY START/END marker block in the file at `path`.
    ///
    /// If a marker block already exists it is replaced in-place.
    /// Otherwise the block is appended to the end of the file.
    ///
    /// Args:
    ///   path: Absolute path to the config file.
    ///   content: The text to place between the markers.
    static func writeMarkerBlock(to path: String, content: String) throws {
        let fileContent: String
        if FileManager.default.fileExists(atPath: path) {
            fileContent = try String(contentsOfFile: path, encoding: .utf8)
        } else {
            fileContent = ""
        }

        var lines = fileContent.components(separatedBy: "\n")

        // 收集所有成对的标记块；孤儿/乱序标记视为文件损坏，拒绝写入
        var blocks: [(start: Int, end: Int)] = []
        var pendingStart: Int?
        for (i, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == startMarker {
                guard pendingStart == nil else { throw ConfigWriterError.corruptedMarkers(path: path) }
                pendingStart = i
            } else if trimmed == endMarker {
                guard let start = pendingStart else { throw ConfigWriterError.corruptedMarkers(path: path) }
                blocks.append((start, i))
                pendingStart = nil
            }
        }
        guard pendingStart == nil else { throw ConfigWriterError.corruptedMarkers(path: path) }

        let block = [startMarker, content, endMarker]

        if let first = blocks.first {
            // 从后往前删除多余块，再原位替换第一个块
            for extra in blocks.dropFirst().reversed() {
                lines.removeSubrange(extra.start...extra.end)
            }
            lines.replaceSubrange(first.start...first.end, with: block)
        } else {
            if lines.last?.isEmpty == false { lines.append("") }
            lines.append(contentsOf: block)
            lines.append("")
        }

        try lines.joined(separator: "\n").write(toFile: path, atomically: true, encoding: .utf8)
    }

    /// Replace the first line matching `prefix` with `newLine`, or append if no match.
    ///
    /// Args:
    ///   path: Absolute path to the config file.
    ///   prefix: The prefix to search for in existing lines.
    ///   newLine: The full replacement line.
    static func replaceLine(in path: String, prefix: String, newLine: String) throws {
        let fileContent: String
        if FileManager.default.fileExists(atPath: path) {
            fileContent = try String(contentsOfFile: path, encoding: .utf8)
        } else {
            fileContent = ""
        }

        var lines = fileContent.components(separatedBy: "\n")
        if let idx = lines.firstIndex(where: { $0.hasPrefix(prefix) }) {
            lines[idx] = newLine
        } else {
            if lines.last?.isEmpty == false { lines.append("") }
            lines.append(newLine)
        }

        try lines.joined(separator: "\n").write(toFile: path, atomically: true, encoding: .utf8)
    }

    /// Replace an entire TOML section (from `[sectionPrefix` to the next `[` header) with new content.
    ///
    /// If the section does not exist it is appended.
    ///
    /// Args:
    ///   path: Absolute path to the TOML file.
    ///   sectionPrefix: The section header prefix to match (e.g. "[theme]").
    ///   newContent: The replacement text including the section header.
    static func replaceTOMLSection(in path: String, sectionPrefix: String, newContent: String) throws {
        let fileContent: String
        if FileManager.default.fileExists(atPath: path) {
            fileContent = try String(contentsOfFile: path, encoding: .utf8)
        } else {
            let parentDir = (path as NSString).deletingLastPathComponent
            if !FileManager.default.fileExists(atPath: parentDir) {
                try FileManager.default.createDirectory(atPath: parentDir, withIntermediateDirectories: true)
            }
            fileContent = ""
        }
        var lines = fileContent.components(separatedBy: "\n")

        let startIdx = lines.firstIndex { $0.hasPrefix(sectionPrefix) }
        if let start = startIdx {
            var end = start + 1
            while end < lines.count && !lines[end].hasPrefix("[") {
                end += 1
            }
            let replacement = newContent.components(separatedBy: "\n")
            lines.replaceSubrange(start..<end, with: replacement)
        } else {
            lines.append("")
            lines.append(contentsOf: newContent.components(separatedBy: "\n"))
        }

        try lines.joined(separator: "\n").write(toFile: path, atomically: true, encoding: .utf8)
    }
}
