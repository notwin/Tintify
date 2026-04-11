import Testing
import Foundation
@testable import Tintify

@Test func starshipAdapterWritesPaletteSection() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

    let config = tmpDir.appendingPathComponent("starship.toml").path
    try "# my starship config\nformat = \"$all\"".write(toFile: config, atomically: true, encoding: .utf8)

    let adapter = StarshipAdapter()
    let theme = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: theme, configPath: config)

    let content = try String(contentsOfFile: config, encoding: .utf8)
    #expect(content.contains("palette = \"catppuccin_mocha\""))
    #expect(content.contains("[palettes.catppuccin_mocha]"))
    #expect(content.contains("blue = "))
    #expect(content.contains("format = \"$all\""))
}

@Test func starshipAdapterRemovesOldPalettes() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

    let config = tmpDir.appendingPathComponent("starship.toml").path
    try "palette = \"old\"\n\n[palettes.old]\nblue = \"#000\"".write(toFile: config, atomically: true, encoding: .utf8)

    let adapter = StarshipAdapter()
    let theme = ThemeRegistry.shared.theme(id: "nord")!
    try adapter.apply(theme: theme, configPath: config)

    let content = try String(contentsOfFile: config, encoding: .utf8)
    #expect(content.contains("palette = \"nord\""))
    #expect(!content.contains("[palettes.old]"))
    #expect(content.contains("[palettes.nord]"))
}

@Test func starshipAdapterToolName() {
    let adapter = StarshipAdapter()
    #expect(adapter.toolName == "starship")
}
