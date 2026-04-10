import Testing
import Foundation
@testable import Tintify

@Test func ghosttyAdapterAppliesTheme() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try "font-size = 14\ntheme = old-theme\nwindow-padding-x = 4\n"
        .write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = GhosttyAdapter()
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: tmp.path)

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(result.contains("Catppuccin Mocha"))
    #expect(!result.contains("theme = old-theme"))
    #expect(result.contains("font-size = 14"))
}

@Test func ghosttyAdapterInsertsWhenMissing() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try "font-size = 14\n".write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = GhosttyAdapter()
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: tmp.path)

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(result.contains("Catppuccin Mocha"))
}

@Test func ghosttyAdapterToolName() {
    let adapter = GhosttyAdapter()
    #expect(adapter.toolName == "ghostty")
}
