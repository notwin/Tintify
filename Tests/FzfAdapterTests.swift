import Testing
import Foundation
@testable import Tintify

@Test func fzfAdapterWritesColorScheme() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try "# my zshrc\n".write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = FzfAdapter()
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: tmp.path)

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(result.contains("FZF_DEFAULT_OPTS"))
    #expect(result.contains("#313244"))  // surface0
    #expect(result.contains("#1e1e2e"))  // base
    #expect(result.contains("#f5e0dc"))  // rosewater
    #expect(result.contains("selected-bg:#45475a"))  // 多选已选行底色 = surface1
    #expect(result.contains("label:#cdd6f4"))        // 边框标签 = text
    #expect(result.contains("# === TINTIFY START ==="))
}

@Test func fzfAdapterPreservesBatLines() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let existing = """
        # my zshrc
        # === TINTIFY START ===
        export BAT_THEME="Catppuccin Mocha"
        # === TINTIFY END ===
        """
    try existing.write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = FzfAdapter()
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: tmp.path)

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(result.contains("FZF_DEFAULT_OPTS"))
    #expect(result.contains("BAT_THEME"))
}

@Test func fzfAdapterToolName() {
    let adapter = FzfAdapter()
    #expect(adapter.toolName == "fzf")
}
