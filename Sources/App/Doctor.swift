// Sources/App/Doctor.swift
import Foundation

/// `tintify doctor`：体检每个工具的「写入的配置」vs「实际会生效的状态」。
/// 覆盖的故障模式全部来自实战：bat 生成主题没注册进缓存、bat/delta
/// 版本错配导致自定义主题被静默回退、starship palette 行丢失、
/// otty/ghostty 主题文件缺失、bat 配置文件覆盖 env 等。
struct Doctor {
    struct Finding {
        enum Level: String {
            case ok = "✓", warn = "⚠", fail = "✗", skip = "-"
        }
        let level: Level
        let tool: String
        let message: String
    }

    let theme: Theme
    let home: String
    /// 跑外部命令拿 stdout（失败返回 nil）；测试注入假实现
    let runCommand: (_ executable: String, _ args: [String]) -> String?
    /// 工具是否安装；测试注入假实现（CI 上没有这些工具）
    let isInstalled: (_ name: String) -> Bool

    init(
        theme: Theme,
        home: String = NSHomeDirectory(),
        runCommand: ((String, [String]) -> String?)? = nil,
        isInstalled: ((String) -> Bool)? = nil
    ) {
        self.theme = theme
        self.home = home
        self.runCommand = runCommand ?? Doctor.runProcess
        self.isInstalled = isInstalled ?? { name in
            name == "otty"
                ? FileManager.default.fileExists(atPath: "/Applications/Otty.app")
                : ToolDetection.findExecutable(name)
        }
    }

    func diagnose() -> [Finding] {
        starshipChecks() + batChecks() + deltaChecks() + ezaChecks()
            + ottyChecks() + ghosttyChecks() + fzfChecks() + vimChecks()
    }

    // MARK: - 各工具检查

    private func starshipChecks() -> [Finding] {
        guard let lines = fileLines("\(home)/.config/starship.toml") else {
            return [Finding(level: .skip, tool: "starship", message: L("未找到配置，跳过"))]
        }
        var findings: [Finding] = []
        if !lines.contains(where: { $0.trimmingCharacters(in: .whitespaces) == "palette = \"tintify\"" }) {
            findings.append(Finding(level: .fail, tool: "starship",
                message: L("缺顶层 palette = \"tintify\" 引用，重新应用主题可修复")))
        }
        if !lines.contains(where: { $0.hasPrefix("[palettes.tintify]") }) {
            findings.append(Finding(level: .fail, tool: "starship",
                message: L("缺 [palettes.tintify] 色板块，重新应用主题可修复")))
        }
        if findings.isEmpty {
            findings.append(Finding(level: .ok, tool: "starship", message: L("palette 引用与色板块齐全")))
        }
        return findings
    }

    private func batChecks() -> [Finding] {
        guard isInstalled("bat") else {
            return [Finding(level: .skip, tool: "bat", message: L("未安装，跳过"))]
        }
        var findings: [Finding] = []
        let expected: String
        switch theme.themeSource(for: .bat) {
        case .builtin(let name): expected = name
        case .generate: expected = TmThemeInstaller.themeName
        }

        let zshrc = (fileLines("\(home)/.zshrc") ?? [])
        let batLine = zshrc.first { $0.contains("BAT_THEME") }
        if batLine?.contains("\"\(expected)\"") != true {
            findings.append(Finding(level: .fail, tool: "bat",
                message: L("BAT_THEME 与主题不符（期望 \(expected)），重新应用主题可修复")))
        }
        if expected == TmThemeInstaller.themeName {
            let themes = runCommand("bat", ["--list-themes"]) ?? ""
            if !themes.components(separatedBy: "\n").contains(TmThemeInstaller.themeName) {
                findings.append(Finding(level: .fail, tool: "bat",
                    message: L("生成主题未注册进 bat 缓存，重新应用主题（会自动 bat cache --build）")))
            }
        }
        if let config = try? String(contentsOfFile: "\(home)/.config/bat/config", encoding: .utf8),
           config.contains("--theme") {
            findings.append(Finding(level: .warn, tool: "bat",
                message: L("~/.config/bat/config 里有 --theme，部分场景会覆盖 Tintify 的设置")))
        }
        if findings.isEmpty {
            findings.append(Finding(level: .ok, tool: "bat", message: L("BAT_THEME 匹配且主题已注册")))
        }
        return findings
    }

    private func deltaChecks() -> [Finding] {
        guard isInstalled("delta") else {
            return [Finding(level: .skip, tool: "delta", message: L("未安装，跳过"))]
        }
        let expected: String
        switch theme.themeSource(for: .delta) {
        case .builtin(let name): expected = name
        case .generate: expected = TmThemeInstaller.themeName
        }
        let actual = runCommand("git", ["config", "--global", "--get", "delta.syntax-theme"])?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if actual != expected {
            return [Finding(level: .fail, tool: "delta",
                message: L("syntax-theme 是 \(actual ?? "未设置")，期望 \(expected)，重新应用主题可修复"))]
        }
        if expected == TmThemeInstaller.themeName {
            let themes = runCommand("delta", ["--list-syntax-themes"]) ?? ""
            if !themes.contains(TmThemeInstaller.themeName) {
                // delta 读 bat 编译缓存，版本严重错配时会静默回退内置主题集
                return [Finding(level: .fail, tool: "delta",
                    message: L("delta 看不到生成主题——bat 与 delta 版本可能错配，缓存被静默忽略"))]
            }
        }
        return [Finding(level: .ok, tool: "delta", message: L("syntax-theme 匹配且 delta 可见"))]
    }

