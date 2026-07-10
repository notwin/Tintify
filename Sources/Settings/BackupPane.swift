// Sources/Settings/BackupPane.swift

import SwiftUI

/// Backup management pane listing snapshots with one-click restore.
struct BackupPane: View {
    @State private var backups: [BackupInfo] = []
    @State private var showRestoreAlert = false
    @State private var selectedBackup: BackupInfo?
    @State private var restoreMessage: String?
    @State private var restoreSucceeded = false
    private let manager = BackupManager()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PaneHeader(icon: "externaldrive", color: .green, title: L("备份"), subtitle: L("应用主题前自动备份，可一键还原"))

                if backups.isEmpty {
                    EmptyStateView(
                        icon: "externaldrive",
                        title: L("暂无备份"),
                        subtitle: L("切换主题时会自动创建备份")
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
                                    Button(L("还原")) {
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
                        .foregroundStyle(restoreSucceeded ? .green : .red)
                        .padding(.top, 4)
                }
            }
            .padding(24)
        }
        .onAppear { backups = manager.listBackups() }
        .alert(L("确认还原？"), isPresented: $showRestoreAlert) {
            Button(L("取消"), role: .cancel) {}
            Button(L("还原"), role: .destructive) {
                if let backup = selectedBackup {
                    do {
                        try manager.restore(backupId: backup.id)
                        restoreMessage = L("还原成功")
                        restoreSucceeded = true
                    } catch {
                        restoreMessage = L("还原失败：\(error.localizedDescription)")
                        restoreSucceeded = false
                    }
                }
            }
        } message: {
            Text(L("将用备份替换当前配置文件，此操作不可撤销。"))
        }
    }
}
