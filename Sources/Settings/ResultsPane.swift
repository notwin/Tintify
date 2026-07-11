// Sources/Settings/ResultsPane.swift
import SwiftUI

/// Pane displaying theme application history with per-tool details.
struct ResultsPane: View {
    @EnvironmentObject var skinModel: SkinModel
    @ObservedObject private var store = ApplyHistoryStore.shared
    private var history: [ApplyResult] {
        store.history
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PaneHeader(icon: "list.clipboard", title: L("应用记录"), subtitle: L("查看每次主题切换的详细结果"))

                if history.isEmpty {
                    EmptyStateView(
                        icon: "list.clipboard",
                        title: L("暂无应用记录"),
                        subtitle: L("切换主题后这里会显示详细结果")
                    )
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
    @EnvironmentObject var skinModel: SkinModel
    let result: ApplyResult
    @State var isExpanded: Bool

    var body: some View {
        SkinCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.theme.name)
                            .font(.headline)
                            .foregroundStyle(skinModel.skin.textPrimaryColor)
                        Text(result.timestamp.friendlyString)
                            .font(.caption)
                            .foregroundStyle(skinModel.skin.textSecondaryColor)
                    }
                    Spacer()
                    Text(result.summary)
                        .font(.caption.bold())
                        .foregroundStyle(result.failedCount > 0 ? skinModel.skin.dangerColor : skinModel.skin.successColor)
                    Button {
                        withAnimation { isExpanded.toggle() }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundStyle(skinModel.skin.textSecondaryColor)
                            .contentShape(Rectangle())
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                }

                if isExpanded {
                    SkinDivider()
                    ForEach(result.toolResults) { toolResult in
                        HStack(spacing: 8) {
                            Image(systemName: statusIcon(toolResult.status))
                                .foregroundStyle(statusColor(toolResult.status))
                                .frame(width: 16)
                            Text(toolResult.toolName)
                                .font(.body.monospaced())
                                .foregroundStyle(skinModel.skin.textPrimaryColor)
                            Spacer()
                            if let message = toolResult.message {
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(skinModel.skin.textSecondaryColor)
                                    .lineLimit(1)
                            } else {
                                Text(toolResult.configPath)
                                    .font(.caption)
                                    .foregroundStyle(skinModel.skin.textSecondaryColor)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .padding(10)
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
        case .success: return skinModel.skin.successColor
        case .skipped: return skinModel.skin.textSecondaryColor
        case .failed: return skinModel.skin.dangerColor
        }
    }
}
