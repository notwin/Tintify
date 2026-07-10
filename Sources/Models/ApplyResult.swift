// Sources/Models/ApplyResult.swift
import Foundation

/// Status of a single tool's theme application.
enum ToolStatus: String, Codable, Sendable {
    case success
    case skipped
    case failed
}

/// Result of applying a theme to a single tool adapter.
struct ToolResult: Identifiable, Codable {
    var id = UUID()
    let toolName: String
    let status: ToolStatus
    let message: String?
    let configPath: String

    enum CodingKeys: String, CodingKey { case toolName, status, message, configPath }
}

/// Aggregate result of applying a theme across all tool adapters.
struct ApplyResult: Identifiable, Codable {
    var id = UUID()
    let theme: Theme
    let timestamp: Date
    let toolResults: [ToolResult]
    let backupId: String?

    enum CodingKeys: String, CodingKey { case theme, timestamp, toolResults, backupId }

    init(theme: Theme, timestamp: Date, toolResults: [ToolResult], backupId: String? = nil) {
        self.theme = theme
        self.timestamp = timestamp
        self.toolResults = toolResults
        self.backupId = backupId
    }

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
        if successCount > 0 { parts.append(L("\(successCount) 成功")) }
        if skippedCount > 0 { parts.append(L("\(skippedCount) 跳过")) }
        if failedCount > 0 { parts.append(L("\(failedCount) 失败")) }
        return parts.joined(separator: ", ")
    }
}
