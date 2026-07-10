import os

/// 统一日志入口。Console.app 里按 subsystem "com.notwin.Tintify" 过滤。
enum Log {
    static let engine = Logger(subsystem: "com.notwin.Tintify", category: "engine")
    static let adapter = Logger(subsystem: "com.notwin.Tintify", category: "adapter")
    static let update = Logger(subsystem: "com.notwin.Tintify", category: "update")
    static let history = Logger(subsystem: "com.notwin.Tintify", category: "history")
}
