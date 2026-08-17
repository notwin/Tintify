// Sources/Adapters/ToolAdapter.swift
import Foundation

/// Protocol that every CLI-tool adapter must conform to.
protocol ToolAdapter {
    /// 工具的稳定标识（rawValue 即持久化键）。
    var id: ToolID { get }

    /// Default config file path when the user has not overridden it.
    var defaultConfigPath: String { get }

    /// Apply the given theme, writing to `configPath` (or the default if nil).
    func apply(theme: Theme, configPath: String?) throws

    /// Return `true` if the tool appears to be installed.
    func detectInstalled() -> Bool
}

extension ToolAdapter {
    /// 持久化/日志用字符串标识——disabledTools、toolPaths、toolNames 的键。
    var toolName: String { id.rawValue }

    /// ToolsPane 显示用：home 前缀缩写为 ~。
    var defaultPathDescription: String {
        defaultConfigPath.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
}

/// 适配器共用的"通知运行中 app 重载"进程：fire-and-forget，
/// 静音 stdio、不阻塞 apply，非零退出或启动失败只记日志。
enum ReloadNotifier {
    static func fire(executable: String, arguments: [String], logPrefix: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        process.terminationHandler = { p in
            if p.terminationStatus != 0 {
                Log.adapter.info("\(logPrefix)：退出码 \(p.terminationStatus)（app 可能未运行）")
            }
        }
        do {
            try process.run()
        } catch {
            Log.adapter.info("\(logPrefix)：启动失败：\(error.localizedDescription)")
        }
    }
}

/// 工具安装检测的共享逻辑。GUI app 的 PATH 不含 Homebrew，用固定路径探测。
enum ToolDetection {
    static let binSearchPaths = ["/opt/homebrew/bin", "/usr/local/bin", "/usr/bin", "/bin"]

    static func findExecutable(_ name: String) -> Bool {
        executablePath(name) != nil
    }

    /// 返回可执行文件的完整路径（Process 需要绝对路径）。
    static func executablePath(_ name: String) -> String? {
        binSearchPaths
            .map { "\($0)/\(name)" }
            .first { FileManager.default.isExecutableFile(atPath: $0) }
    }
}
