# Repository Guidelines

## Project Overview

Tintify 是一个 macOS 14+ 菜单栏应用，一键把同一套配色主题统一写入 12 个终端 CLI 工具的配置文件。内置 28 个精选主题（4 类：热门/经典/新锐/原创），含 SwiftUI 设置窗口（「主题即界面」，整窗跟随主题换肤）、headless CLI、配置备份还原、应用历史、`doctor` 体检诊断、GitHub Releases 自动更新。

技术栈：Swift 5.9+ / SwiftUI + AppKit / Swift Package Manager / LaunchAtLogin-Modern。无 Node/package.json，无 Xcode 工程文件，无 lint/format 配置。

## Architecture & Data Flow

核心是一条单漏斗式 apply 管线，UI 与 CLI 共用同一入口，保证行为一致：

1. 入口 `Sources/App/TintifyApp.swift`：`TintifyMain.main()` 检测 `argv[1]=="cli"` 转 `CLIRunner`（headless，不启动 GUI），否则启动 `TintifyApp`。`AppDelegate` 持有 `MenuBarManager` 与 `SystemAppearanceMonitor`；空 `Settings` scene（纯菜单栏 app，设置窗口由 `MenuBarManager` 手动用 `NSWindow` + `NSHostingController` 管理）。
2. apply 唯一入口 `ThemeApplicationService.apply`（`@MainActor` 静态方法）：快照 `AppSettings` → 展开 `~` 路径 → 构造 `ThemeEngine(pathOverrides:disabledTools:)` → `engine.apply` → 仅当 `successCount>0` 才更新 `currentThemeId`/`previousThemeId` → `ApplyHistoryStore.record` → `NotificationManager.notify`。
3. 引擎层 `ThemeEngine`：纯文件 IO 编排（非 `@MainActor`、不碰 `AppSettings`）。收集并去重各适配器 configPaths → `BackupManager.backup`（失败则全部中止并标记 failed，用户配置不动）→ 逐适配器：跳过 disabled、解析路径(override>default)、`try apply`、`catch` 进 `ToolResult`。
4. 适配器层：`Sources/Adapters/` 每个文件实现 `ToolAdapter` 协议服务一个工具。用 `Theme.themeSource(for:)` 决定引用内置主题名 vs 生成配色文件，经 `ConfigWriter` 原语安全写入。
5. 主题数据：编译期内置 Swift 数据（`ThemeDefinitions/*.swift`），无网络拉取。唯一网络边界是 `UpdateManager`（GitHub Releases 自更新）。
6. 状态层：`AppSettings`（`@MainActor`，`@Published`+`didSet` 写穿 `UserDefaults`）；`ApplyHistoryStore`（`~/.tintify/history.json`，上限 50 条）。
7. CLI/GUI 同步：`CLIRunner` set 成功后经 `DistributedNotificationCenter` 发 `com.notwin.Tintify.themeChangedExternally`，GUI 监听后 reload 状态。
8. 换肤层：`SkinModel.previewTheme` 是试穿态（永不落盘、永不调 `ThemeApplicationService`），`ThemeSkin` 把 palette 映射成 11 个语义 UI token，设置窗口全部从这里取色。

## Key Directories

