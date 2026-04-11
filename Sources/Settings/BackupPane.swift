// Sources/Settings/BackupPane.swift

import SwiftUI

/// Backup management pane listing snapshots with one-click restore.
struct BackupPane: View {
    @State private var backups: [BackupInfo] = []
    @State private var showRestoreAlert = false
    @State private var selectedBackup: BackupInfo?
    @State private var restoreMessage: String?
    private let manager = BackupManager()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PaneHeader(icon: "externaldrive", color: .green, title: "备份", subtitle: "应用主题前自动备份，可一键还原")

                if backups.isEmpty {
                    EmptyStateView(
                        icon: "externaldrive",
                        title: "暂无备份",
                        subtitle: "切换主题时会自动创建备份"
                    )
                } else {
                    GroupBox {
                        VStack(spacing: 0) {
                            ForEach(Array(backups.enumerated()), id: \.element.id) { idx, backup in
                                if idx > 0 { Divider() }
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(backup.date.friendlyString)
                                            .font(.body)
                                        Text(backup.id)
                                            .font(.caption.monospaced())
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Button("还原") {
                                        selectedBackup = backup
                                        showRestoreAlert = true
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                            }
                        }
                    }
                }

                if let message = restoreMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(message.contains("成功") ? .green : .red)
                        .padding(.top, 4)
                }
            }
            .padding(24)
        }
        .onAppear { backups = manager.listBackups() }
        .alert("确认还原？", isPresented: $showRestoreAlert) {
            Button("取消", role: .cancel) {}
            Button("还原", role: .destructive) {
                if let backup = selectedBackup {
                    do {
                        try manager.restore(backupId: backup.id)
                        restoreMessage = "还原成功"
                    } catch {
                        restoreMessage = "还原失败：\(error.localizedDescription)"
                    }
                }
            }
        } message: {
            Text("将用备份替换当前配置文件，此操作不可撤销。")
        }
    }
}
