// Sources/Models/Localization.swift
import Foundation

/// 本地化入口：SPM 包的字符串资源在 Bundle.module，不能用默认的 Bundle.main。
func L(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: .module)
}
