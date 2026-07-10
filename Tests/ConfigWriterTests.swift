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

@Test func replaceTopLevelKeyInsertsBeforeFirstSection() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let existing = """
    add_newline = false

    [character]
    success_symbol = "[➜](bold green)"
    """
    try existing.write(to: tmp, atomically: true, encoding: .utf8)

    try ConfigWriter.replaceTopLevelKey(in: tmp.path, key: "palette", line: "palette = \"nord\"")

    let lines = try String(contentsOf: tmp, encoding: .utf8).components(separatedBy: "\n")
    let paletteIdx = lines.firstIndex { $0.hasPrefix("palette = ") }!
    let sectionIdx = lines.firstIndex { $0.hasPrefix("[character]") }!
    #expect(paletteIdx < sectionIdx)  // 必须在第一个 section 之前
}

@Test func replaceTopLevelKeyIgnoresKeyInsideSection() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let existing = """
    [somesection]
    palette = "inner"
    """
    try existing.write(to: tmp, atomically: true, encoding: .utf8)

    try ConfigWriter.replaceTopLevelKey(in: tmp.path, key: "palette", line: "palette = \"nord\"")

    let content = try String(contentsOf: tmp, encoding: .utf8)
    #expect(content.contains("palette = \"inner\""))  // section 内的同名键不动
    let lines = content.components(separatedBy: "\n")
    #expect(lines.firstIndex { $0 == "palette = \"nord\"" }! < lines.firstIndex { $0.hasPrefix("[somesection]") }!)
}

@Test func replaceTopLevelKeySkipsMultilineStrings() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    // format 多行字符串内部有以 [ 开头的行，不能被当成 section 头
    let existing = [
        "format = \"\"\"",
        "[](grad1)\\",
        "$directory\\",
        "\"\"\"",
        "",
        "[username]",
        "show_always = true",
    ].joined(separator: "\n")
    try existing.write(toFile: tmp.path, atomically: true, encoding: .utf8)

    try ConfigWriter.replaceTopLevelKey(in: tmp.path, key: "palette", line: "palette = \"tintify\"")

    let lines = try String(contentsOf: tmp, encoding: .utf8).components(separatedBy: "\n")
    let paletteIdx = lines.firstIndex(of: "palette = \"tintify\"")!
    #expect(paletteIdx > lines.firstIndex(of: "\"\"\"")!)        // 在 format 字符串结束之后
    #expect(paletteIdx < lines.firstIndex(of: "[username]")!)     // 在第一个真 section 之前
    #expect(lines[1] == "[](grad1)\\")                            // format 内容未被改动
}

@Test func replaceTopLevelKeyReplacesExistingKeyAfterMultilineString() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let existing = [
        "format = \"\"\"",
        "[](grad1)\\",
        "\"\"\"",
        "",
        "palette = \"old\"",
        "",
        "[username]",
    ].joined(separator: "\n")
    try existing.write(toFile: tmp.path, atomically: true, encoding: .utf8)

    try ConfigWriter.replaceTopLevelKey(in: tmp.path, key: "palette", line: "palette = \"tintify\"")

    let lines = try String(contentsOf: tmp, encoding: .utf8).components(separatedBy: "\n")
    #expect(lines.filter { $0.hasPrefix("palette") }.count == 1)  // 原位替换，不重复插入
    #expect(lines.contains("palette = \"tintify\""))
    #expect(!lines.contains("palette = \"old\""))
}

@Test func replaceTopLevelKeyHealsLineInsertedInsideMultilineString() throws {
    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    // 旧版本 bug 会把键行连同一个空行插进 format 字符串内部，重新 apply 时要清掉
    let existing = [
        "format = \"\"\"",
        "palette = \"tintify\"",
        "",
        "[](grad1)\\",
        "$directory\\",
        "\"\"\"",
        "",
        "[username]",
        "show_always = true",
    ].joined(separator: "\n")
    try existing.write(toFile: tmp.path, atomically: true, encoding: .utf8)

    try ConfigWriter.replaceTopLevelKey(in: tmp.path, key: "palette", line: "palette = \"tintify\"")

    let lines = try String(contentsOf: tmp, encoding: .utf8).components(separatedBy: "\n")
    #expect(lines[1] == "[](grad1)\\")                            // 残留行和空行都被移除
    #expect(lines.filter { $0 == "palette = \"tintify\"" }.count == 1)
    let paletteIdx = lines.firstIndex(of: "palette = \"tintify\"")!
    #expect(paletteIdx > lines.firstIndex(of: "\"\"\"")!)
    #expect(paletteIdx < lines.firstIndex(of: "[username]")!)
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
