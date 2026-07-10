// Sources/Adapters/BatAdapter.swift
import Foundation

/// Adapter for the bat syntax highlighter.
struct BatAdapter: ToolAdapter {
    let id: ToolID = .bat

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.zshrc"
    }

    func detectInstalled() -> Bool {
        ToolDetection.findExecutable("bat")
    }

    /// Write `export BAT_THEME` into the Tintify marker block.
    ///
    /// Preserves non-BAT lines (e.g. FZF) already present in the block.
    ///
    /// Args:
    ///   theme: The theme to apply.
    ///   configPath: Optional override path.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath
        let batLine = "export BAT_THEME=\"\(theme.nameForTool(toolName))\""

        // Read existing marker block content to preserve other adapters' lines.
        let existing = Self.readExistingMarkerContent(from: path)
        let otherLines = existing.filter { !$0.contains("BAT_THEME") }
        let combined = (otherLines + [batLine]).joined(separator: "\n")

        try ConfigWriter.writeMarkerBlock(to: path, content: combined)
    }

    /// Read lines between TINTIFY markers from the given file.
    ///
    /// Args:
    ///   path: Absolute path to the file.
    ///
    /// Returns:
    ///   Array of non-empty lines found between markers.
    static func readExistingMarkerContent(from path: String) -> [String] {
        guard FileManager.default.fileExists(atPath: path),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return []
        }

        let lines = content.components(separatedBy: "\n")
        guard let startIdx = lines.firstIndex(where: {
            $0.trimmingCharacters(in: .whitespaces) == ConfigWriter.startMarker
        }),
        let endIdx = lines.firstIndex(where: {
            $0.trimmingCharacters(in: .whitespaces) == ConfigWriter.endMarker
        }),
        endIdx > startIdx else {
            return []
        }

        return Array(lines[(startIdx + 1)..<endIdx]).filter { !$0.isEmpty }
    }
}
