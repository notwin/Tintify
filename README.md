<p align="center">
  <img src="AppIcon.icns" width="128" height="128" alt="Tintify">
</p>

<h1 align="center">Tintify</h1>

<p align="center">
  <strong>一键统一所有终端 CLI 工具的配色主题</strong>
</p>

<p align="center">
  <a href="https://github.com/notwin/Tintify/releases/latest"><img src="https://img.shields.io/github/v/release/notwin/Tintify?style=flat-square" alt="Release"></a>
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9%2B-orange?style=flat-square" alt="Swift">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/notwin/Tintify?style=flat-square" alt="License"></a>
</p>

---

Tintify 是一个 macOS 菜单栏应用，可以同时切换 **10 个终端工具**的配色主题。内置 **25 个精选主题**，覆盖从经典到前沿的所有热门配色方案。

## 截图

<table>
  <tr>
    <td><img src="assets/themes.png" alt="主题面板" width="500"></td>
    <td><img src="assets/menu.png" alt="菜单栏" width="250"></td>
  </tr>
  <tr>
    <td><em>设置窗口 — 主题面板，带搜索过滤和代码预览</em></td>
    <td><em>菜单栏 — 分组子菜单，快速切换</em></td>
  </tr>
</table>

<details>
<summary>终端效果预览</summary>
<br>
<img src="assets/terminal.png" alt="终端效果" width="600">
<p><em>Neon City 主题下的终端效果 — ls、bat、git diff 的配色统一</em></p>
</details>

## 功能特性

- **一键切换** — 菜单栏选择主题，10 个工具同时更新
- **25 个内置主题** — 4 大分类：热门推荐 / 经典永恒 / 新锐之选 / Tintify 原创
- **终端代码预览** — 在主题卡片中直接预览配色效果
- **搜索与过滤** — 按名称搜索，按暗色/浅色筛选
- **跟随系统外观** — 自动切换深色/浅色主题
- **快速回退** — 一键回到上一个主题
- **备份还原** — 自动备份配置文件，可一键还原
- **应用记录** — 每次切换的详细结果（成功/失败/跳过）
- **macOS 原生通知** — 切换完成后显示结果摘要

## 支持的工具

| 工具 | 配置方式 | 即时生效 |
|------|---------|---------|
| [Ghostty](https://ghostty.org) | theme 配置行 | ✅ 自动检测 |
| [Starship](https://starship.rs) | palette 色板定义 | ✅ 下个 prompt |
| [bat](https://github.com/sharkdp/bat) | BAT_THEME 环境变量 | 新终端窗口 |
| [fzf](https://github.com/junegunn/fzf) | FZF_DEFAULT_OPTS 颜色 | 新终端窗口 |
| [delta](https://github.com/dandavison/delta) | git config syntax-theme | 下次 git diff |
| [eza](https://github.com/eza-community/eza) | YAML 主题文件 | ✅ 即时 |
| [lazygit](https://github.com/jesseduffield/lazygit) | gui.theme YAML | 下次打开 |
| [tmux](https://github.com/tmux/tmux) | 状态栏 + 边框颜色 | ✅ 自动 source |
| [Vim](https://www.vim.org) | 自动生成 colorscheme | 下次打开 |
| zsh-syntax-highlighting | 跟随终端 ANSI | ✅ 即时 |

## 内置主题

<table>
  <tr>
    <th>分类</th>
    <th>主题</th>
  </tr>
  <tr>
    <td><strong>热门推荐</strong></td>
    <td>Catppuccin (Mocha/Macchiato/Frappe/Latte) · Dracula · Solarized (Dark/Light)</td>
  </tr>
  <tr>
    <td><strong>经典永恒</strong></td>
    <td>Monokai · One Dark/Light · Gruvbox (Dark/Light) · Nord</td>
  </tr>
  <tr>
    <td><strong>新锐之选</strong></td>
    <td>Tokyo Night (Night/Light) · Rose Pine (Main/Moon/Dawn) · Kanagawa (Wave/Dragon/Lotus) · Everforest Dark</td>
  </tr>
  <tr>
    <td><strong>Tintify 原创</strong></td>
    <td>Neon City · 墨竹 · 极光</td>
  </tr>
</table>

## 安装

### Homebrew (推荐)

```bash
brew tap notwin/tap
brew install --cask tintify
```

### 手动下载

从 [Releases](https://github.com/notwin/Tintify/releases/latest) 下载 `Tintify-x.x.x.dmg`，打开后将 Tintify 拖入应用程序文件夹。

### 从源码构建

```bash
git clone https://github.com/notwin/Tintify.git
cd Tintify
scripts/bundle.sh
open /Applications/Tintify.app
```

> 需要 macOS 14 (Sonoma)+ 和 Swift 5.9+

## 使用

1. 启动 Tintify，菜单栏出现调色板图标
2. 点击图标，在分组子菜单中选择主题
3. 所有工具配置自动更新
4. 新终端窗口自动生效（部分工具需要重启终端）

**设置窗口：** 点击菜单 → 设置...（⌘,）

## 开发

```bash
# 构建
swift build

# 测试（45 个测试）
swift test

# 运行（开发模式）
swift build && .build/debug/Tintify

# 打包安装到 /Applications
scripts/bundle.sh

# 构建 DMG
scripts/dmg.sh
```

## 项目结构

```
Sources/
├── App/                 # 应用入口、菜单栏、系统外观监听、通知
├── Models/              # Theme、Palette、AppSettings、ApplyResult
├── Engine/              # ThemeEngine 编排器、ThemeRegistry、ConfigWriter、BackupManager
│   └── ThemeDefinitions/  # 按分类的主题定义文件
├── Adapters/            # 10 个工具适配器（每个工具一个文件）
└── Settings/            # SwiftUI 设置窗口（6 个面板）
```

## 贡献

欢迎 PR 和 Issue！

- **新增主题：** 在 `Sources/Engine/ThemeDefinitions/` 对应分类文件中添加
- **新增工具适配器：** 实现 `ToolAdapter` 协议，注册到 `ThemeEngine`
- **Bug 反馈：** [提交 Issue](https://github.com/notwin/Tintify/issues)

## 许可证

[MIT](LICENSE) © 2026 notwin
