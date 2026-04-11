# Tintify

一键统一所有终端 CLI 工具的配色主题。

Tintify 是一个 macOS 菜单栏应用，可以同时切换 10 个终端工具的配色主题，内置 25 个精选主题。

## 功能

- **一键切换** — 菜单栏选择主题，10 个工具同时更新
- **25 个内置主题** — Catppuccin、Dracula、Nord、Gruvbox、Tokyo Night、Solarized、Monokai、One Dark、Rose Pine、Kanagawa、Everforest 等
- **3 个原创主题** — Neon City 赛博朋克系列
- **跟随系统外观** — 自动切换深色/浅色主题
- **快速回退** — 一键回到上一个主题
- **应用记录** — 每次切换的详细结果
- **备份还原** — 自动备份配置文件，可一键还原

## 支持的工具

| 工具 | 配置方式 |
|------|---------|
| [Ghostty](https://ghostty.org) | theme 配置行 |
| [Starship](https://starship.rs) | palette + 色板定义 |
| [bat](https://github.com/sharkdp/bat) | BAT_THEME 环境变量 |
| [fzf](https://github.com/junegunn/fzf) | FZF_DEFAULT_OPTS 颜色 |
| [delta](https://github.com/dandavison/delta) | git config syntax-theme |
| [eza](https://github.com/eza-community/eza) | YAML 主题文件 |
| [lazygit](https://github.com/jesseduffield/lazygit) | gui.theme YAML |
| [tmux](https://github.com/tmux/tmux) | 状态栏 + 边框颜色 |
| [Vim](https://www.vim.org) | 自动生成 colorscheme |
| zsh-syntax-highlighting | 跟随终端 ANSI |

## 安装

### Homebrew

```bash
brew tap notwin/tap
brew install --cask tintify
```

### 手动安装

从 [Releases](https://github.com/notwin/Tintify/releases) 下载最新的 `Tintify.dmg`，拖入应用程序文件夹。

### 从源码构建

```bash
git clone https://github.com/notwin/Tintify.git
cd Tintify
scripts/bundle.sh
open /Applications/Tintify.app
```

需要 macOS 14+ 和 Swift 5.9+。

## 使用

1. 启动 Tintify，菜单栏出现调色板图标
2. 点击图标，在分组子菜单中选择主题
3. 所有工具配置自动更新
4. 新终端窗口自动生效

## 主题预览

主题按四个分类组织：

- **热门推荐** — Catppuccin、Dracula、Solarized
- **经典永恒** — Monokai、One Dark/Light、Gruvbox、Nord
- **新锐之选** — Tokyo Night、Rose Pine、Kanagawa、Everforest
- **Tintify 原创** — Neon City 赛博朋克系列

## 开发

```bash
# 构建
swift build

# 测试
swift test

# 运行（开发模式）
swift build && .build/debug/Tintify

# 打包安装
scripts/bundle.sh
```

## 许可证

[MIT](LICENSE)
