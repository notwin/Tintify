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
    #expect(content.contains("palette = \"tintify\""))
    #expect(content.contains("[palettes.tintify]"))
    #expect(content.contains("blue = "))
    #expect(content.contains("format = \"$all\""))
}

@Test func starshipAdapterRemovesKnownOldPalette() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

    let config = tmpDir.appendingPathComponent("starship.toml").path
    try "palette = \"old\"\n\n[palettes.old]\nblue = \"#000\"".write(toFile: config, atomically: true, encoding: .utf8)

    // "old" 是 Tintify 已知主题名之一（模拟上次应用留下的段），应被清除；固定段名为 tintify。
    let adapter = StarshipAdapter(knownPaletteNames: ["old", "nord"])
    let theme = ThemeRegistry.shared.theme(id: "nord")!
    try adapter.apply(theme: theme, configPath: config)

    let content = try String(contentsOfFile: config, encoding: .utf8)
    #expect(content.contains("palette = \"tintify\""))
    #expect(!content.contains("[palettes.old]"))
    #expect(content.contains("[palettes.tintify]"))
}

@Test func starshipPreservesUserPalettes() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let existing = """
    [palettes.my_custom]
    red = "#ff0000"

    [palettes.nord]
    red = "#old"
    """
    try existing.write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = StarshipAdapter(knownPaletteNames: ["nord", "catppuccin_mocha"])
    let nord = ThemeRegistry.shared.theme(id: "nord")!
    try adapter.apply(theme: nord, configPath: tmp.path)

    let content = try String(contentsOf: tmp, encoding: .utf8)
    #expect(content.contains("[palettes.my_custom]"))       // 用户自建 palette 保留
    #expect(!content.contains("[palettes.nord]"))           // 历史遗留段被清
    #expect(content.contains("[palettes.tintify]"))         // 固定段名重新生成
    #expect(!content.contains("#old"))
    let lines = content.components(separatedBy: "\n")
    let paletteLine = lines.firstIndex { $0.hasPrefix("palette = ") }!
    let firstSection = lines.firstIndex { $0.hasPrefix("[") }!
    #expect(paletteLine < firstSection)                      // 顶层引用在所有 section 之前
}

@Test func starshipAdapterToolName() {
    let adapter = StarshipAdapter()
    #expect(adapter.toolName == "starship")
}

@Test func starshipWritesFixedTintifyPalette() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try "add_newline = false\n".write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = StarshipAdapter(knownPaletteNames: ["nord"])
    let nord = ThemeRegistry.shared.theme(id: "nord")!
    try adapter.apply(theme: nord, configPath: tmp.path)

    let content = try String(contentsOf: tmp, encoding: .utf8)
    #expect(content.contains("palette = \"tintify\""))
    #expect(content.contains("[palettes.tintify]"))
    #expect(content.contains("grad1 = \"\(nord.promptSegments[0].color)\""))
    #expect(content.contains("grad5 = \"\(nord.promptSegments[4].color)\""))
    #expect(content.contains("ink1 = \"\(nord.promptSegments[0].ink)\""))
    #expect(content.contains("blue = "))                       // 26 色语义名仍在
    #expect(!content.contains("[palettes.nord]"))              // 不再写 per-theme 段
}

@Test func starshipReplacesLegacyPerThemePalette() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try "palette = \"nord\"\n\n[palettes.nord]\nblue = \"#old\"\n".write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = StarshipAdapter(knownPaletteNames: ["nord"])
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: tmp.path)

    let content = try String(contentsOf: tmp, encoding: .utf8)
    #expect(content.contains("palette = \"tintify\""))         // 顶层键更新
    #expect(!content.contains("[palettes.nord]"))              // 历史遗留段被清
    #expect(content.contains("[palettes.tintify]"))
}

@Test func starshipMigratesHardcodedHexToGradSlots() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    // 模拟用户 Pastel Powerline：5 段渐变 + 1 个模块色，箭头引用相邻段色
    let userConfig = """
    format = \"\"\"
    [](#DA627D)\\
    $directory\\
    [](fg:#DA627D bg:#FCA17D)\\
    $git_branch\\
    [](fg:#FCA17D bg:#86BBD8)\\
    $nodejs\\
    [](fg:#86BBD8 bg:#06969A)\\
    $docker_context\\
    [](fg:#06969A bg:#33658A)\\
    $time\\
    [ ](fg:#33658A)\\
    \"\"\"

    [username]
    style_user = "bg:#9A348E"
    """
    try userConfig.write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = StarshipAdapter(knownPaletteNames: [])
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "rose-pine")!, configPath: tmp.path)

    let content = try String(contentsOf: tmp, encoding: .utf8)
    #expect(!content.contains("#DA627D") && !content.contains("#9A348E"))  // 硬编码 hex 全部消失
    #expect(content.contains("[](grad1)"))
    #expect(content.contains("fg:grad1 bg:grad2"))                          // 箭头引用自动正确
    #expect(content.contains("fg:grad4 bg:grad5"))
    #expect(content.contains("bg:grad5"))                                   // 第 6 个 hex clamp 到 grad5
    // 幂等：再 apply 一次不重复迁移、内容稳定
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: tmp.path)
    let second = try String(contentsOf: tmp, encoding: .utf8)
    #expect(second.contains("[](grad1)"))
    #expect(!second.contains("gradgrad"))
}

