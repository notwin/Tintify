// Sources/Engine/TmThemeGenerator.swift
import Foundation

/// 从 26 色色板生成 bat/delta 共用的 .tmTheme 语法主题。
/// scope 映射蓝本 = catppuccin 官方 bat 主题的核心规则子集
/// （通用语法 + diff + markdown + 数据格式键名）。
enum TmThemeGenerator {
    /// 生成 plist XML。fontStyle 三态：nil = 不写该键；
    /// "" = 显式空（切断父 scope 的 italic/bold 继承，蓝本的 ∅ 语义）。
    static func generate(palette p: Palette) -> String {
        let rules: [(scope: String, color: String, fontStyle: String?)] = [
            ("text, source, variable.other.readwrite, punctuation.definition.variable", p.text, nil),
            ("punctuation", p.overlay2, ""),
            ("comment, punctuation.definition.comment", p.overlay2, "italic"),
            ("string, punctuation.definition.string", p.green, nil),
            ("constant.character.escape", p.pink, nil),
            ("constant.numeric, variable.other.constant, entity.name.constant, "
             + "constant.language.boolean, constant.language.false, constant.language.true, "
             + "keyword.other.unit.user-defined, keyword.other.unit.suffix.floating-point", p.peach, nil),
            ("keyword, keyword.operator.word, keyword.operator.new, variable.language.super, "
             + "support.type.primitive, storage.type, storage.modifier, punctuation.definition.keyword", p.mauve, ""),
            ("keyword.operator, punctuation.accessor, punctuation.definition.generic, "
             + "punctuation.definition.tag, punctuation.separator.key-value", p.teal, nil),
            ("entity.name.function, meta.function-call.method, support.function, variable.function", p.blue, "italic"),
            ("entity.name.class, entity.other.inherited-class, support.class, "
             + "entity.name.struct, entity.name.enum, meta.function-call.constructor", p.yellow, "italic"),
            ("meta.type, meta.type-alias, support.type, entity.name.type", p.yellow, "italic"),
            ("variable.parameter, meta.function.parameters", p.maroon, "italic"),
            ("constant.language, support.function.builtin", p.red, nil),
            ("variable.language.this", p.red, nil),
            ("entity.name.namespace", p.yellow, nil),
            ("keyword.control.directive, punctuation.definition.directive", p.yellow, nil),
            ("entity.name.tag", p.blue, ""),
            ("entity.other.attribute-name", p.yellow, nil),
            ("support.type.property-name, entity.name.tag.yaml, keyword.other.definition.ini", p.blue, ""),
            // diff——delta 的代码 token 高亮靠这组；带 .diff 完整后缀更精准
            ("markup.inserted.diff", p.green, nil),
            ("markup.deleted.diff", p.red, nil),
            ("markup.changed.diff", p.peach, nil),
            ("meta.diff.header.from-file, meta.diff.header.to-file, "
             + "punctuation.definition.from-file.diff, punctuation.definition.to-file.diff", p.blue, nil),
            // markdown
            ("heading.1.markdown, markup.heading.1.markdown", p.red, nil),
            ("heading.2.markdown, markup.heading.2.markdown", p.peach, nil),
            ("markup.heading", p.yellow, nil),
            ("markup.bold", p.red, "bold"),
            ("markup.italic", p.red, "italic"),
            ("markup.underline.link, punctuation.definition.link", p.blue, nil),
            ("string.other.link.title", p.lavender, nil),
            ("markup.inline.raw, markup.raw.block", p.green, nil),
            ("markup.quote, punctuation.definition.quote.begin", p.pink, nil),
            ("markup.list.bullet, punctuation.definition.list.begin", p.teal, nil),
        ]

        var dicts: [String] = ["""
                <dict>
                  <key>settings</key>
                  <dict>
                    <key>background</key><string>\(p.base)</string>
                    <key>foreground</key><string>\(p.text)</string>
                    <key>caret</key><string>\(p.rosewater)</string>
                    <key>lineHighlight</key><string>\(p.surface0)</string>
                    <key>selection</key><string>\(p.overlay2)40</string>
                    <key>gutterForeground</key><string>\(p.overlay1)</string>
                    <key>accent</key><string>\(p.mauve)</string>
                    <key>misspelling</key><string>\(p.red)</string>
                  </dict>
                </dict>
            """]

        for rule in rules {
            let fontStyle = rule.fontStyle.map { "\n        <key>fontStyle</key><string>\($0)</string>" } ?? ""
            dicts.append("""
                <dict>
                  <key>scope</key><string>\(rule.scope)</string>
                  <key>settings</key>
                  <dict>
                    <key>foreground</key><string>\(rule.color)</string>\(fontStyle)
                  </dict>
                </dict>
            """)
        }

        return """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
              <key>name</key><string>\(TmThemeInstaller.themeName)</string>
              <key>settings</key>
              <array>
            \(dicts.joined(separator: "\n"))
              </array>
              <key>uuid</key><string>b5a6f2c1-58f0-4a41-9c1e-0d5f6a7b8c9d</string>
            </dict>
            </plist>
            """
    }
}

/// 安装共享的 tintify.tmTheme（bat 与 delta 都按名字 "tintify" 引用；
/// syntect 取「文件名去扩展名」作主题名，plist 里的 name 键会被忽略）。
/// delta 只读默认 ~/.cache/bat 编译缓存（不认 BAT_CACHE_PATH），
/// 所以 rebuild 必须让 bat 把产物写到默认缓存目录。
struct TmThemeInstaller {
    static let themeName = "tintify"

    let themesDir: String
    let rebuildCache: () throws -> Void

    init(
        themesDir: String = NSHomeDirectory() + "/.config/bat/themes",
        rebuildCache: @escaping () throws -> Void = TmThemeInstaller.runBatCacheBuild
    ) {
        self.themesDir = themesDir
        self.rebuildCache = rebuildCache
    }

    /// 写入主题文件；内容变化才重建缓存（bat cache --build 约数百毫秒）。
    func install(theme: Theme) throws {
        let content = TmThemeGenerator.generate(palette: theme.palette)
        let path = themesDir + "/\(Self.themeName).tmTheme"
        if (try? String(contentsOfFile: path, encoding: .utf8)) == content { return }
        try FileManager.default.createDirectory(atPath: themesDir, withIntermediateDirectories: true)
        try ConfigWriter.atomicWrite(content, to: path)
        try rebuildCache()
    }

    static func runBatCacheBuild() throws {
        guard let bat = ToolDetection.executablePath("bat") else {
            throw AdapterError.commandFailed(tool: "bat", status: 127)
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: bat)
        process.arguments = ["cache", "--build"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw AdapterError.commandFailed(tool: "bat", status: process.terminationStatus)
        }
    }
}
