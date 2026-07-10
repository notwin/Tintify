import Testing
import Foundation
@testable import Tintify

@Test func vimAdapterGeneratesColorscheme() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

    let vimColors = tmpDir.appendingPathComponent("colors").path
    let vimrc = tmpDir.appendingPathComponent(".vimrc").path
    try "\" my vimrc".write(toFile: vimrc, atomically: true, encoding: .utf8)

    let adapter = VimAdapter(colorsDir: vimColors, vimrcPath: vimrc)
    let theme = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: theme, configPath: nil)

    let colorscheme = try String(contentsOfFile: vimColors + "/tintify.vim", encoding: .utf8)
    #expect(colorscheme.contains("colors_name"))
    #expect(colorscheme.contains("highlight Normal"))
    #expect(colorscheme.contains("highlight Comment"))
    #expect(colorscheme.contains("highlight String"))
    #expect(colorscheme.contains("set background=dark"))

    let vimrcContent = try String(contentsOfFile: vimrc, encoding: .utf8)
    #expect(vimrcContent.contains("colorscheme tintify"))
    #expect(vimrcContent.contains("TINTIFY START"))
    #expect(vimrcContent.contains("\" my vimrc"))
}

@Test func vimAdapterLightTheme() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

    let vimColors = tmpDir.appendingPathComponent("colors").path
    let vimrc = tmpDir.appendingPathComponent(".vimrc").path
    try "".write(toFile: vimrc, atomically: true, encoding: .utf8)

    let adapter = VimAdapter(colorsDir: vimColors, vimrcPath: vimrc)
    let theme = ThemeRegistry.shared.theme(id: "catppuccin-latte")!
    try adapter.apply(theme: theme, configPath: nil)

    let colorscheme = try String(contentsOfFile: vimColors + "/tintify.vim", encoding: .utf8)
    #expect(colorscheme.contains("set background=light"))
}

@Test func vimColorschemeEnablesTermguicolorsAndClearsAttrs() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let vimColors = tmpDir.appendingPathComponent("colors").path
    let vimrc = tmpDir.appendingPathComponent(".vimrc").path
    try "\" rc".write(toFile: vimrc, atomically: true, encoding: .utf8)

    let adapter = VimAdapter(colorsDir: vimColors, vimrcPath: vimrc)
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "ink-vermilion")!, configPath: nil)
    let scheme = try String(contentsOfFile: vimColors + "/tintify.vim", encoding: .utf8)

    // 只写 gui 色的主题在终端 vim 里必须开 termguicolors，否则整个主题无效
    #expect(scheme.contains("set termguicolors"))
    // 每条 highlight 都显式清属性：highlight clear 重置到的是 vim 默认组，
    // StatusLine 的 reverse、TabLine 的 underline 不显式覆盖就会残留
    for line in scheme.components(separatedBy: "\n")
    where line.hasPrefix("highlight ") && line != "highlight clear" {
        #expect(line.contains("gui=") && line.contains("cterm="), "缺属性清除: \(line)")
    }
    // Visual 必须显式 guifg=NONE，防默认 LightGrey 压平选区内语法色
    let visual = scheme.components(separatedBy: "\n").first { $0.hasPrefix("highlight Visual ") }
    #expect(visual?.contains("guifg=NONE") == true)
    // 此前漏掉的核心组（默认色透出：vimdiff 深蓝、MatchParen 深青、copy 黄底）
    for group in ["DiffAdd", "DiffChange", "DiffDelete", "DiffText", "MatchParen",
                  "IncSearch", "Folded", "SignColumn", "ColorColumn", "ErrorMsg",
                  "NonText", "Directory", "Title", "WildMenu", "SpellBad"] {
        #expect(scheme.contains("highlight \(group) "), "缺 \(group)")
    }
}

@Test func vimAdapterRestoresDefaultsForFreshVimrc() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let vimrc = tmpDir.appendingPathComponent(".vimrc").path   // 不存在

    let adapter = VimAdapter(colorsDir: tmpDir.appendingPathComponent("colors").path, vimrcPath: vimrc)
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: nil)

    // 新建 vimrc 会让 vim 跳过 defaults.vim（语法高亮等默认全丢），块里要补 source
    let content = try String(contentsOfFile: vimrc, encoding: .utf8)
    #expect(content.contains("source $VIMRUNTIME/defaults.vim"))
    // 再次 apply 不丢失（Tintify 块是 vimrc 唯一内容时仍需 defaults）
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "dracula")!, configPath: nil)
    let second = try String(contentsOfFile: vimrc, encoding: .utf8)
    #expect(second.contains("source $VIMRUNTIME/defaults.vim"))

    // 用户已有实质内容的 vimrc 不加
    let vimrc2 = tmpDir.appendingPathComponent("user.vimrc").path
    try "set number\nsyntax on".write(toFile: vimrc2, atomically: true, encoding: .utf8)
    let adapter2 = VimAdapter(colorsDir: tmpDir.appendingPathComponent("colors").path, vimrcPath: vimrc2)
    try adapter2.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: nil)
    let userContent = try String(contentsOfFile: vimrc2, encoding: .utf8)
    #expect(!userContent.contains("defaults.vim"))
}

@Test func vimAdapterToolName() {
    let adapter = VimAdapter()
    #expect(adapter.toolName == "vim")
}

@Test func vimAdapterWritesVimScriptComments() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let vimrc = tmpDir.appendingPathComponent(".vimrc").path
    // 模拟旧版本写坏的 .vimrc：含 # 标记块
    try "set number\n# === TINTIFY START ===\ncolorscheme tintify\n# === TINTIFY END ===\n"
        .write(toFile: vimrc, atomically: true, encoding: .utf8)

    let adapter = VimAdapter(colorsDir: tmpDir.appendingPathComponent("colors").path, vimrcPath: vimrc)
    try adapter.apply(theme: ThemeRegistry.shared.allThemes[0], configPath: nil)

    let result = try String(contentsOfFile: vimrc, encoding: .utf8)
    #expect(!result.contains("# === TINTIFY"))          // 旧的 # 块已迁移清除
    #expect(result.contains("\" === TINTIFY START ===")) // 新块用 vim 注释
    #expect(result.contains("colorscheme tintify"))
}
