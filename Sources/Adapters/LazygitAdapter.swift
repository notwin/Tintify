// Sources/Adapters/LazygitAdapter.swift
import Foundation

/// Adapter for lazygit.
struct LazygitAdapter: ToolAdapter {
    let id: ToolID = .lazygit

    var defaultConfigPath: String {
        NSHomeDirectory() + "/Library/Application Support/lazygit/config.yml"
    }

    func detectInstalled() -> Bool {
        ToolDetection.findExecutable("lazygit")
    }

    /// gui 段内的 theme 子块（2 空格缩进起）。
    private func themeBlockLines(palette p: Palette) -> [String] {
        """
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
        """.components(separatedBy: "\n")
    }

    /// Write the gui.theme section into the lazygit config.
    ///
    /// For new files the full content is written.
    /// For existing files, only the `gui.theme` subtree is replaced (or
    /// inserted); other `gui:` subkeys and other top-level sections are
    /// preserved untouched.
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

        if FileManager.default.fileExists(atPath: path) {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            var lines = content.components(separatedBy: "\n")

            if let guiIdx = lines.firstIndex(where: { $0.hasPrefix("gui:") }) {
                // gui 段边界：到下一个顶层键为止
                var guiEnd = guiIdx + 1
                while guiEnd < lines.count {
                    let line = lines[guiEnd]
                    if !line.isEmpty && !line.hasPrefix(" ") && !line.hasPrefix("\t") { break }
                    guiEnd += 1
                }
                let newTheme = themeBlockLines(palette: p)

                // 在 gui 段内定位 theme: 子键
                if let themeIdx = (guiIdx + 1..<guiEnd).first(where: {
                    lines[$0].trimmingCharacters(in: .whitespaces).hasPrefix("theme:")
                }) {
                    // theme 子块范围：到第一个缩进 <= theme 缩进的非空行为止
                    let themeIndent = lines[themeIdx].prefix(while: { $0 == " " }).count
                    var themeEnd = themeIdx + 1
                    while themeEnd < guiEnd {
                        let line = lines[themeEnd]
                        let trimmed = line.trimmingCharacters(in: .whitespaces)
                        let indent = line.prefix(while: { $0 == " " }).count
                        if !trimmed.isEmpty && indent <= themeIndent { break }
                        themeEnd += 1
                    }
                    lines.replaceSubrange(themeIdx..<themeEnd, with: newTheme)
                } else {
                    lines.insert(contentsOf: newTheme, at: guiIdx + 1)
                }
            } else {
                // 无 gui 段：追加 "gui:" + theme 子块
                if lines.last?.isEmpty == false { lines.append("") }
                lines.append("gui:")
                lines.append(contentsOf: themeBlockLines(palette: p))
            }

            // Remove leading blank lines
            while lines.first?.isEmpty == true {
                lines.removeFirst()
            }

            try ConfigWriter.atomicWrite(lines.joined(separator: "\n"), to: path)
        } else {
            let guiSection = "gui:\n" + themeBlockLines(palette: p).joined(separator: "\n")
            try ConfigWriter.atomicWrite(guiSection, to: path)
        }
    }
}
