// Sources/Models/ApplyResult.swift
import Foundation

/// Status of a single tool's theme application.
enum ToolStatus: String, Codable {
    case success
    case skipped
    case failed
}

/// Result of applying a theme to a single tool adapter.
struct ToolResult: Identifiable {
    let id = UUID()
    let toolName: String
    let status: ToolStatus
    let message: String?
    let configPath: String
}

/// Aggregate result of applying a theme across all tool adapters.
struct ApplyResult: Identifiable {
    let id = UUID()
    let theme: Theme
    let timestamp: Date
    let toolResults: [ToolResult]

    var successCount: Int {
        toolResults.filter { $0.status == .success }.count
    }

    var failedCount: Int {
        toolResults.filter { $0.status == .failed }.count
    }

    var skippedCount: Int {
        toolResults.filter { $0.status == .skipped }.count
    }

    var summary: String {
        var parts: [String] = []
        if successCount > 0 { parts.append("\(successCount) 成功") }
        if skippedCount > 0 { parts.append("\(skippedCount) 跳过") }
        if failedCount > 0 { parts.append("\(failedCount) 失败") }
        return parts.joined(separator: ", ")
    }
}
