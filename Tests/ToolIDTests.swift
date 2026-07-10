import Testing
import Foundation
@testable import Tintify

@Test func everyToolIDHasExactlyOneAdapter() {
    let adapters = ThemeEngine.allAdapters
    #expect(adapters.count == ToolID.allCases.count)
    #expect(Set(adapters.map(\.id)) == Set(ToolID.allCases))   // 防第 13 个工具漏注册
}

@Test func toolIDRawValuesAreStable() {
    // 持久化键快照——改 case 名会破坏用户已存的 disabledTools/toolPaths
    let expected = ["ghostty", "starship", "bat", "fzf", "delta", "eza", "lazygit",
                    "zsh-syntax-highlighting", "tmux", "vim", "wezterm", "otty"]
    #expect(ToolID.allCases.map(\.rawValue) == expected)
}

@Test func adapterToolNameMatchesRawValue() {
    for adapter in ThemeEngine.allAdapters {
        #expect(adapter.toolName == adapter.id.rawValue)
    }
}
