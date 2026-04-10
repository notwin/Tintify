// Sources/Settings/ResultsPane.swift
import SwiftUI

/// Pane displaying theme application history with per-tool details.
struct ResultsPane: View {
    private let history = NotificationManager.shared.history

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Image(systemName: "list.clipboard")
                        .font(.system(size: 36))
                        .foregroundStyle(.orange)
                    Text("应用记录")
                        .font(.title2.bold())
                    Text("查看每次主题切换的详细结果")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)

                if history.isEmpty {
                    Text("暂无应用记录")
                        .foregroundStyle(.secondary)
                        .padding(40)
                } else {
                    ForEach(Array(history.enumerated()), id: \.element.id) { idx, result in
                        ResultCard(result: result, isExpanded: idx == 0)
                    }
                }
            }
            .padding(24)
        }
    }
}

/// A single apply result card with expandable tool details.
struct ResultCard: View {
    let result: ApplyResult
    @State var isExpanded: Bool

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.theme.name)
                            .font(.headline)
                        Text(result.timestamp.formatted(date: .abbreviated, time: .standard))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(result.summary)
                        .font(.caption.bold())
                        .foregroundStyle(result.failedCount > 0 ? .red : .green)
                    Button {
                        withAnimation { isExpanded.toggle() }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .buttonStyle(.plain)
                }

                if isExpanded {
                    Divider()
                    ForEach(result.toolResults) { toolResult in
                        HStack(spacing: 8) {
                            Image(systemName: statusIcon(toolResult.status))
                                .foregroundStyle(statusColor(toolResult.status))
                                .frame(width: 16)
                            Text(toolResult.toolName)
                                .font(.body.monospaced())
                            Spacer()
                            if let message = toolResult.message {
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            } else {
                                Text(toolResult.configPath)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .padding(4)
        }
    }

    private func statusIcon(_ status: ToolStatus) -> String {
        switch status {
        case .success: return "checkmark.circle.fill"
        case .skipped: return "minus.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }

    private func statusColor(_ status: ToolStatus) -> Color {
        switch status {
        case .success: return .green
        case .skipped: return .orange
        case .failed: return .red
        }
    }
}
