import Testing
import Foundation
@testable import Tintify

@Test func tmuxAdapterWritesMarkerBlock() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

    let tmuxConf = tmpDir.appendingPathComponent(".tmux.conf").path
    try "# my tmux config\nset -g mouse on".write(toFile: tmuxConf, atomically: true, encoding: .utf8)

    let adapter = TmuxAdapter()
    let theme = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: theme, configPath: tmuxConf)

    let content = try String(contentsOfFile: tmuxConf, encoding: .utf8)
    #expect(content.contains("# === TINTIFY START ==="))
    #expect(content.contains("# === TINTIFY END ==="))
    #expect(content.contains("status-style"))
    #expect(content.contains("pane-border-style"))
    #expect(content.contains("pane-active-border-style"))
    #expect(content.contains("set -g mouse on"))
}

@Test func tmuxAdapterToolName() {
    let adapter = TmuxAdapter()
    #expect(adapter.toolName == "tmux")
}
