// Sources/Adapters/VimAdapter.swift
import Foundation

/// Adapter for Vim. Generates a colorscheme file and sets it in .vimrc.
struct VimAdapter: ToolAdapter {
    let toolName = "vim"
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

    func apply(theme: Theme, configPath: String? = nil) throws {
        let effectiveVimrc = configPath ?? vimrcPath

        try FileManager.default.createDirectory(
            atPath: colorsDir, withIntermediateDirectories: true
        )

        let colorscheme = buildColorscheme(theme: theme)
        let colorschemeFile = (colorsDir as NSString).appendingPathComponent("tintify.vim")
        try colorscheme.write(toFile: colorschemeFile, atomically: true, encoding: .utf8)

        let vimrcLine = "colorscheme tintify"
        // 迁移：清理 v1.7 以前误写入的 shell 风格标记（vim 会报 E488）
        try ConfigWriter.removeMarkerBlocks(from: effectiveVimrc, commentPrefix: "#")
        try ConfigWriter.writeMarkerBlock(to: effectiveVimrc, content: vimrcLine, commentPrefix: "\"")
    }

    private func buildColorscheme(theme: Theme) -> String {
        let p = theme.palette
        let bg = theme.appearance == .dark ? "dark" : "light"

        return """
            " Tintify-managed colorscheme — do not edit manually
            set background=\(bg)
            highlight clear
            if exists("syntax_on")
              syntax reset
            endif
            let g:colors_name = "tintify"

            highlight Normal guifg=\(p.text) guibg=\(p.base)
            highlight Comment guifg=\(p.overlay1) gui=italic
            highlight String guifg=\(p.green)
            highlight Number guifg=\(p.peach)
            highlight Keyword guifg=\(p.mauve)
            highlight Function guifg=\(p.blue)
            highlight Type guifg=\(p.yellow)
            highlight Statement guifg=\(p.mauve)
            highlight Identifier guifg=\(p.flamingo)
            highlight Constant guifg=\(p.peach)
            highlight PreProc guifg=\(p.pink)
            highlight Special guifg=\(p.rosewater)
            highlight Operator guifg=\(p.sky)
            highlight Error guifg=\(p.red) guibg=\(p.base)
            highlight Todo guifg=\(p.yellow) guibg=\(p.base) gui=bold
            highlight LineNr guifg=\(p.surface1)
            highlight CursorLine guibg=\(p.surface0) cterm=NONE
            highlight CursorLineNr guifg=\(p.lavender)
            highlight Visual guibg=\(p.surface1)
            highlight StatusLine guifg=\(p.text) guibg=\(p.mantle)
            highlight StatusLineNC guifg=\(p.subtext0) guibg=\(p.mantle)
            highlight Pmenu guifg=\(p.text) guibg=\(p.surface0)
            highlight PmenuSel guifg=\(p.base) guibg=\(p.blue)
            highlight Search guifg=\(p.base) guibg=\(p.yellow)
            highlight VertSplit guifg=\(p.surface0)
            highlight TabLine guifg=\(p.subtext0) guibg=\(p.mantle)
            highlight TabLineSel guifg=\(p.base) guibg=\(p.blue)
            """
    }
}
