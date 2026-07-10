// Sources/Adapters/WezTermAdapter.swift
import Foundation

enum WezTermAdapterError: LocalizedError {
    case unrecognizedStructure(path: String)

    var errorDescription: String? {
        switch self {
        case .unrecognizedStructure(let path):
            return L("无法识别 wezterm.lua 的结构（未找到 return <变量名>）：\(path)。请手动在配置中设置 color_scheme。")
        }
    }
}

/// Adapter for WezTerm terminal emulator.
struct WezTermAdapter: ToolAdapter {
    let id: ToolID = .wezterm

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.wezterm.lua"
    }

    func detectInstalled() -> Bool {
        ToolDetection.findExecutable("wezterm")
            || FileManager.default.fileExists(atPath: "/Applications/WezTerm.app")
    }

    /// Write color_scheme into the Tintify marker block in wezterm.lua.
    ///
    /// For themes with a WezTerm built-in name, sets `<var>.color_scheme`.
    /// For custom/original themes, defines an inline color_schemes table.
    ///
    /// The config's local variable name (commonly `config`, but also `c` when users write
    /// `local c = wezterm.config_builder() ... return c`) is detected from the file's
    /// `return <identifier>` line so the injected block never references an undefined global.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath

        if !FileManager.default.fileExists(atPath: path) {
            let parentDir = (path as NSString).deletingLastPathComponent
            if !FileManager.default.fileExists(atPath: parentDir) {
                try FileManager.default.createDirectory(atPath: parentDir, withIntermediateDirectories: true)
            }
            let template = """
                local wezterm = require 'wezterm'
                local config = {}

                return config
                """
            try ConfigWriter.atomicWrite(template, to: path)
        }

        let fileContent = try String(contentsOfFile: path, encoding: .utf8)
        guard let varName = detectConfigVariable(in: fileContent) else {
            throw WezTermAdapterError.unrecognizedStructure(path: path)
        }

        let luaContent: String
        switch theme.themeSource(for: .wezterm) {
        case .builtin(let name):
            luaContent = "\(varName).color_scheme = \"\(name)\""
        case .generate(let name):
            luaContent = buildCustomScheme(theme: theme, name: name, varName: varName)
        }

        try ConfigWriter.writeMarkerBlock(
            to: path,
            content: luaContent,
            commentPrefix: "--",
            insertBeforeLine: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("return ") }
        )
    }

    /// Build inline WezTerm color_schemes definition from palette.
    /// 16 色 ANSI 槽位统一走 AnsiPalette（三个终端生成器共用）。
    private func buildCustomScheme(theme: Theme, name: String, varName: String) -> String {
        let p = theme.palette
        let ansi = AnsiPalette.colors(for: theme)
        let normal = ansi[0..<8].map { "\"\($0)\"" }.joined(separator: ", ")
        let brights = ansi[8..<16].map { "\"\($0)\"" }.joined(separator: ", ")
        return """
            \(varName).color_schemes = \(varName).color_schemes or {}
            \(varName).color_schemes["\(name)"] = {
              foreground = "\(p.text)",
              background = "\(p.base)",
              cursor_bg = "\(p.rosewater)",
              cursor_fg = "\(p.base)",
              selection_bg = "\(p.surface1)",
              selection_fg = "\(p.text)",
              ansi = {\(normal)},
              brights = {\(brights)},
            }
            \(varName).color_scheme = "\(name)"
            """
    }

    /// 从 "return <identifier>" 行提取配置变量名。
    private func detectConfigVariable(in content: String) -> String? {
        let pattern = #"^\s*return\s+([A-Za-z_][A-Za-z0-9_]*)\s*$"#
        let regex = try! NSRegularExpression(pattern: pattern)
        for line in content.components(separatedBy: "\n").reversed() {
            let range = NSRange(line.startIndex..., in: line)
            if let match = regex.firstMatch(in: line, range: range),
               let r = Range(match.range(at: 1), in: line) {
                return String(line[r])
            }
        }
        return nil
    }
}
