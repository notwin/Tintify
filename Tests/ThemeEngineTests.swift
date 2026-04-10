// Tests/ThemeEngineTests.swift

import Testing
import Foundation
@testable import Tintify

@Test func engineAppliesThemeToAllAdapters() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

    let ghosttyConfig = tmpDir.appendingPathComponent("ghostty-config").path
    let zshrc = tmpDir.appendingPathComponent(".zshrc").path
    try "theme = old".write(toFile: ghosttyConfig, atomically: true, encoding: .utf8)
    try "# my zshrc".write(toFile: zshrc, atomically: true, encoding: .utf8)

    let theme = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!

    let engine = ThemeEngine(
        adapters: [GhosttyAdapter(), BatAdapter()],
        backupManager: BackupManager(backupRoot: tmpDir.appendingPathComponent("backups").path),
        pathOverrides: ["ghostty": ghosttyConfig, "bat": zshrc]
    )

    try engine.apply(theme: theme)

    let ghosttyResult = try String(contentsOfFile: ghosttyConfig, encoding: .utf8)
    #expect(ghosttyResult.contains("theme = catppuccin-mocha"))

    let zshrcResult = try String(contentsOfFile: zshrc, encoding: .utf8)
    #expect(zshrcResult.contains("BAT_THEME"))
}