    private func ezaChecks() -> [Finding] {
        guard isInstalled("eza") else {
            return [Finding(level: .skip, tool: "eza", message: L("未安装，跳过"))]
        }
        var findings: [Finding] = []
        let themePath = "\(home)/Library/Application Support/eza/theme.yml"
        let content = try? String(contentsOfFile: themePath, encoding: .utf8)
        if content?.hasPrefix("# Tintify-managed") != true {
            findings.append(Finding(level: .fail, tool: "eza",
                message: L("主题文件缺失或非 Tintify 管理，重新应用主题可修复")))
        }
        if FileManager.default.fileExists(atPath: "\(home)/.config/eza/theme.yml") {
            findings.append(Finding(level: .warn, tool: "eza",
                message: L("~/.config/eza/theme.yml 是残留（macOS 上 eza 读 Application Support），建议删除")))
        }
        if findings.isEmpty {
            findings.append(Finding(level: .ok, tool: "eza", message: L("主题文件在位")))
        }
        return findings
    }

    private func ottyChecks() -> [Finding] {
        guard isInstalled("otty") else {
            return [Finding(level: .skip, tool: "otty", message: L("未安装，跳过"))]
        }
        let expected = "tintify-\(theme.id)"
        let config = (fileLines("\(home)/.config/otty/config.toml") ?? [])
        var findings: [Finding] = []
        if !config.contains(where: { $0.hasPrefix("theme = \"\(expected)\"") }) {
            findings.append(Finding(level: .fail, tool: "otty",
                message: L("config.toml 的 theme 不是 \(expected)，重新应用主题可修复")))
        }
        if !FileManager.default.fileExists(atPath: "\(home)/.config/otty/themes/\(expected).ottytheme") {
            findings.append(Finding(level: .fail, tool: "otty",
                message: L("主题文件 \(expected).ottytheme 缺失，重新应用主题可修复")))
        }
        if findings.isEmpty {
            findings.append(Finding(level: .ok, tool: "otty", message: L("配置与主题文件在位（应用后自动重载）")))
        }
        return findings
    }

    private func ghosttyChecks() -> [Finding] {
        let configPath = "\(home)/Library/Application Support/com.mitchellh.ghostty/config"
        guard let lines = fileLines(configPath) else {
            return [Finding(level: .skip, tool: "ghostty", message: L("未找到配置，跳过"))]
        }
        let expected: String
        var needsFile = false
        switch theme.themeSource(for: .ghostty) {
        case .builtin(let name): expected = name
        case .generate(let name): expected = name; needsFile = true
        }
        if !lines.contains(where: { $0.trimmingCharacters(in: .whitespaces) == "theme = \(expected)" }) {
            return [Finding(level: .fail, tool: "ghostty",
                message: L("theme 行不是 \(expected)，重新应用主题可修复"))]
        }
        if needsFile && !FileManager.default.fileExists(atPath: "\(home)/.config/ghostty/themes/\(expected)") {
            return [Finding(level: .fail, tool: "ghostty",
                message: L("生成主题文件缺失，重新应用主题可修复"))]
        }
        return [Finding(level: .ok, tool: "ghostty", message: L("配置就绪（已开窗口需 ⌘⇧, 重载）"))]
    }

    private func fzfChecks() -> [Finding] {
        guard isInstalled("fzf") else {
            return [Finding(level: .skip, tool: "fzf", message: L("未安装，跳过"))]
        }
        let zshrc = (fileLines("\(home)/.zshrc") ?? [])
        if !zshrc.contains(where: { $0.contains("FZF_DEFAULT_OPTS") }) {
            return [Finding(level: .fail, tool: "fzf",
                message: L("FZF_DEFAULT_OPTS 缺失，重新应用主题可修复"))]
        }
        return [Finding(level: .ok, tool: "fzf", message: L("颜色参数在位"))]
    }

    private func vimChecks() -> [Finding] {
        guard isInstalled("vim") else {
            return [Finding(level: .skip, tool: "vim", message: L("未安装，跳过"))]
        }
        let scheme = try? String(contentsOfFile: "\(home)/.vim/colors/tintify.vim", encoding: .utf8)
        guard let scheme else {
            return [Finding(level: .fail, tool: "vim",
                message: L("colorscheme 文件缺失，重新应用主题可修复"))]
        }
        if !scheme.contains("set termguicolors") {
            return [Finding(level: .fail, tool: "vim",
                message: L("colorscheme 是旧版（缺 termguicolors），重新应用主题可修复"))]
        }
        return [Finding(level: .ok, tool: "vim", message: L("colorscheme 就位且启用真彩"))]
    }

    // MARK: - 基础设施

    private func fileLines(_ path: String) -> [String]? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
        return content.components(separatedBy: "\n")
    }

    /// 真实执行外部命令（git 用系统路径，其余走 ToolDetection）。
    static func runProcess(_ executable: String, _ args: [String]) -> String? {
        let path: String?
        if executable == "git" {
            path = "/usr/bin/git"
        } else {
            path = ToolDetection.executablePath(executable)
        }
        guard let path else { return nil }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