- `Sources/App/` — 应用生命周期、菜单栏、CLI、诊断、更新管理、日志、通知、应用历史、apply 编排入口。
- `Sources/Models/` — 主题模型（`Theme`/`Palette` 26 色）、`ToolID`、`AppSettings`、`ThemeSkin` UI token、`SkinModel`、本地化 `L(_:)`、`ApplyResult`。
- `Sources/Engine/` — `ThemeEngine` 编排、`ThemeRegistry`、`ConfigWriter` 安全写入、`BackupManager`、`AnsiPalette`、`TmThemeGenerator`（bat/delta 共用 .tmTheme 生成）。
- `Sources/Engine/ThemeDefinitions/` — 28 个内置主题，按分类分文件：`PopularThemes`/`TimelessThemes`/`TrendingThemes`/`OriginalThemes`。
- `Sources/Adapters/` — 12 个工具适配器（每工具一文件）+ `ToolAdapter` 协议 + `ToolDetection`。
- `Sources/Settings/` — SwiftUI 设置窗口（6 pane）与可复用换肤 UI 组件。
- `Sources/Resources/{en,zh-Hans}.lproj/` — 本地化字符串（SwiftPM `Bundle.module` 资源）。
- `Tests/` — Swift Testing 测试（26 文件，平铺，无共享 helper/fixture 目录）。
- `scripts/` — 开发/打包/发版/本地化同步/主题名核对的 bash 脚本。
- `.github/workflows/ci.yml` — CI（`macos-15` runner）。

## Development Commands

```bash
swift build                         # 构建 debug target
swift test                          # 跑 Swift Testing 套件（需 Xcode 16+）
bash scripts/dev-run.sh             # 调试运行：build 后把 debug 二进制塞进 .app 壳再启动
bash scripts/dev-run.sh --settings  # 启动即直开设置窗口
.build/debug/Tintify cli list       # headless CLI（裸跑 OK，无 GUI）
.build/debug/Tintify cli set nord
.build/debug/Tintify cli doctor
bash scripts/sync-strings.sh        # 从 en 派生 zh-Hans 本地化副本
bash scripts/verify-theme-names.sh  # 核对主题名（需先 swift build）
scripts/bundle.sh                   # release 构建 + ad-hoc 签名 + 装 /Applications
scripts/dmg.sh                      # 打 Tintify-<version>.dmg + .sha256
```

发版（仅当被明确要求时执行，有发布副作用）：

```bash
bash scripts/release.sh <x.y.z> <release说明.md>
```

## Code Conventions & Common Patterns

- 遵循 Swift API Design Guidelines，每文件单一职责；匹配现有中英混合注释风格，不要重新格式化相邻代码。
- `@MainActor` 边界：凡碰 SwiftUI/AppKit/`UserDefaults` 的对象都是 `@MainActor`（`AppSettings`、`MenuBarManager`、`ThemeApplicationService`、`ApplyHistoryStore`、`UpdateManager`、`SkinModel`）。`ThemeEngine` 是纯文件 IO，保持非 `@MainActor`。
- **新增支持工具的四步**（`ToolID` 是工具清单唯一真相源，UI 三处自动派生）：
  1. `Sources/Models/ToolID.swift` 加 `ToolID` case。
  2. `Sources/Adapters/` 加一个实现 `ToolAdapter` 的文件（`id`/`defaultConfigPath`/`apply`/`detectInstalled`）。
  3. `ThemeEngine.adapterFactories` 加一行构造器。
  4. 加适配器测试。不要建平行工具清单。
