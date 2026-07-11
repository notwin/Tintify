// Sources/Settings/ToolsPane.swift

import SwiftUI

/// Tools pane for customizing per-tool configuration file paths.
struct ToolsPane: View {
    @EnvironmentObject var skinModel: SkinModel
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        let skin = skinModel.skin
        ScrollView {
            VStack(spacing: 16) {
                PaneHeader(icon: "wrench.and.screwdriver", title: L("工具"), subtitle: L("配置文件路径（留空使用默认路径）"))

                SkinCard {
                    VStack(spacing: 0) {
                        ForEach(Array(ThemeEngine.allAdapters.enumerated()), id: \.offset) { idx, adapter in
                            if idx > 0 { SkinDivider() }
                            HStack(spacing: 12) {
                                Toggle("", isOn: Binding(
                                    get: { !settings.disabledTools.contains(adapter.toolName) },
                                    set: { enabled in
                                        if enabled {
                                            settings.disabledTools.remove(adapter.toolName)
                                        } else {
                                            settings.disabledTools.insert(adapter.toolName)
                                        }
                                    }
                                ))
                                .toggleStyle(SkinToggleStyle(skin: skin))
                                .labelsHidden()

                                VStack(alignment: .leading) {
                                    Text(adapter.toolName).font(.body.bold())
                                        .foregroundStyle(skin.textPrimaryColor)
                                    Text(adapter.defaultPathDescription).font(.caption).foregroundStyle(skin.textSecondaryColor)
                                }
                                .opacity(settings.disabledTools.contains(adapter.toolName) ? 0.4 : 1.0)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    TextField(L("留空使用默认路径"), text: Binding(
                                        get: { settings.toolPaths[adapter.toolName] ?? "" },
                                        set: { val in
                                            if val.isEmpty {
                                                settings.toolPaths.removeValue(forKey: adapter.toolName)
                                            } else {
                                                settings.toolPaths[adapter.toolName] = val
                                            }
                                        }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    .tint(skin.accentColor)
                                    .frame(width: 200)
                                    .disabled(settings.disabledTools.contains(adapter.toolName))

                                    if let customPath = settings.toolPaths[adapter.toolName],
                                       !customPath.isEmpty,
                                       !FileManager.default.fileExists(atPath: (customPath as NSString).expandingTildeInPath) {
                                        Label(L("路径不存在"), systemImage: "exclamationmark.triangle.fill")
                                            .font(.caption2)
                                            .foregroundStyle(skin.dangerColor)
                                    }
                                }
                                .opacity(settings.disabledTools.contains(adapter.toolName) ? 0.4 : 1.0)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}
