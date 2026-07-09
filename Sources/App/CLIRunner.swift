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
            default:
                usage()
            }
        }
        exit(0)
    }

    @MainActor
    private static func set(themeId: String?) {
        guard let themeId, let theme = ThemeRegistry.shared.theme(id: themeId) else {
            print("错误: 未找到主题 '\(themeId ?? "")'。运行 'tintify list' 查看可用主题。")
            exit(1)
        }
        let result = ThemeEngine().apply(theme: theme)
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
            print("\(category.rawValue)")
            for theme in themes {
                let marker = theme.id == current ? "✓ " : "  "
                let badge = theme.appearance == .light ? " (浅色)" : ""
                print("  \(marker)\(theme.id) — \(theme.name)\(badge)")
            }
            print("")
        }
    }

    @MainActor
    private static func current() {
        let id = AppSettings.shared.currentThemeId
        if let theme = ThemeRegistry.shared.theme(id: id) {
            print("\(theme.name) (\(theme.id)) — \(theme.category.rawValue)")
        } else {
            print("\(id) (未知主题)")
        }
    }

    @MainActor
    private static func tools() {
        let disabled = AppSettings.shared.disabledTools
        print("工具状态\n")
        for factory in ThemeEngine.adapterFactories {
            let adapter = factory()
            if disabled.contains(adapter.toolName) {
                print("  ✗ \(adapter.toolName) — 已禁用")
            } else {
                print("  ✓ \(adapter.toolName) — 已启用")
            }
        }
    }

    private static func usage() {
        print("""
        tintify — 终端主题管理器 CLI

        用法:
          tintify set <theme-id>    切换主题
          tintify list              列出所有主题
          tintify current           显示当前主题
          tintify tools             显示工具状态
        """)
    }
}
