// Sources/Adapters/DeltaAdapter.swift
import Foundation

/// Adapter for delta (git diff viewer).
struct DeltaAdapter: ToolAdapter {
    let id: ToolID = .delta

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.gitconfig"
    }

    /// Set delta's syntax-theme via `git config --global`.
    ///
    /// Args:
    ///   theme: The theme to apply.
    ///   configPath: Ignored; delta uses git config commands.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["config", "--global", "delta.syntax-theme", theme.nameForTool(toolName)]
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw AdapterError.commandFailed(tool: toolName, status: process.terminationStatus)
        }
    }

    func detectInstalled() -> Bool {
        ToolDetection.findExecutable("delta")
    }
}

/// Errors that adapters can throw when external commands fail.
enum AdapterError: LocalizedError {
    case commandFailed(tool: String, status: Int32)

    var errorDescription: String? {
        switch self {
        case .commandFailed(let tool, let status):
            return "\(tool) command failed with exit code \(status)"
        }
    }
}
