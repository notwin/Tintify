import Testing
import Foundation
@testable import Tintify

/// 构造一个「一切健康」的假 home（针对墨与朱），单项破坏后断言对应 fail。
private func makeHealthyHome(theme: Theme) throws -> String {
    let home = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString).path
    let fm = FileManager.default
    try fm.createDirectory(atPath: "\(home)/.config", withIntermediateDirectories: true)
    try fm.createDirectory(atPath: "\(home)/.config/otty/themes", withIntermediateDirectories: true)
    try fm.createDirectory(atPath: "\(home)/Library/Application Support/eza", withIntermediateDirectories: true)
    try fm.createDirectory(atPath: "\(home)/Library/Application Support/com.mitchellh.ghostty", withIntermediateDirectories: true)
    try fm.createDirectory(atPath: "\(home)/.config/ghostty/themes", withIntermediateDirectories: true)
    try fm.createDirectory(atPath: "\(home)/.vim/colors", withIntermediateDirectories: true)

    try "palette = \"tintify\"\n\n[palettes.tintify]\ngrad1 = \"#fff\"\n"
        .write(toFile: "\(home)/.config/starship.toml", atomically: true, encoding: .utf8)
    try "export BAT_THEME=\"tintify\"\nexport FZF_DEFAULT_OPTS=\"--color=bg:#000\"\n"
        .write(toFile: "\(home)/.zshrc", atomically: true, encoding: .utf8)
    try "# Tintify-managed eza theme\nfilekinds:\n"
        .write(toFile: "\(home)/Library/Application Support/eza/theme.yml", atomically: true, encoding: .utf8)
    try "theme = \"tintify-\(theme.id)\"\ntheme-dark = \"tintify-\(theme.id)\"\n"
        .write(toFile: "\(home)/.config/otty/config.toml", atomically: true, encoding: .utf8)
    try "[meta]\n".write(
        toFile: "\(home)/.config/otty/themes/tintify-\(theme.id).ottytheme",
        atomically: true, encoding: .utf8)
    try "theme = \(theme.name)\n".write(
        toFile: "\(home)/Library/Application Support/com.mitchellh.ghostty/config",
        atomically: true, encoding: .utf8)
    try "x".write(toFile: "\(home)/.config/ghostty/themes/\(theme.name)", atomically: true, encoding: .utf8)
    try "\" scheme\nif has('termguicolors')\n  set termguicolors\nendif\n"
        .write(toFile: "\(home)/.vim/colors/tintify.vim", atomically: true, encoding: .utf8)
    return home
}

private func makeDoctor(
    theme: Theme, home: String,
    batThemes: String = "ansi\ntintify\n",
    deltaThemes: String = "dark tintify\n",
    gitSyntaxTheme: String = "tintify\n"
) -> Doctor {
    Doctor(
        theme: theme, home: home,
        runCommand: { exe, _ in
            switch exe {
            case "bat": return batThemes
            case "delta": return deltaThemes
            case "git": return gitSyntaxTheme
            default: return ""
            }
        },
        isInstalled: { _ in true }
    )
}

@Test func doctorPassesOnHealthyState() throws {
    let theme = ThemeRegistry.shared.theme(id: "ink-vermilion")!
    let home = try makeHealthyHome(theme: theme)
    let findings = makeDoctor(theme: theme, home: home).diagnose()
    let fails = findings.filter { $0.level == .fail }
    #expect(fails.isEmpty, "不该有问题: \(fails.map(\.message))")
}

@Test func doctorFlagsUnregisteredBatTheme() throws {
    let theme = ThemeRegistry.shared.theme(id: "ink-vermilion")!
    let home = try makeHealthyHome(theme: theme)
    // bat 缓存里没有 tintify（比如用户手动 bat cache --clear 过）
    let findings = makeDoctor(theme: theme, home: home, batThemes: "ansi\nGitHub\n").diagnose()
    #expect(findings.contains { $0.tool == "bat" && $0.level == .fail })
}

@Test func doctorFlagsDeltaCacheMismatch() throws {
    let theme = ThemeRegistry.shared.theme(id: "ink-vermilion")!
    let home = try makeHealthyHome(theme: theme)
    // git config 对但 delta 列不出来 = bat/delta 版本错配的静默回退
    let findings = makeDoctor(theme: theme, home: home, deltaThemes: "dark OneHalfDark\n").diagnose()
    #expect(findings.contains { $0.tool == "delta" && $0.level == .fail })
}

@Test func doctorFlagsCorruptedStarship() throws {
    let theme = ThemeRegistry.shared.theme(id: "ink-vermilion")!
    let home = try makeHealthyHome(theme: theme)
    try "format = \"$all\"\n".write(
        toFile: "\(home)/.config/starship.toml", atomically: true, encoding: .utf8)
    let findings = makeDoctor(theme: theme, home: home).diagnose()
    #expect(findings.filter { $0.tool == "starship" && $0.level == .fail }.count == 2)
}

@Test func doctorWarnsAboutBatConfigOverride() throws {
    let theme = ThemeRegistry.shared.theme(id: "ink-vermilion")!
    let home = try makeHealthyHome(theme: theme)
    try FileManager.default.createDirectory(atPath: "\(home)/.config/bat", withIntermediateDirectories: true)
    try "--theme=\"GitHub\"\n".write(toFile: "\(home)/.config/bat/config", atomically: true, encoding: .utf8)
    let findings = makeDoctor(theme: theme, home: home).diagnose()
    #expect(findings.contains { $0.tool == "bat" && $0.level == .warn })
}
