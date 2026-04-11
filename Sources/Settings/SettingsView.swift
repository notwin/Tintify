// Sources/Settings/SettingsView.swift

import SwiftUI

/// Sidebar tabs for the settings window.
enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "通用"
    case tools = "工具"
    case themes = "主题"
    case results = "应用记录"
    case backup = "备份"
    case about = "关于"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general: return "paintpalette"
        case .tools: return "wrench.and.screwdriver"
        case .themes: return "theatermasks"
        case .results: return "list.clipboard"
        case .backup: return "externaldrive"
        case .about: return "info.circle"
        }
    }
}

/// Main settings window using NavigationSplitView with a sidebar and detail pane.
struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        NavigationSplitView {
            List(SettingsTab.allCases, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            switch selectedTab {
            case .general: GeneralPane()
            case .tools: ToolsPane()
            case .themes: ThemesPane()
            case .results: ResultsPane()
            case .backup: BackupPane()
            case .about: AboutPane()
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}