- **配置写入必须保留用户内容**：优先用 `ConfigWriter` 原语——`writeMarkerBlock`（标记块 `# === TINTIFY START/END ===`，`commentPrefix` 可配如 vim 用 `"`）、`replaceLine`、`replaceTopLevelKey`（TOML 顶层感知，跳过多行字符串内部）、`replaceTOMLSection`。一律走 `ConfigWriter.atomicWrite`（先解析 symlink 再写，避免把 dotfiles 链接替换成普通文件）。孤儿/乱序标记抛错拒写，绝不吞用户内容。
- **主题命名**：`Theme.toolNames` 存每工具名，用 `theme.nameForTool("bat")` 或 `theme.themeSource(for:)`（返回 `.builtin`/`.generate`），不要在适配器里做布尔嗅探。
- **主题定义不变量**（有守护测试）：28 个主题、`AppSettings.retiredThemeIds` 裁撤迁移有效、variants 不引用已裁撤 id、26 色 palette、每主题恰好 5 段 `promptSegments`（color+ink 合法 `#rrggbb`）、category/appearance 元数据、`ThemeCategory` 兼容旧版中文 rawValue。
- **本地化**：用户可见字符串走 `L("中文 key")`（资源在 `Bundle.module` 不是 `Bundle.main`）。只手维护 `Sources/Resources/en.lproj/Localizable.strings`（key=中文、value=英文），改完跑 `bash scripts/sync-strings.sh` 派生 zh-Hans 副本。不要引入 `.xcstrings`（SwiftPM 不编译）。
- **设置窗口取色**：一律从 `ThemeSkin` 语义 token，别直拿 palette 槽——`ThemeSkinTests` 对全部主题断言正文对比度 ≥4.0、accent 字色 ≥2.5。`SkinModel.previewTheme` 只染窗口，永不落盘/apply。
- **布局预算**：窗口 minWidth 760，减侧边栏后内容区约 588pt；塞不下 SwiftUI 会折行、chip 高矮不齐——chip 类文字一律 `lineLimit(1)` + `fixedSize()` 兜底。
- **可复用控件样式不要内置布局意图**（Spacer/对齐归调用方）。
- **日志**用 `Log.engine`/`Log.adapter`/`Log.update`/`Log.history`（os.Logger），诊断日志保持中文不本地化。
- **工具检测**必须走 `ToolDetection.binSearchPaths`（GUI PATH 不含 Homebrew）。

## Important Files

- `Package.swift` — SwiftPM 清单：tools-version 5.9、`platforms [.macOS(.v14)]`、`defaultLocalization "zh-Hans"`、executableTarget `Tintify`（path `Sources`，resources `[.process("Resources")]`，依赖 LaunchAtLogin）、testTarget `TintifyTests`（path `Tests`）。
- `Package.resolved` — 锁定唯一依赖 launchatlogin-modern v1.1.0。
- `Info.plist` — bundle id/version（版本号唯一真源）、`LSUIElement=true`、`LSMinimumSystemVersion 14.0`、`CFBundleLocalizations [zh-Hans, en]`。
- `Sources/App/TintifyApp.swift` — GUI/CLI 分流与 AppDelegate。
- `Sources/App/ThemeApplicationService.swift` — apply 唯一入口。
- `Sources/App/MenuBarManager.swift` — `NSStatusItem` 菜单 + 设置窗口宿主（`menuNeedsUpdate` 每次打开重建菜单）。
- `Sources/App/CLIRunner.swift` — CLI 子命令 `set`/`list`/`current`/`tools`/`themes-json`/`doctor`（`themes-json` 是内部命令供脚本用，未列在 usage）。
- `Sources/App/Doctor.swift` — 配置诊断，`runCommand`/`isInstalled` 可注入便于测试。
- `Sources/Engine/ThemeEngine.swift` — 编排 + `adapterFactories`（适配器注册唯一位置）。
- `Sources/Engine/ConfigWriter.swift` — 安全文件写入原语（symlink 原子写、标记块、TOML 感知）。
- `Sources/Engine/BackupManager.swift` — `~/.tintify/backups`，initial 永久快照 + 滚动 prune 到 10。
- `Sources/Engine/TmThemeGenerator.swift` — bat/delta 共用 .tmTheme 生成 + `TmThemeInstaller`（内容变化才 `bat cache --build`，幂等）。
- `Sources/Models/Theme.swift` — `Theme`/`Palette`/`ThemeCategory`/`ToolThemeSource`/`PromptSegment`。
- `Sources/Models/AppSettings.swift` — 持久化偏好 + `retiredThemeIds` 裁撤迁移 + `reload()`。
- `Sources/Models/ToolID.swift` — 12 工具稳定标识 + `displayName`。
- `Sources/Models/ThemeSkin.swift` — 11 个语义 UI token + `isLight(hex:)` 判定（决定窗口 NSAppearance）。
- `.github/workflows/ci.yml` — CI 必须 `macos-15`（Swift Testing 需 Xcode 16+）。
- `scripts/dev-run.sh` — 正确的 GUI 调试运行器。

