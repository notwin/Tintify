// Sources/Adapters/VimAdapter.swift
import Foundation

/// Adapter for Vim. Generates a colorscheme file and sets it in .vimrc.
struct VimAdapter: ToolAdapter {
    let id: ToolID = .vim
    let colorsDir: String
    let vimrcPath: String

    var defaultConfigPath: String { vimrcPath }

    init(
        colorsDir: String = NSHomeDirectory() + "/.vim/colors",
        vimrcPath: String = NSHomeDirectory() + "/.vimrc"
    ) {
        self.colorsDir = colorsDir
        self.vimrcPath = vimrcPath
    }

    func detectInstalled() -> Bool {
        ToolDetection.findExecutable("vim")
    }

    func apply(theme: Theme, configPath: String? = nil) throws {
        let effectiveVimrc = configPath ?? vimrcPath

        try FileManager.default.createDirectory(
            atPath: colorsDir, withIntermediateDirectories: true
        )

        let colorscheme = buildColorscheme(theme: theme)
        let colorschemeFile = (colorsDir as NSString).appendingPathComponent("tintify.vim")
        try ConfigWriter.atomicWrite(colorscheme, to: colorschemeFile)

        // 新建（或只含 Tintify 块的）vimrc 会让 vim 跳过 defaults.vim，
        // 语法高亮等出厂默认全丢——在块里补回来
        var blockLines: [String] = []
        if needsDefaultsSource(vimrcPath: effectiveVimrc) {
            blockLines.append("unlet! skip_defaults_vim")
            blockLines.append("source $VIMRUNTIME/defaults.vim")
        }
        blockLines.append("colorscheme tintify")

        // 迁移：清理 v1.7 以前误写入的 shell 风格标记（vim 会报 E488）
        try ConfigWriter.removeMarkerBlocks(from: effectiveVimrc, commentPrefix: "#")
        try ConfigWriter.writeMarkerBlock(
            to: effectiveVimrc, content: blockLines.joined(separator: "\n"), commentPrefix: "\"")
    }

    /// vimrc 不存在，或除 Tintify 块外没有实质内容时，需要替用户补 defaults.vim。
    private func needsDefaultsSource(vimrcPath: String) -> Bool {
        guard let content = try? String(contentsOfFile: vimrcPath, encoding: .utf8) else { return true }
        var inBlock = false
        for line in content.components(separatedBy: "\n") {
            let t = line.trimmingCharacters(in: .whitespaces)
            if t == "\" === TINTIFY START ===" { inBlock = true; continue }
            if t == "\" === TINTIFY END ===" { inBlock = false; continue }
            if !inBlock && !t.isEmpty { return false }
        }
        return true
    }

    private func buildColorscheme(theme: Theme) -> String {
        let p = theme.palette
        let bg = theme.appearance == .dark ? "dark" : "light"

        // 每条都显式写全 guifg/guibg/gui/cterm：highlight clear 重置到的是
        // vim 出厂默认组（StatusLine 带 reverse、TabLine 带 underline、
        // Visual 带 LightGrey 前景），不显式覆盖就会残留。
        func hi(_ group: String, fg: String = "NONE", bg: String = "NONE", attr: String = "NONE") -> String {
            "highlight \(group) guifg=\(fg) guibg=\(bg) gui=\(attr) cterm=\(attr)"
        }

        let rules = [
            hi("Normal", fg: p.text, bg: p.base),
            hi("Comment", fg: p.overlay1, attr: "italic"),
            hi("String", fg: p.green),
            hi("Number", fg: p.peach),
            hi("Keyword", fg: p.mauve),
            hi("Function", fg: p.blue),
            hi("Type", fg: p.yellow),
            hi("Statement", fg: p.mauve),
            hi("Identifier", fg: p.flamingo),
            hi("Constant", fg: p.peach),
            hi("PreProc", fg: p.pink),
            hi("Special", fg: p.rosewater),
            hi("Operator", fg: p.sky),
            hi("Error", fg: p.red, bg: p.base, attr: "bold"),
            hi("Todo", fg: p.yellow, bg: p.base, attr: "bold"),
            hi("LineNr", fg: p.overlay1),
            hi("CursorLine", bg: p.surface0),
            hi("CursorLineNr", fg: p.lavender),
            hi("Visual", bg: p.surface1),
            hi("StatusLine", fg: p.text, bg: p.mantle),
            hi("StatusLineNC", fg: p.subtext0, bg: p.mantle),
            hi("Pmenu", fg: p.text, bg: p.surface0),
            hi("PmenuSel", fg: p.base, bg: p.blue),
            hi("Search", fg: p.base, bg: p.yellow),
            hi("IncSearch", fg: p.base, bg: p.peach),
            hi("VertSplit", fg: p.surface0),
            hi("TabLine", fg: p.subtext0, bg: p.mantle),
            hi("TabLineSel", fg: p.base, bg: p.blue),
            hi("MatchParen", fg: p.peach, bg: p.surface1, attr: "bold"),
            hi("DiffAdd", fg: p.green, bg: p.surface0),
            hi("DiffChange", fg: p.yellow, bg: p.surface0),
            hi("DiffDelete", fg: p.red, bg: p.surface0),
            hi("DiffText", fg: p.yellow, bg: p.surface1, attr: "bold"),
            hi("Folded", fg: p.subtext0, bg: p.surface0),
            hi("FoldColumn", fg: p.overlay1, bg: p.base),
            hi("SignColumn", fg: p.overlay1, bg: p.base),
            hi("ColorColumn", bg: p.surface0),
            hi("ErrorMsg", fg: p.red, attr: "bold"),
            hi("WarningMsg", fg: p.yellow),
            hi("NonText", fg: p.overlay0),
            hi("SpecialKey", fg: p.overlay0),
            hi("Directory", fg: p.blue),
            hi("Title", fg: p.blue, attr: "bold"),
            hi("WildMenu", fg: p.base, bg: p.blue),
            hi("SpellBad", fg: p.red, attr: "underline"),
        ].joined(separator: "\n")

        return """
            " Tintify-managed colorscheme — do not edit manually
            " 本文件只写 gui 真彩色，终端 vim 必须开 termguicolors 才生效
            if has('termguicolors')
              set termguicolors
            endif
            set background=\(bg)
            highlight clear
            if exists("syntax_on")
              syntax reset
            endif
            let g:colors_name = "tintify"

            \(rules)
            """
    }
}
