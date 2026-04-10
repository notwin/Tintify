// Sources/Settings/BackupPane.swift

import SwiftUI

/// Backup management pane listing snapshots with one-click restore.
struct BackupPane: View {
    @State private var backups: [BackupInfo] = []
    @State private var showRestoreAlert = false
    @State private var selectedBackup: BackupInfo?
    private let manager = BackupManager()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Image(systemName: "externaldrive")
                        .font(.system(size: 36))
                        .foregroundStyle(.green)
                    Text("备份")
                        .font(.title2.bold())
                    Text("应用主题前自动备份，可一键还原")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)

                if backups.isEmpty {
                    Text("暂无备份")
                        .foregroundStyle(.secondary)
                        .padding(40)
                } else {
                    GroupBox {
                        VStack(spacing: 0) {
                            ForEach(Array(backups.enumerated()), id: \.element.id) { idx, backup in
                                if idx > 0 { Divider() }
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(backup.id).font(.body.monospaced())
                                        Text(backup.date.formatted())
                                            .font(.caption)
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
            }
            .padding(24)
        }
        .onAppear { backups = manager.listBackups() }
        .alert("确认还原？", isPresented: $showRestoreAlert) {
            Button("取消", role: .cancel) {}
            Button("还原", role: .destructive) {
                if let backup = selectedBackup {
                    try? manager.restore(backupId: backup.id)
                }
            }
        } message: {
            Text("将用备份替换当前配置文件，此操作不可撤销。")
        }
    }
}
