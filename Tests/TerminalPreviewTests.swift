import Testing
import Foundation
@testable import Tintify

@Test func lsColorOverridesReferenceValidThemes() {
    for (id, colors) in LsThemeColors.overrides {
        #expect(ThemeRegistry.shared.theme(id: id) != nil, "未知主题 id: \(id)")
        #expect(colors.count == 3, "\(id) 的 ls 三色数量不对")
        for hex in colors {
            let isValid = hex.count == 7 && hex.hasPrefix("#")
                && hex.dropFirst().allSatisfy(\.isHexDigit)
            #expect(isValid, "\(id) 含非法 hex: \(hex)")
        }
    }
}

@Test func lsColorFallbackCoversAllThemes() {
    // 没有专属 ls 三色的主题回退 blue/green/pink，全部主题都要能取到 3 个合法色
    for theme in ThemeRegistry.shared.allThemes {
        #expect(LsThemeColors.colors(for: theme).count == 3)
    }
}
