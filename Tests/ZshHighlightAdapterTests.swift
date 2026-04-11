import Testing
import Foundation
@testable import Tintify

@Test func zshHighlightAdapterToolName() {
    let adapter = ZshHighlightAdapter()
    #expect(adapter.toolName == "zsh-syntax-highlighting")
}

@Test func zshHighlightAdapterApplyDoesNotThrow() throws {
    let adapter = ZshHighlightAdapter()
    let theme = ThemeRegistry.shared.theme(id: "catppuccin-mocha")!
    try adapter.apply(theme: theme, configPath: nil)
}
