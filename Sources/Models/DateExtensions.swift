// Sources/Models/DateExtensions.swift
import Foundation

extension Date {
    /// 友好的时间显示：刚刚、X 分钟前、今天 HH:mm、昨天 HH:mm、MM-dd HH:mm
    var friendlyString: String {
        let now = Date()
        let interval = now.timeIntervalSince(self)
        let formatter = DateFormatter()

        if interval < 60 {
            return "刚刚"
        } else if interval < 3600 {
            return "\(Int(interval / 60)) 分钟前"
        } else if Calendar.current.isDateInToday(self) {
            formatter.dateFormat = "'今天' HH:mm"
            return formatter.string(from: self)
        } else if Calendar.current.isDateInYesterday(self) {
            formatter.dateFormat = "'昨天' HH:mm"
            return formatter.string(from: self)
        } else {
            formatter.dateFormat = "MM-dd HH:mm"
            return formatter.string(from: self)
        }
    }
}
