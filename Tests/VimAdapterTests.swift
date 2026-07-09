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
