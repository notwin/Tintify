import Testing
import Foundation
@testable import Tintify

@Test func ezaAdapterWritesYAML() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let tmpPath = tmpDir.appendingPathComponent("theme.yml").path

    let adapter = EzaAdapter()
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: tmpPath)

    let result = try String(contentsOfFile: tmpPath, encoding: .utf8)
    #expect(result.contains("#89b4fa"))   // blue (directory color)
    #expect(result.contains("#cdd6f4"))   // text
    #expect(result.contains("#a6e3a1"))   // green
    #expect(result.contains("filekinds:"))
    #expect(result.contains("directory:"))
    #expect(result.contains("git:"))
}

@Test func ezaAdapterToolName() {
    let adapter = EzaAdapter()
    #expect(adapter.toolName == "eza")
}
