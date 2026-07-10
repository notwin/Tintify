import Testing
import Foundation
@testable import Tintify

@Test func tmuxAdapterWritesMarkerBlock() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

    let tmuxConf = tmpDir.appendingPathComponent(".tmux.conf").path
    try "# my tmux config\nset -g mouse on".write(toFile: tmuxConf, atomically: true, encoding: .utf8)

    let adapter = TmuxAdapter(reloadEnabled: false)
    let theme = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: theme, configPath: tmuxConf)

    let content = try String(contentsOfFile: tmuxConf, encoding: .utf8)
    #expect(content.contains("# === TINTIFY START ==="))
    #expect(content.contains("# === TINTIFY END ==="))
    #expect(content.contains("status-style"))
    #expect(content.contains("pane-border-style"))
    #expect(content.contains("pane-active-border-style"))
    // copy-mode 不写的话默认是黄底黑字大色块
    #expect(content.contains("mode-style"))
    #expect(content.contains("copy-mode-match-style"))
    #expect(content.contains("copy-mode-current-match-style"))
    #expect(content.contains("set -g mouse on"))
}

@Test func tmuxAdapterToolName() {
    let adapter = TmuxAdapter(reloadEnabled: false)
    #expect(adapter.toolName == "tmux")
}

@Test func tmuxAdapterSkipsReloadWhenDisabled() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let confPath = tmpDir.appendingPathComponent(".tmux.conf").path

    let adapter = TmuxAdapter(reloadEnabled: false)
    let theme = ThemeRegistry.shared.allThemes[0]
    try adapter.apply(theme: theme, configPath: confPath)

    let content = try String(contentsOfFile: confPath, encoding: .utf8)
    #expect(content.contains("TINTIFY START"))
    // 关键验证在于：跑测试时不再刷新本机 tmux（无法直接断言子进程，靠 reloadEnabled 逻辑保证）
}
