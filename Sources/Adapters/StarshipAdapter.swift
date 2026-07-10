// Sources/Adapters/StarshipAdapter.swift
import Foundation

/// Adapter for the Starship prompt.
struct StarshipAdapter: ToolAdapter {
    let id: ToolID = .starship

    /// Palette names Tintify itself generates (built-in theme ids). Only
    /// `[palettes.*]` sections whose name is in this set — or matches the
    /// palette being applied — are removed; anything else is user-authored
    /// and must be preserved.
    let knownPaletteNames: Set<String>

    init(knownPaletteNames: Set<String> = []) {
        self.knownPaletteNames = knownPaletteNames
    }

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.config/starship.toml"
    }

    func detectInstalled() -> Bool {
        ToolDetection.findExecutable("starship")
    }

    /// Write palette reference and color definitions into starship.toml.
    ///
    /// Args:
    ///   theme: The theme to apply.
    ///   configPath: Optional override path.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath

        // One-time migration: rewrite hardcoded hex in the user's format string
        // to grad/ink slot references. Must run before the palette section below
        // is written, since that section is itself full of hex literals that a
        // later scan would misidentify as user-authored colors.
        try migrateHardcodedHexIfNeeded(in: path)

        // 段内文字颜色必须确定（设计稿用 ink 色），不能随终端默认前景漂移。
        try addInkForegrounds(in: path)

        // 空段（如语言/docker）不该留下挤扁的分隔箭头细条。
        try wrapSegmentGroupsIfNeeded(in: path)

        // Set the palette reference line (must sit in the TOML top-level area,
        // before the first [section] — replaceLine would append to EOF and
        // silently land inside the last section). The section name is fixed
        // to "tintify" so user format strings referencing grad/ink slots
        // never need to change when the theme changes.
        try ConfigWriter.replaceTopLevelKey(
            in: path,
            key: "palette",
            line: "palette = \"tintify\""
        )

        // Remove only Tintify-known [palettes.*] sections to avoid accumulation,
        // preserving any user-authored palettes.
        try removeKnownPaletteSections(in: path, currentPaletteName: "tintify")

        // Build the palette section: gradient/ink slots first, then all 26 colors.
        let p = theme.palette
        let segs = theme.promptSegments
        let section = """
            [palettes.tintify]
            grad1 = "\(segs[0].color)"
            grad2 = "\(segs[1].color)"
            grad3 = "\(segs[2].color)"
            grad4 = "\(segs[3].color)"
            grad5 = "\(segs[4].color)"
            ink1 = "\(segs[0].ink)"
            ink2 = "\(segs[1].ink)"
            ink3 = "\(segs[2].ink)"
            ink4 = "\(segs[3].ink)"
            ink5 = "\(segs[4].ink)"
            rosewater = "\(p.rosewater)"
            flamingo = "\(p.flamingo)"
            pink = "\(p.pink)"
            mauve = "\(p.mauve)"
            red = "\(p.red)"
            maroon = "\(p.maroon)"
            peach = "\(p.peach)"
            yellow = "\(p.yellow)"
            green = "\(p.green)"
            teal = "\(p.teal)"
            sky = "\(p.sky)"
            sapphire = "\(p.sapphire)"
            blue = "\(p.blue)"
            lavender = "\(p.lavender)"
            text = "\(p.text)"
            subtext1 = "\(p.subtext1)"
            subtext0 = "\(p.subtext0)"
            overlay2 = "\(p.overlay2)"
            overlay1 = "\(p.overlay1)"
            overlay0 = "\(p.overlay0)"
            surface2 = "\(p.surface2)"
            surface1 = "\(p.surface1)"
            surface0 = "\(p.surface0)"
            base = "\(p.base)"
            mantle = "\(p.mantle)"
            crust = "\(p.crust)"
            """

        try ConfigWriter.replaceTOMLSection(
            in: path,
            sectionPrefix: "[palettes.tintify]",
            newContent: section
        )
    }

    /// Remove [palettes.*] sections whose name is known to Tintify (or is the
    /// palette currently being applied). Sections with unrecognized names are
    /// left untouched — they were authored by the user.
    private func removeKnownPaletteSections(in path: String, currentPaletteName: String) throws {
        guard FileManager.default.fileExists(atPath: path) else { return }
        let content = try String(contentsOfFile: path, encoding: .utf8)
        var lines = content.components(separatedBy: "\n")

        var i = 0
        while i < lines.count {
            if lines[i].hasPrefix("[palettes.") {
                var name = lines[i].dropFirst("[palettes.".count)
                if name.hasSuffix("]") {
                    name = name.dropLast()
                }
                // Remove from this header to the next top-level section or EOF
                var end = i + 1
                while end < lines.count && !lines[end].hasPrefix("[") {
                    end += 1
                }
                if knownPaletteNames.contains(String(name)) || String(name) == currentPaletteName {
                    lines.removeSubrange(i..<end)
                    // Don't increment i — check the same index again
                    continue
                }
                i = end
            } else {
                i += 1
            }
        }

        // Remove trailing blank lines
        while lines.last?.isEmpty == true && lines.count > 1 {
            lines.removeLast()
        }

        try ConfigWriter.atomicWrite(lines.joined(separator: "\n"), to: path)
    }

    /// 给引用 grad 槽位背景但没写前景色的 style/style_* 键补上配套 fg:inkN。
    /// 不写 fg 时文字用终端默认前景，在深底终端里浅色 grad 段上是浅字，
    /// 不可读；主题的 promptSegments 为每段配了 ink 前景正是为此。
    /// 已写 fg 的样式视为用户意图，不动。幂等：补过的行含 fg: 即跳过。
    private func addInkForegrounds(in path: String) throws {
        guard FileManager.default.fileExists(atPath: path) else { return }
        let content = try String(contentsOfFile: path, encoding: .utf8)
        var lines = content.components(separatedBy: "\n")
        let regex = try! NSRegularExpression(
            pattern: "^(\\s*style\\w*\\s*=\\s*\")([^\"]*bg:grad([1-5])[^\"]*)(\".*)$")

        var changed = false
        for (i, line) in lines.enumerated() {
            let range = NSRange(line.startIndex..., in: line)
            guard let match = regex.firstMatch(in: line, range: range),
                  let value = Range(match.range(at: 2), in: line),
                  !line[value].contains("fg:") else { continue }
            let prefix = line[Range(match.range(at: 1), in: line)!]
            let slot = line[Range(match.range(at: 3), in: line)!]
            let suffix = line[Range(match.range(at: 4), in: line)!]
            lines[i] = "\(prefix)fg:ink\(slot) \(line[value])\(suffix)"
            changed = true
        }

        if changed {
            try ConfigWriter.atomicWrite(lines.joined(separator: "\n"), to: path)
        }
    }

    /// 把 format 多行字符串里的「分隔箭头 + 模块行」包进 (...) 条件组：
    /// 组内变量全空时整组（含箭头）不渲染，空段不再挤成细色条。
    /// 代价是中间段隐藏时相邻过渡箭头颜色有一处不衔接（starship 静态
    /// 配置无法按可见段动态选色）。只处理「箭头独占一行 + 后随 $模块行」
    /// 的结构，其他一律不动。幂等：包过的箭头行以 ( 开头，不再匹配。
    private func wrapSegmentGroupsIfNeeded(in path: String) throws {
        guard FileManager.default.fileExists(atPath: path) else { return }
        let content = try String(contentsOfFile: path, encoding: .utf8)

        var lines = content.components(separatedBy: "\n")

        // 定位 format 多行字符串块，找不到或不闭合则不动
        guard let open = lines.firstIndex(where: {
            let t = $0.trimmingCharacters(in: .whitespaces)
            return t == "format = \"\"\"" || t == "format = '''"
        }) else { return }
        let delimiter = lines[open].contains("\"\"\"") ? "\"\"\"" : "'''"
        guard let close = ((open + 1)..<lines.count).first(where: { lines[$0].contains(delimiter) })
        else { return }

        // 括号内是 powerline 箭头字形（如 ），允许任意非 ] 内容
        let arrow = try! NSRegularExpression(pattern: "^\\[[^\\]]*\\]\\(fg:grad[1-5] bg:grad[1-5]\\)\\\\?$")
        let module = try! NSRegularExpression(pattern: "^\\$[a-z_]+\\\\?$")
        func matches(_ regex: NSRegularExpression, _ s: String) -> Bool {
            regex.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) != nil
        }

        var changed = false
        var i = open + 1
        while i < close {
            guard matches(arrow, lines[i]) else {
                i += 1
                continue
            }
            var end = i + 1
            while end < close && matches(module, lines[end]) {
                end += 1
            }
            if end > i + 1 {
                lines[i] = "(" + lines[i]
                let last = lines[end - 1]
                lines[end - 1] = last.hasSuffix("\\")
                    ? String(last.dropLast()) + ")\\"
                    : last + ")"
                changed = true
            }
            i = end
        }

        if changed {
            Log.adapter.info("starship: 已把分隔箭头包进条件组，空段自动隐藏")
            try ConfigWriter.atomicWrite(lines.joined(separator: "\n"), to: path)
        }
    }

    /// 一次性把 format 中硬编码的 hex 迁移为 grad 槽位引用。幂等：
    /// 文件里已出现 grad1 即视为已迁移。unique hex 超过 10 个不自动迁移（日志留痕）。
    private func migrateHardcodedHexIfNeeded(in path: String) throws {
        guard FileManager.default.fileExists(atPath: path) else { return }
        let content = try String(contentsOfFile: path, encoding: .utf8)
        guard !content.contains("grad1") else { return }

        let regex = try! NSRegularExpression(pattern: "#[0-9a-fA-F]{6}")
        let range = NSRange(content.startIndex..., in: content)
        var seen: [String] = []
        for match in regex.matches(in: content, range: range) {
            let hex = String(content[Range(match.range, in: content)!]).lowercased()
            if !seen.contains(hex) { seen.append(hex) }
        }
        guard !seen.isEmpty else { return }
        guard seen.count <= 10 else {
            Log.adapter.warning("starship: 检测到 \(seen.count) 个自定义颜色，未自动迁移 format")
            return
        }

        var migrated = content
        for (i, hex) in seen.enumerated() {
            migrated = migrated.replacingOccurrences(
                of: hex, with: "grad\(min(i + 1, 5))", options: .caseInsensitive)
        }
        try ConfigWriter.atomicWrite(migrated, to: path)
    }
}
