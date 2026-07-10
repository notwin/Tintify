import Testing
@testable import Tintify

@Test func versionComparisonHandlesMultiDigitSegments() {
    #expect(UpdateManager.isNewer(remote: "1.10.0", current: "1.9.0"))
    #expect(!UpdateManager.isNewer(remote: "1.9.0", current: "1.10.0"))
    #expect(!UpdateManager.isNewer(remote: "1.8.0", current: "1.8.0"))
    #expect(UpdateManager.isNewer(remote: "2.0", current: "1.9.9"))
    #expect(!UpdateManager.isNewer(remote: "1.8", current: "1.8.0"))
}
