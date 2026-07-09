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

    /// symlink 安全的原子写入：先解析链接，把内容写到真实目标文件。
    ///
    /// `String.write(atomically:)` 会用临时文件 rename 覆盖路径本身，
    /// 若路径是 symlink 会将其替换为普通文件，破坏用户的 dotfiles 链接。
    static func atomicWrite(_ content: String, to path: String) throws {
        let resolved = URL(fileURLWithPath: path).resolvingSymlinksInPath().path
        try content.write(toFile: resolved, atomically: true, encoding: .utf8)
    }

    /// Insert or replace a TINTIFY START/END marker block in the file at `path`.
    ///
    /// If a marker block already exists it is replaced in-place.
    /// Otherwise the block is appended to the end of the file.
    ///
    /// Args:
    ///   path: Absolute path to the config file.
    ///   content: The text to place between the markers.
    ///   commentPrefix: The line-comment token for the target file's syntax (e.g. `"#"`, `"\""` for Vim script).
    ///   insertBeforeLine: Only consulted when no existing block is found. If it matches a line,
    ///     the block is inserted before the last matching line instead of being appended at the end.
    static func writeMarkerBlock(to path: String, content: String, commentPrefix: String = "#", insertBeforeLine: ((String) -> Bool)? = nil) throws {
        let startMarker = "\(commentPrefix) === TINTIFY START ==="
        let endMarker = "\(commentPrefix) === TINTIFY END ==="

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
            if let predicate = insertBeforeLine,
               let anchor = lines.lastIndex(where: { predicate($0) }) {
                lines.insert(contentsOf: block + [""], at: anchor)
            } else {
                if lines.last?.isEmpty == false { lines.append("") }
                lines.append(contentsOf: block)
                lines.append("")
            }
        }

        try atomicWrite(lines.joined(separator: "\n"), to: path)
    }

    /// Remove all TINTIFY marker blocks using the given `commentPrefix` from the file at `path`.
    ///
    /// Used to migrate files that were previously written with the wrong comment syntax
    /// (e.g. `#` markers in a `.vimrc`, which Vim script cannot parse). Unlike `writeMarkerBlock`,
    /// this is deliberately lenient: paired blocks are removed in full, and orphan marker lines
    /// (no matching partner) are removed individually rather than causing a throw.
    ///
    /// Args:
    ///   path: Absolute path to the config file.
    ///   commentPrefix: The line-comment token the old markers were written with (e.g. `"#"`).
    static func removeMarkerBlocks(from path: String, commentPrefix: String) throws {
        guard FileManager.default.fileExists(atPath: path) else { return }

        let startMarker = "\(commentPrefix) === TINTIFY START ==="
        let endMarker = "\(commentPrefix) === TINTIFY END ==="

        let fileContent = try String(contentsOfFile: path, encoding: .utf8)
        var lines = fileContent.components(separatedBy: "\n")

        var removeRanges: [ClosedRange<Int>] = []
        var pendingStart: Int?
        for (i, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == startMarker {
                if let orphan = pendingStart {
                    // 前一个 start 没等到 end，单独删除它
                    removeRanges.append(orphan...orphan)
                }
                pendingStart = i
            } else if trimmed == endMarker {
                if let start = pendingStart {
                    removeRanges.append(start...i)
                    pendingStart = nil
                } else {
                    // 孤儿 end 标记，单独删除
                    removeRanges.append(i...i)
                }
            }
        }
        if let orphan = pendingStart {
            removeRanges.append(orphan...orphan)
        }

        guard !removeRanges.isEmpty else { return }

        // 从后往前删除，避免索引错位
        for range in removeRanges.sorted(by: { $0.lowerBound > $1.lowerBound }) {
            lines.removeSubrange(range)
        }

        try atomicWrite(lines.joined(separator: "\n"), to: path)
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

        try atomicWrite(lines.joined(separator: "\n"), to: path)
    }

    /// 在 TOML 文件的顶层区域（第一个 [section] 之前）替换或插入一个键。
    ///
    /// `replaceLine` 找不到时会追加到文件末尾——在 TOML 中那属于最后一个
    /// section，顶层键必须插在第一个 section 头之前。
    static func replaceTopLevelKey(in path: String, key: String, line newLine: String) throws {
        let fileContent: String
        if FileManager.default.fileExists(atPath: path) {
            fileContent = try String(contentsOfFile: path, encoding: .utf8)
        } else {
            fileContent = ""
        }
        var lines = fileContent.components(separatedBy: "\n")

        let firstSection = lines.firstIndex {
            $0.trimmingCharacters(in: .whitespaces).hasPrefix("[")
        } ?? lines.count

        if let idx = lines[..<firstSection].firstIndex(where: {
            $0.hasPrefix("\(key) =") || $0.hasPrefix("\(key)=")
        }) {
            lines[idx] = newLine
        } else {
            lines.insert(contentsOf: [newLine, ""], at: firstSection)
        }

        try atomicWrite(lines.joined(separator: "\n"), to: path)
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

        try atomicWrite(lines.joined(separator: "\n"), to: path)
    }
}
