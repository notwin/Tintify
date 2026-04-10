import Testing
import Foundation
@testable import Tintify

@Test func batAdapterWritesMarkerBlock() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try "# my zshrc\nalias ls='eza'\n".write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = BatAdapter()
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: tmp.path)

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(result.contains("# === TINTIFY START ==="))
    #expect(result.contains("export BAT_THEME=\"Catppuccin Mocha\""))
    #expect(result.contains("# === TINTIFY END ==="))
    #expect(result.contains("alias ls='eza'"))
}

@Test func batAdapterPreservesFzfLines() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let existing = """
        # my zshrc
        # === TINTIFY START ===
        export FZF_DEFAULT_OPTS="--color=bg:#1e1e2e"
        export BAT_THEME="Old"
        # === TINTIFY END ===
        """
    try existing.write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = BatAdapter()
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: tmp.path)

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(result.contains("export BAT_THEME=\"Catppuccin Mocha\""))
    #expect(!result.contains("BAT_THEME=\"Old\""))
    #expect(result.contains("FZF_DEFAULT_OPTS"))
}

@Test func batAdapterToolName() {
    let adapter = BatAdapter()
    #expect(adapter.toolName == "bat")
}
