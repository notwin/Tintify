// Sources/App/CLIRunner.swift
import AppKit

/// Headless CLI 入口：`Tintify cli set <id>` 等命令直接在进程内应用主题，
/// 不启动 GUI。bash 包装脚本（scripts/tintify）只是它的薄壳。
enum CLIRunner {
    static let externalChangeNotification = "com.notwin.Tintify.themeChangedExternally"

    static func run(_ args: [String]) -> Never {
        // CLI 进程的主线程即 MainActor
        MainActor.assumeIsolated {
            switch args.first {
            case "set":
                set(themeId: args.count > 1 ? args[1] : nil)
            case "list":
                list()
            case "current":
                current()
            case "tools":
                tools()
            case "themes-json":
                themesJSON()
            case "doctor":
                doctor()
            default:
                usage()
            }
        }
        exit(0)
    }

    @MainActor
    private static func set(themeId: String?) {
        guard let themeId, let theme = ThemeRegistry.shared.theme(id: themeId) else {
            print(L("错误: 未找到主题 '\(themeId ?? "")'。运行 'tintify list' 查看可用主题。"))
            exit(1)
        }
        let result = ThemeApplicationService.apply(theme: theme)
        for tool in result.toolResults {
            let mark: String
            switch tool.status {
            case .success: mark = "✓"
            case .skipped: mark = "-"
            case .failed:  mark = "✗"
            }
            let detail = tool.message.map { " (\($0))" } ?? ""
            print("  \(mark) \(tool.toolName)\(detail)")
        }
        print("\(theme.name): \(result.summary)")

        // 通知运行中的 GUI 实例刷新状态
        DistributedNotificationCenter.default().postNotificationName(
            .init(externalChangeNotification), object: nil, userInfo: nil,
            deliverImmediately: true
        )
        exit(result.successCount > 0 ? 0 : 1)
    }

    @MainActor
    private static func list() {
        let current = AppSettings.shared.currentThemeId
        for category in ThemeCategory.allCases {
            let themes = ThemeRegistry.shared.themes(for: category)
            guard !themes.isEmpty else { continue }
            print("\(category.displayName)")
            for theme in themes {
                let marker = theme.id == current ? "✓ " : "  "
                let badge = theme.appearance == .light ? " " + L("(浅色)") : ""
                print("  \(marker)\(theme.id) — \(theme.name)\(badge)")
            }
            print("")
        }
    }

    @MainActor
    private static func current() {
        let id = AppSettings.shared.currentThemeId
        if let theme = ThemeRegistry.shared.theme(id: id) {
            print("\(theme.name) (\(theme.id)) — \(theme.category.displayName)")
        } else {
            print(L("\(id) (未知主题)"))
        }
    }

    @MainActor
    private static func tools() {
        let disabled = AppSettings.shared.disabledTools
        print(L("工具状态") + "\n")
        for factory in ThemeEngine.adapterFactories {
            let adapter = factory()
            if disabled.contains(adapter.toolName) {
                print("  ✗ \(adapter.toolName) — \(L("已禁用"))")
            } else {
                print("  ✓ \(adapter.toolName) — \(L("已启用"))")
            }
        }
    }

    @MainActor
    private static func themesJSON() {
        struct Entry: Codable {
            let id: String
            let toolNames: [String: String]
        }
        let entries = ThemeRegistry.shared.allThemes.map {
            Entry(id: $0.id, toolNames: $0.toolNames)
        }
        let data = try! JSONEncoder().encode(entries)
        print(String(data: data, encoding: .utf8)!)
    }

    @MainActor
    private static func doctor() {
        let id = AppSettings.shared.currentThemeId
        guard let theme = ThemeRegistry.shared.theme(id: id) else {
            print(L("当前主题未知（\(id)），先用 tintify set 应用一个主题再体检"))
            exit(1)
        }
        print(L("Tintify 体检 — 当前主题：\(theme.name)") + "\n")
        let findings = Doctor(theme: theme).diagnose()
        for finding in findings {
            print("  \(finding.level.rawValue) \(finding.tool)  \(finding.message)")
        }
        let fails = findings.filter { $0.level == .fail }.count
        let warns = findings.filter { $0.level == .warn }.count
        print("\n" + L("体检完成：\(fails) 个问题，\(warns) 个提醒"))
        if fails > 0 {
            print(L("提示：多数问题重新应用主题即可修复（tintify set \(theme.id)）"))
        }
        exit(fails > 0 ? 1 : 0)
    }

    private static func usage() {
        print("""
        tintify — 终端主题管理器 CLI

        用法:
          tintify set <theme-id>    切换主题
          tintify list              列出所有主题
          tintify current           显示当前主题
          tintify tools             显示工具状态
          tintify doctor            体检各工具配置是否实际生效
        """)
    }
}
