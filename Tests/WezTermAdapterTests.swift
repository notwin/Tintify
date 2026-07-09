import Testing
import Foundation
@testable import Tintify

private func tmpLua(_ content: String) throws -> String {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".lua")
    try content.write(to: tmp, atomically: true, encoding: .utf8)
    return tmp.path
}

@Test func weztermUsesDetectedVariableName() throws {
    let path = try tmpLua("""
    local wezterm = require 'wezterm'
    local c = wezterm.config_builder()
    c.font_size = 14
    return c
    """)
    let adapter = WezTermAdapter()
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: path)

    let content = try String(contentsOfFile: path, encoding: .utf8)
    #expect(content.contains("c.color_scheme"))          // 用检测到的变量名
    #expect(!content.contains("config.color_scheme"))    // 不注入未定义的 config
    let lines = content.components(separatedBy: "\n")
    let blockIdx = lines.firstIndex { $0.contains("TINTIFY START") }!
    let returnIdx = lines.lastIndex { $0.trimmingCharacters(in: .whitespaces) == "return c" }!
    #expect(blockIdx < returnIdx)                        // 块在 return 之前
}

@Test func weztermThrowsOnUnrecognizedStructure() throws {
    let path = try tmpLua("""
    local wezterm = require 'wezterm'
    return { font_size = 14 }
    """)
    let adapter = WezTermAdapter()
    #expect(throws: (any Error).self) {
        try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: path)
    }
    // 文件未被修改
    let content = try String(contentsOfFile: path, encoding: .utf8)
    #expect(!content.contains("TINTIFY"))
}

@Test func weztermCreatesTemplateWhenFileMissing() throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let path = dir.appendingPathComponent(".wezterm.lua").path

    let adapter = WezTermAdapter()
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "nord")!, configPath: path)

    let content = try String(contentsOfFile: path, encoding: .utf8)
    #expect(content.contains("local config"))
    #expect(content.contains("-- === TINTIFY START ==="))
    #expect(content.contains("return config"))
}

@Test func weztermReplacesExistingBlock() throws {
    let path = try tmpLua("""
    local wezterm = require 'wezterm'
    local config = {}
    -- === TINTIFY START ===
    config.color_scheme = "Old"
    -- === TINTIFY END ===
    return config
    """)
    let adapter = WezTermAdapter()
    try adapter.apply(theme: ThemeRegistry.shared.theme(id: "dracula")!, configPath: path)

    let content = try String(contentsOfFile: path, encoding: .utf8)
    #expect(!content.contains("\"Old\""))
    #expect(content.components(separatedBy: "TINTIFY START").count == 2)
}
