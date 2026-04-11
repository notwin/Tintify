import Testing
import Foundation
@testable import Tintify

@Test func deltaAdapterToolName() {
    let adapter = DeltaAdapter()
    #expect(adapter.toolName == "delta")
}

@Test func deltaAdapterDefaultConfigPath() {
    let adapter = DeltaAdapter()
    #expect(adapter.defaultConfigPath.hasSuffix(".gitconfig"))
}
