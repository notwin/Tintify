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

@Test func ezaWritesValidKeysAndCoversForeignDefaults() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let tmpPath = tmpDir.appendingPathComponent("theme.yml").path

    let adapter = EzaAdapter(legacyConfigPath: tmpDir.appendingPathComponent("legacy").path)
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "catppuccin-mocha")!, configPath: tmpPath)

    let result = try String(contentsOfFile: tmpPath, encoding: .utf8)
    // eza 的合法键名带下划线，旧写法被静默忽略
    #expect(result.contains("block_device:") && result.contains("char_device:"))
    #expect(!result.contains("blockdevice:") && !result.contains("chardevice:"))
    // date 是扁平字段；hour_old/day_old 是 lsd 的格式，eza 不认
    #expect(result.contains("date:\n  foreground:"))
    #expect(!result.contains("hour_old"))
    // file_type 段必须写，否则 eza 默认 ANSI 色（黄下划线 build、紫 image…）透出
    #expect(result.contains("file_type:"))
    #expect(result.contains("build:"))
    #expect(result.contains("source:"))
    // build/mount_point/user_execute_file 的默认样式带下划线，必须显式关掉
    #expect(result.components(separatedBy: "is_underline: false").count >= 4)
}

@Test func ezaAppliesThemeAccentToExecutable() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let tmpPath = tmpDir.appendingPathComponent("theme.yml").path
    let adapter = EzaAdapter(legacyConfigPath: tmpDir.appendingPathComponent("legacy").path)

    // 标志色住在非映射槽的原创主题定义了 accent（各自的设计意图）
    let ink = ThemeRegistry.shared.theme(id: "ink-vermilion")!
    #expect(ink.accent == "#e34234")                                             // 朱印
    #expect(ThemeRegistry.shared.theme(id: "neon-city")!.accent == "#ff2daf")     // 霓虹粉
    #expect(ThemeRegistry.shared.theme(id: "synthwave-sunset")!.accent == "#ff7edb")  // 热粉
    // rose-pine 家族对齐官方 eza 主题：executable = iris
    #expect(ThemeRegistry.shared.theme(id: "rose-pine")!.accent == "#c4a7e7")
    #expect(ThemeRegistry.shared.theme(id: "rose-pine-moon")!.accent == "#c4a7e7")
    #expect(ThemeRegistry.shared.theme(id: "rose-pine-dawn")!.accent == "#907aa9")
    // 单色/多宝石主题刻意不设 accent；经典主题维持官方绿色惯例
    #expect(ThemeRegistry.shared.theme(id: "phosphor-green")!.accent == nil)
    #expect(ThemeRegistry.shared.theme(id: "jewel-tones")!.accent == nil)
    #expect(ThemeRegistry.shared.theme(id: "dracula")!.accent == nil)

    try adapter.apply(theme: ink, configPath: tmpPath)
    let result = try String(contentsOfFile: tmpPath, encoding: .utf8)
    #expect(result.contains("  executable:\n    foreground: \"#e34234\""))

    // 没定义 accent 的主题维持 green 惯例
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: tmpPath)
    let mochaResult = try String(contentsOfFile: tmpPath, encoding: .utf8)
    #expect(mochaResult.contains("  executable:\n    foreground: \"\(mocha.palette.green)\""))
}

@Test func ezaRaisesDimSlotsAboveInvisible() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let tmpPath = tmpDir.appendingPathComponent("theme.yml").path
    let adapter = EzaAdapter(legacyConfigPath: tmpDir.appendingPathComponent("legacy").path)
    let mocha = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: mocha, configPath: tmpPath)

    let result = try String(contentsOfFile: tmpPath, encoding: .utf8)
    // git.ignored 用 overlay0 在 28 个主题上对比度 <3，提到 overlay1
    #expect(result.contains("  ignored:\n    foreground: \"\(mocha.palette.overlay1)\""))
    // perms.attribute 同理提到 overlay2
    #expect(result.contains("  attribute:\n    foreground: \"\(mocha.palette.overlay2)\""))
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
