// Sources/Adapters/TmuxAdapter.swift
import Foundation

/// Adapter for tmux terminal multiplexer.
struct TmuxAdapter: ToolAdapter {
    let toolName = "tmux"

    var defaultConfigPath: String {
        NSHomeDirectory() + "/.tmux.conf"
    }

    /// Write tmux status bar and pane border colors into the Tintify marker block.
    func apply(theme: Theme, configPath: String? = nil) throws {
        let path = configPath ?? defaultConfigPath
        let p = theme.palette

        let tmuxLines = """
            set -g status-style 'fg=\(p.text),bg=\(p.mantle)'
            set -g status-left-style 'fg=\(p.base),bg=\(p.blue),bold'
            set -g status-right-style 'fg=\(p.text),bg=\(p.surface0)'
            set -g window-status-style 'fg=\(p.subtext0),bg=\(p.mantle)'
            set -g window-status-current-style 'fg=\(p.base),bg=\(p.blue),bold'
            set -g pane-border-style 'fg=\(p.surface0)'
            set -g pane-active-border-style 'fg=\(p.blue)'
            set -g message-style 'fg=\(p.text),bg=\(p.surface0)'
            set -g message-command-style 'fg=\(p.text),bg=\(p.surface0)'
            """

        try ConfigWriter.writeMarkerBlock(to: path, content: tmuxLines)
        reloadTmux(configPath: path)
    }

    private func reloadTmux(configPath: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["tmux", "source-file", configPath]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus != 0 {
                NSLog("[Tintify] tmux reload failed with exit code \(process.terminationStatus)")
            }
        } catch {
            // tmux not running — expected, ignore
        }
    }
}
