import Foundation

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
        let startIdx = lines.firstIndex { $0.trimmingCharacters(in: .whitespaces) == startMarker }
        let endIdx = lines.firstIndex { $0.trimmingCharacters(in: .whitespaces) == endMarker }

        let block = [startMarker, content, endMarker]

        if let start = startIdx, let end = endIdx, end > start {
            lines.replaceSubrange(start...end, with: block)
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
