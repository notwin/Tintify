// Sources/Settings/SettingsView.swift

import SwiftUI
import AppKit

/// Sidebar tabs for the settings window.
enum SettingsTab: String, CaseIterable, Identifiable {
    case general, tools, themes, results, backup, about

    var id: String { rawValue }

    /// UI 显示名。
    var displayName: String {
        switch self {
        case .general: L("通用")
        case .tools: L("工具")
        case .themes: L("主题")
        case .results: L("应用记录")
        case .backup: L("备份")
        case .about: L("关于")
        }
    }

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

/// 主设置窗口：自绘侧边栏 + 换肤内容区（「主题即界面」）。
struct SettingsView: View {
    @EnvironmentObject var skinModel: SkinModel
    @State private var selectedTab: SettingsTab = .general
    @State private var escMonitor: Any?

    var body: some View {
        let skin = skinModel.skin
        HStack(spacing: 0) {
            SidebarView(selectedTab: $selectedTab)
            detail
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(skin.windowBgColor)
        .background(WindowSkinApplier(skin: skin))
        .frame(minWidth: 760, minHeight: 560)
        .animation(.easeInOut(duration: 0.2), value: skin)
        .onChange(of: selectedTab) { _ in
            // 离开主题页（或任何切页）即取消试穿
            skinModel.previewTheme = nil
        }
        .onAppear {
            escMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53, skinModel.previewTheme != nil {  // 53 = Esc
                    skinModel.previewTheme = nil
                    return nil
                }
                return event
            }
        }
        .onDisappear {
            if let monitor = escMonitor {
                NSEvent.removeMonitor(monitor)
                escMonitor = nil
            }
            skinModel.previewTheme = nil
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch selectedTab {
        case .general: GeneralPane()
        case .tools: ToolsPane()
        case .themes: ThemesPane()
        case .results: ResultsPane()
        case .backup: BackupPane()
        case .about: AboutPane()
        }
    }
}
