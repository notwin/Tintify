// Sources/Adapters/WezTermAdapter.swift
import Foundation

/// Adapter for WezTerm terminal emulator.
struct WezTermAdapter: ToolAdapter {
    let toolName = "wezterm"

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.wezterm.lua"
    }

    /// Write color_scheme into the Tintify marker block in wezterm.lua.
    ///
    /// For themes with a WezTerm built-in name, sets `config.color_scheme`.
    /// For custom/original themes, defines an inline color_schemes table.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath
        let schemeName = theme.nameForTool(toolName)

        let luaContent: String
        if theme.toolNames["wezterm"] != nil || theme.compatibility == .full {
            // Built-in theme — just set the name
            luaContent = "config.color_scheme = \"\(schemeName)\""
        } else {
            // Custom theme — define colors inline
            luaContent = buildCustomScheme(theme: theme, name: schemeName)
        }

        try writeLuaMarkerBlock(to: path, content: luaContent)
    }

    /// Build inline WezTerm color_schemes definition from palette.
    private func buildCustomScheme(theme: Theme, name: String) -> String {
        let p = theme.palette
        return """
            config.color_schemes = config.color_schemes or {}
            config.color_schemes["\(name)"] = {
              foreground = "\(p.text)",
              background = "\(p.base)",
              cursor_bg = "\(p.rosewater)",
              cursor_fg = "\(p.base)",
              selection_bg = "\(p.surface1)",
              selection_fg = "\(p.text)",
              ansi = {"\(p.crust)", "\(p.red)", "\(p.green)", "\(p.yellow)", "\(p.blue)", "\(p.pink)", "\(p.teal)", "\(p.subtext1)"},
              brights = {"\(p.surface1)", "\(p.maroon)", "\(p.green)", "\(p.yellow)", "\(p.sapphire)", "\(p.mauve)", "\(p.sky)", "\(p.text)"},
            }
            config.color_scheme = "\(name)"
            """
    }

    /// Write a marker block using Lua comments (-- instead of #).
    private func writeLuaMarkerBlock(to path: String, content: String) throws {
        let startMarker = "-- === TINTIFY START ==="
        let endMarker = "-- === TINTIFY END ==="

        let fileContent: String
        if FileManager.default.fileExists(atPath: path) {
            fileContent = try String(contentsOfFile: path, encoding: .utf8)
        } else {
            fileContent = """
                local wezterm = require 'wezterm'
                local config = {}

                return config
                """
        }

        var lines = fileContent.components(separatedBy: "\n")
        let startIdx = lines.firstIndex { $0.trimmingCharacters(in: .whitespaces) == startMarker }
        let endIdx = lines.firstIndex { $0.trimmingCharacters(in: .whitespaces) == endMarker }

        let block = [startMarker, content, endMarker]

        if let start = startIdx, let end = endIdx, end > start {
            lines.replaceSubrange(start...end, with: block)
        } else {
            if let returnIdx = lines.lastIndex(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("return config") || $0.trimmingCharacters(in: .whitespaces).hasPrefix("return ") }) {
                lines.insert(contentsOf: block + [""], at: returnIdx)
            } else {
                if lines.last?.isEmpty == false { lines.append("") }
                lines.append(contentsOf: block)
                lines.append("")
            }
        }

        let parentDir = (path as NSString).deletingLastPathComponent
        if !FileManager.default.fileExists(atPath: parentDir) {
            try FileManager.default.createDirectory(atPath: parentDir, withIntermediateDirectories: true)
        }

        try ConfigWriter.atomicWrite(lines.joined(separator: "\n"), to: path)
    }
}