## Runtime/Tooling Preferences

- **运行时**：macOS 14+（app）；CI 与本地 `swift test` 需 Xcode 16+（macos-15 runner），否则 Swift Testing 报 `no such module 'Testing'`。
- **包管理/构建**：纯 SwiftPM，用 `swift build` / `swift test`。无 Bun/npm/yarn/Makefile/Taskfile，所有入口在 `scripts/*.sh`。无独立 typecheck 命令——`swift build` 即类型检查。无项目级 lint/format 配置。
- **GUI 调试必须用 `bash scripts/dev-run.sh`**：macOS 26 对菜单栏宿主有打包/签名要求，裸跑 `.build/debug/Tintify` 会让状态栏图标被系统扣下（parked off-screen）。裸跑 debug 二进制仅限 `cli` 子命令（无 GUI）。
- **绝不同时跑两个 Tintify 实例**：`dev-run.sh` 与 `bundle.sh` 都会 `pkill -9 -f Tintify`；`release.sh` 收尾会 `open /Applications/Tintify.app`。
- 签名全程 ad-hoc（`codesign --force --deep -s -`），无 Developer ID / notarization。
- **SourceKit 诊断常是索引滞后的误报**（跨文件移动、新增类型后成片报 Cannot find in scope）——以 `swift build` 实际结果为准。
- 版本号唯一真源是 `Info.plist`（`release.sh` 用 PlistBuddy bump，build 号自增）。
- 无 `.env`（GUI 应用无密钥注入）；`release.sh` 需 `gh auth login` + notwin/homebrew-tap 写权限 + 在 main 分支且工作区干净。
- 生成/发版产物（`Tintify-*.dmg`、`.build/`、`.dmg-staging`）是输出，不是源码改动。

## Testing & QA

- 测试框架：Swift Testing（`import Testing` / `@Test` / `#expect` / `#require`），非 XCTest。26 个文件平铺在 `Tests/`，命名 `<Component>Tests.swift`。
- 运行：`swift test`（CI 跑 `swift build` 后 `swift test`）。本地同样需 Xcode 16+ 工具链。
- **隔离与注入**：无 fixture 目录——全部在 `FileManager.temporaryDirectory` 下现场生成。适配器/Doctor/Installer 全依赖注入（`runCommand`/`isInstalled` 闭包、构造器传 `backupRoot`/`themesDir`/`storageURL`/`pathOverrides`），测试不碰真实 CLI/shell/UserDefaults/网络。
- **守护不变量**（改相关代码后确认不破）：28 主题总数、retired 迁移往返、6 原创主题、暗/亮各 ≥6/≥3、每主题 5 段 promptSegments、ANSI 16 色三家（ghostty/otty/wezterm）共用构建器、12 ToolID 注册完备性。
- **安全守护**：`ConfigWriter` 孤儿标记抛错且文件原封不动、atomicWrite 保留 symlink、引擎 backup-fail 中止写、备份 initial 快照不被 prune + 增量、滚动留 10。
- **对比度守护**：`ThemeSkinTests` 遍历全部主题断言正文 ≥4.0、accent 字色 ≥2.5、`isLight` 与主题声明深浅一致——新 UI 色走 token 层才受保护。
- **复杂迁移守护**：`StarshipAdapterTests` 覆盖固定 `tintify` 段、硬编码 hex→渐变槽迁移、补 `fg:inkN`、二次 apply 幂等、条件组拆回、hex 过多不迁移。
- **Doctor 静默失败守护**：bat 缓存缺 tintify、delta 版本错配静默回退、starship palette 损坏、bat config 覆盖 env。
- 本地化改动后跑 `bash scripts/sync-strings.sh` 再 `swift test`（`LocalizationTests` 锁定种子条目）。
- GUI 改动后用 `bash scripts/dev-run.sh --settings` 走查全部 6 个 pane，别只验收改动的那一页。
