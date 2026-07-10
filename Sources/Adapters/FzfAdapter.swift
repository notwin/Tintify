// Sources/Adapters/FzfAdapter.swift
import Foundation

/// Adapter for fzf (fuzzy finder).
struct FzfAdapter: ToolAdapter {
    let id: ToolID = .fzf

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.zshrc"
    }

    func detectInstalled() -> Bool {
        ToolDetection.findExecutable("fzf")
    }

    /// Write FZF_DEFAULT_OPTS color scheme into the Tintify marker block.
    ///
    /// Preserves non-FZF lines (e.g. BAT_THEME) already present in the block.
    ///
    /// Args:
    ///   theme: The theme to apply.
    ///   configPath: Optional override path.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath
        let p = theme.palette

        let fzfLines = """
            export FZF_DEFAULT_OPTS=" \\
            --color=bg+:\(p.surface0),bg:\(p.base),spinner:\(p.rosewater),hl:\(p.red) \\
            --color=fg:\(p.text),header:\(p.red),info:\(p.mauve),pointer:\(p.rosewater) \\
            --color=marker:\(p.lavender),fg+:\(p.text),prompt:\(p.mauve),hl+:\(p.red) \\
            --color=border:\(p.overlay0)"
            """

        // Read existing marker block content to preserve other adapters' lines.
        let existing = BatAdapter.readExistingMarkerContent(from: path)
        let otherLines = existing.filter { !$0.contains("FZF_DEFAULT_OPTS") && !$0.trimmingCharacters(in: .whitespaces).hasPrefix("--color=") }
        let combined = (otherLines + [fzfLines]).joined(separator: "\n")

        try ConfigWriter.writeMarkerBlock(to: path, content: combined)
    }
}
