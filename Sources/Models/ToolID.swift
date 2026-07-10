/// 全部受支持工具的稳定标识。rawValue 即持久化键（disabledTools/toolPaths/toolNames 的字符串）。
enum ToolID: String, CaseIterable, Codable {
    case ghostty, starship, bat, fzf, delta, eza, lazygit
    case zshSyntaxHighlighting = "zsh-syntax-highlighting"
    case tmux, vim, wezterm, otty

    /// 官方大小写显示名（AboutPane 等 UI 用）。
    var displayName: String {
        switch self {
        case .ghostty: "Ghostty"
        case .starship: "Starship"
        case .bat: "bat"
        case .fzf: "fzf"
        case .delta: "delta"
        case .eza: "eza"
        case .lazygit: "lazygit"
        case .zshSyntaxHighlighting: "zsh-syntax-highlighting"
        case .tmux: "tmux"
        case .vim: "Vim"
        case .wezterm: "WezTerm"
        case .otty: "otty"
        }
    }
}
