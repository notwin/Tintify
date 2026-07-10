// Sources/Models/DateExtensions.swift
import Foundation

extension Date {
    /// 相对时间描述（"3 分钟前"/"3 min ago"，随系统语言）。
    var friendlyString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
