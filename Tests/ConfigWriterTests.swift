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

@Test func orphanStartMarkerThrowsInsteadOfEatingUserContent() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let existing = """
    # my config
    # === TINTIFY START ===
    export BAT_THEME="Old"
    alias important='do-not-delete-me'
    """
    try existing.write(to: tmp, atomically: true, encoding: .utf8)

    #expect(throws: ConfigWriterError.self) {
        try ConfigWriter.writeMarkerBlock(to: tmp.path, content: "new content")
    }
    // 文件必须原封不动
    let after = try String(contentsOf: tmp, encoding: .utf8)
    #expect(after == existing)
}

@Test func orphanEndMarkerThrows() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try "line1\n# === TINTIFY END ===\nline2".write(to: tmp, atomically: true, encoding: .utf8)
    #expect(throws: ConfigWriterError.self) {
        try ConfigWriter.writeMarkerBlock(to: tmp.path, content: "x")
    }
}

@Test func markerBlockWithVimCommentPrefix() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try "set number\n".write(to: tmp, atomically: true, encoding: .utf8)

    try ConfigWriter.writeMarkerBlock(to: tmp.path, content: "colorscheme tintify", commentPrefix: "\"")

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(result.contains("\" === TINTIFY START ==="))
    #expect(result.contains("\" === TINTIFY END ==="))
    #expect(!result.contains("# === TINTIFY"))
}

@Test func removeMarkerBlocksCleansOldStyleMarkers() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let existing = """
    set number
    # === TINTIFY START ===
    colorscheme tintify
    # === TINTIFY END ===
    set ruler
    """
    try existing.write(to: tmp, atomically: true, encoding: .utf8)

    try ConfigWriter.removeMarkerBlocks(from: tmp.path, commentPrefix: "#")

    let result = try String(contentsOf: tmp, encoding: .utf8)
    #expect(!result.contains("TINTIFY"))
    #expect(result.contains("set number") && result.contains("set ruler"))
}

@Test func duplicateBlocksAreMergedIntoFirst() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let existing = """
    # top
    # === TINTIFY START ===
    old-a
    # === TINTIFY END ===
    # user line between blocks
    # === TINTIFY START ===
    old-b
    # === TINTIFY END ===
    # bottom
    """
    try existing.write(to: tmp, atomically: true, encoding: .utf8)

    try ConfigWriter.writeMarkerBlock(to: tmp.path, content: "new")

    let after = try String(contentsOf: tmp, encoding: .utf8)
    #expect(after.components(separatedBy: "TINTIFY START").count == 2)  // 只剩一个块
    #expect(after.contains("new"))
    #expect(!after.contains("old-a") && !after.contains("old-b"))
    #expect(after.contains("# user line between blocks"))               // 块间用户行保留
    #expect(after.contains("# top") && after.contains("# bottom"))
}

@Test func atomicWritePreservesSymlink() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let real = tmpDir.appendingPathComponent("real.conf").path
    let link = tmpDir.appendingPathComponent("link.conf").path
    try "original".write(toFile: real, atomically: true, encoding: .utf8)
    try FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: real)

    try ConfigWriter.atomicWrite("updated", to: link)

    // 链接仍是链接
    let attrs = try FileManager.default.attributesOfItem(atPath: link)
    #expect(attrs[.type] as? FileAttributeType == .typeSymbolicLink)
    // 真实文件被更新
    #expect(try String(contentsOfFile: real, encoding: .utf8) == "updated")
}

@Test func markerBlockWriteThroughSymlink() throws {
    let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    let real = tmpDir.appendingPathComponent("zshrc").path
    let link = tmpDir.appendingPathComponent(".zshrc").path
    try "# user config".write(toFile: real, atomically: true, encoding: .utf8)
    try FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: real)

    try ConfigWriter.writeMarkerBlock(to: link, content: "export X=1")

    let attrs = try FileManager.default.attributesOfItem(atPath: link)
    #expect(attrs[.type] as? FileAttributeType == .typeSymbolicLink)
    #expect(try String(contentsOfFile: real, encoding: .utf8).contains("export X=1"))
}
