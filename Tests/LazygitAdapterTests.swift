import Testing
import Foundation
@testable import Tintify

@Test func lazygitAdapterWritesConfig() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let tmpPath = tmpDir.appendingPathComponent("config.yml").path

    let adapter = LazygitAdapter()
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: tmpPath)

    let result = try String(contentsOfFile: tmpPath, encoding: .utf8)
    #expect(result.contains("gui:"))
    #expect(result.contains("activeBorderColor:"))
    #expect(result.contains("#89b4fa"))   // blue
    #expect(result.contains("#a6adc8"))   // subtext0
    #expect(result.contains("#313244"))   // surface0
    #expect(result.contains("unstagedChangesColor:"))
    #expect(result.contains("#f38ba8"))   // red
}

@Test func lazygitAdapterReplacesExistingGuiSection() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let tmpPath = tmpDir.appendingPathComponent("config.yml").path
    try FileManager.default.createDirectory(
        atPath: tmpDir.path, withIntermediateDirectories: true
    )
    try """
        gui:
          theme:
            activeBorderColor:
              - "#old"
        other_key: value
        """.write(toFile: tmpPath, atomically: true, encoding: .utf8)

    let adapter = LazygitAdapter()
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: tmpPath)

    let result = try String(contentsOfFile: tmpPath, encoding: .utf8)
    #expect(result.contains("#89b4fa"))
    #expect(!result.contains("#old"))
    #expect(result.contains("other_key: value"))
}

@Test func lazygitAdapterToolName() {
    let adapter = LazygitAdapter()
    #expect(adapter.toolName == "lazygit")
}

@Test func lazygitPreservesUserGuiSettings() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".yml")
    let existing = """
    gui:
      nerdFontsVersion: "3"
      mouseEvents: false
      theme:
        activeBorderColor:
          - "#old"
          - bold
      showFileTree: true
    git:
      paging:
        colorArg: always
    """
    try existing.write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = LazygitAdapter()
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: tmp.path)

    let content = try String(contentsOf: tmp, encoding: .utf8)
    #expect(content.contains("nerdFontsVersion: \"3\""))   // 用户 gui 子键保留
    #expect(content.contains("mouseEvents: false"))
    #expect(content.contains("showFileTree: true"))
    #expect(content.contains("git:"))                       // 其他顶层段保留
    #expect(!content.contains("#old"))                      // 旧 theme 子块被替换
    #expect(content.contains("activeBorderColor:"))
}

@Test func lazygitInsertsThemeWhenGuiHasNoTheme() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".yml")
    try "gui:\n  mouseEvents: false\n".write(toFile: tmp.path, atomically: true, encoding: .utf8)

    let adapter = LazygitAdapter()
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: tmp.path)

    let content = try String(contentsOfFile: tmp.path, encoding: .utf8)
    #expect(content.contains("mouseEvents: false"))
    #expect(content.contains("theme:"))
    #expect(content.contains("activeBorderColor:"))
}
