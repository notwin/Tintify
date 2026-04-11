// Sources/Adapters/LazygitAdapter.swift
import Foundation

/// Adapter for lazygit.
struct LazygitAdapter: ToolAdapter {
    let toolName = "lazygit"

    var defaultConfigPath: String {
        NSHomeDirectory() + "/Library/Application Support/lazygit/config.yml"
    }

    /// Write the gui.theme section into the lazygit config.
    ///
    /// For new files the full content is written.
    /// For existing files the `gui:` section is replaced or appended.
    ///
    /// Args:
    ///   theme: The theme to apply.
    ///   configPath: Optional override path.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath
        let p = theme.palette

        // Ensure parent directory exists.
        let dir = (path as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(
            atPath: dir, withIntermediateDirectories: true
        )

        let guiSection = """
            gui:
              theme:
                activeBorderColor:
                  - "\(p.blue)"
                  - bold
                inactiveBorderColor:
                  - "\(p.subtext0)"
                selectedLineBgColor:
                  - "\(p.surface0)"
                cherryPickedCommitFgColor:
                  - "\(p.blue)"
                cherryPickedCommitBgColor:
                  - "\(p.surface1)"
                markedBaseCommitFgColor:
                  - "\(p.blue)"
                markedBaseCommitBgColor:
                  - "\(p.surface1)"
                unstagedChangesColor:
                  - "\(p.red)"
                defaultFgColor:
                  - "\(p.text)"
                searchingActiveBorderColor:
                  - "\(p.mauve)"
                optionsTextColor:
                  - "\(p.subtext1)"
                inactiveViewSelectedLineBgColor:
                  - "\(p.surface1)"
                selectedRangeBgColor:
                  - "\(p.surface1)"
            """

        if FileManager.default.fileExists(atPath: path) {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            var lines = content.components(separatedBy: "\n")

            if let guiIdx = lines.firstIndex(where: { $0.hasPrefix("gui:") }) {
                // Find the end of the gui section (next top-level key).
                var endIdx = guiIdx + 1
                while endIdx < lines.count {
                    let line = lines[endIdx]
                    if !line.isEmpty && !line.hasPrefix(" ") && !line.hasPrefix("\t") {
                        break
                    }
                    endIdx += 1
                }
                let replacement = guiSection.components(separatedBy: "\n")
                lines.replaceSubrange(guiIdx..<endIdx, with: replacement)
            } else {
                lines.append("")
                lines.append(contentsOf: guiSection.components(separatedBy: "\n"))
            }

            // Remove leading blank lines
            while lines.first?.isEmpty == true {
                lines.removeFirst()
            }

            try lines.joined(separator: "\n")
                .write(toFile: path, atomically: true, encoding: .utf8)
        } else {
            try guiSection.write(toFile: path, atomically: true, encoding: .utf8)
        }
    }
}
