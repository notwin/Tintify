import Testing
import Foundation
@testable import Tintify

@Test func ezaAdapterWritesYAML() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let tmpPath = tmpDir.appendingPathComponent("theme.yml").path
    let legacyPath = tmpDir.appendingPathComponent("legacy-theme.yml").path

    let adapter = EzaAdapter(legacyConfigPath: legacyPath)
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

@Test func ezaRemovesTintifyManagedLegacyFile() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let legacy = tmpDir.appendingPathComponent("legacy-theme.yml").path
    let active = tmpDir.appendingPathComponent("theme.yml").path
    try "# Tintify-managed eza theme\nfilekinds:\n".write(toFile: legacy, atomically: true, encoding: .utf8)

    let adapter = EzaAdapter(legacyConfigPath: legacy)
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: active)

    #expect(!FileManager.default.fileExists(atPath: legacy))   // Tintify 自己的残留被清
    #expect(FileManager.default.fileExists(atPath: active))
}

@Test func ezaKeepsUserAuthoredLegacyFile() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let legacy = tmpDir.appendingPathComponent("legacy-theme.yml").path
    try "# my custom eza theme\nfilekinds:\n".write(toFile: legacy, atomically: true, encoding: .utf8)

    let adapter = EzaAdapter(legacyConfigPath: legacy)
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!,
                      configPath: tmpDir.appendingPathComponent("theme.yml").path)

    #expect(FileManager.default.fileExists(atPath: legacy))    // 用户自己的文件不动
}