@Test func starshipAddsInkForegroundToGradStyles() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    // 已迁移过的配置：style 只有 bg:gradN 没有 fg，文字颜色会随终端默认前景漂移。
    // 设计稿里段内文字用配套 ink 色，apply 时应补上 fg:inkN。
    let userConfig = """
    format = \"\"\"
    [](grad1)\\
    $directory\\
    [](fg:grad1 bg:grad2)\\
    $git_branch\\
    [ ](fg:grad5)\\
    \"\"\"

    [username]
    style_user = "bg:grad5"

    [directory]
    style = "bg:grad1"
    format = "[ $path ]($style)"

    [git_branch]
    style = "fg:#cccccc bg:grad2"
    """
    try userConfig.write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = StarshipAdapter(knownPaletteNames: [])
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "soda-pop")!, configPath: tmp.path)

    let content = try String(contentsOf: tmp, encoding: .utf8)
    #expect(content.contains("style = \"fg:ink1 bg:grad1\""))       // 无 fg 的样式补上对应 ink
    #expect(content.contains("style_user = \"fg:ink5 bg:grad5\""))
    #expect(content.contains("style = \"fg:#cccccc bg:grad2\""))    // 已有 fg 的样式尊重用户
    #expect(content.contains("[](fg:grad1 bg:grad2)"))              // format 里的箭头不动

    // 幂等：再 apply 一次不重复叠加
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: tmp.path)
    let second = try String(contentsOf: tmp, encoding: .utf8)
    #expect(second.components(separatedBy: "fg:ink1").count == 2)   // 只出现一次
}

@Test func starshipWrapsSegmentGroupsInConditionalGroups() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    // 固定分隔箭头在段空时会渲染成细条；「箭头+模块」应包进 (...) 条件组，
    // 组内变量全空时整组（含箭头）不渲染。
    // 括号内是 powerline 字形（与真实 preset 一致），不是空括号
    let userConfig = """
    format = \"\"\"
    [](grad1)\\
    $directory\\
    [](fg:grad1 bg:grad2)\\
    $git_branch\\
    $git_status\\
    [](fg:grad2 bg:grad3)\\
    $c\\
    $nodejs\\
    [](fg:grad3 bg:grad4)\\
    $docker_context\\
    [](fg:grad4 bg:grad5)\\
    $time\\
    [ ](fg:grad5)\\
    \"\"\"

    [directory]
    style = "fg:ink1 bg:grad1"
    """
    try userConfig.write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = StarshipAdapter(knownPaletteNames: [])
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "soda-pop")!, configPath: tmp.path)

    let content = try String(contentsOf: tmp, encoding: .utf8)
    #expect(content.contains("([](fg:grad1 bg:grad2)\\"))   // 箭头行加了开组括号
    #expect(content.contains("$git_status)\\"))              // 组在最后一个模块行闭合
    #expect(content.contains("([](fg:grad2 bg:grad3)\\"))
    #expect(content.contains("$nodejs)\\"))
    #expect(content.contains("([](fg:grad3 bg:grad4)\\"))
    #expect(content.contains("$docker_context)\\"))
    #expect(content.contains("$time)\\"))
    #expect(content.contains("[](grad1)\\\n$directory\\"))   // 开头圆帽+目录不包（目录恒显）
    #expect(content.contains("[ ](fg:grad5)\\"))             // 结尾圆帽不动

    // 幂等：再 apply 不重复包组
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: tmp.path)
    let second = try String(contentsOf: tmp, encoding: .utf8)
    #expect(!second.contains("(("))
    #expect(second.components(separatedBy: "([](fg:grad1 bg:grad2)").count == 2)
}

@Test func starshipWrapSkipsUnrecognizedFormats() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    // 单行 format、箭头与模块同行等不认识的结构不动
    let userConfig = """
    format = "$all"

    [directory]
    style = "fg:ink1 bg:grad1"
    """
    try userConfig.write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = StarshipAdapter(knownPaletteNames: [])
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: tmp.path)

    let content = try String(contentsOf: tmp, encoding: .utf8)
    #expect(content.contains("format = \"$all\""))
    #expect(!content.contains("(["))
}

@Test func starshipSkipsMigrationWhenTooManyHexes() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let hexes = (0..<12).map { String(format: "[](#%06x)", $0 * 111111 + 0x100000) }.joined(separator: "\n")
    try "format = \"\"\"\n\(hexes)\n\"\"\"".write(to: tmp, atomically: true, encoding: .utf8)

    let adapter = StarshipAdapter(knownPaletteNames: [])
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: tmp.path)

    let content = try String(contentsOf: tmp, encoding: .utf8)
    #expect(content.contains("grad1 = "))             // palette 块照写
    #expect(content.contains("#100000"))              // format 未被迁移
}
