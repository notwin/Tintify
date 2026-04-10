import Testing
import Foundation
@testable import Tintify

@Test func insertMarkerBlockIntoEmptyFile() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try "# my config\nalias ls='eza'\n".write(to: tmp, atomically: true, encoding: .utf8)

    try ConfigWriter.writeMarkerBlock(to: tmp.path, content: "export BAT_THEME=\"Mocha\"")

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(result.contains("# my config"))
    #expect(result.contains("alias ls='eza'"))
    #expect(result.contains("# === TINTIFY START ==="))
    #expect(result.contains("export BAT_THEME=\"Mocha\""))
    #expect(result.contains("# === TINTIFY END ==="))
}

@Test func replaceExistingMarkerBlock() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let existing = """
    # my config
    # === TINTIFY START ===
    export BAT_THEME="Old"
    # === TINTIFY END ===
    alias ls='eza'
    """
    try existing.write(to: tmp, atomically: true, encoding: .utf8)

    try ConfigWriter.writeMarkerBlock(to: tmp.path, content: "export BAT_THEME=\"New\"")

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(result.contains("export BAT_THEME=\"New\""))
    #expect(!result.contains("export BAT_THEME=\"Old\""))
    #expect(result.contains("alias ls='eza'"))
    #expect(result.components(separatedBy: "TINTIFY START").count == 2)
}

@Test func replaceLineInFile() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try "line1\ntheme = old\nline3\n".write(to: tmp, atomically: true, encoding: .utf8)

    try ConfigWriter.replaceLine(in: tmp.path, prefix: "theme = ", newLine: "theme = new")

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(result.contains("theme = new"))
    #expect(!result.contains("theme = old"))
    #expect(result.contains("line1"))
    #expect(result.contains("line3"))
}

@Test func replaceLineInsertsIfMissing() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try "line1\nline2\n".write(to: tmp, atomically: true, encoding: .utf8)

    try ConfigWriter.replaceLine(in: tmp.path, prefix: "theme = ", newLine: "theme = new")

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(result.contains("theme = new"))
}

@Test func replaceTOMLSectionCreatesFileIfMissing() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

    let path = tmpDir.appendingPathComponent("new.toml").path
    // 文件不存在时应创建并写入内容
    try ConfigWriter.replaceTOMLSection(
        in: path,
        sectionPrefix: "[theme]",
        newContent: "[theme]\nname = \"test\""
    )

    let content = try String(contentsOfFile: path, encoding: .utf8)
    #expect(content.contains("[theme]"))
    #expect(content.contains("name = \"test\""))
}
