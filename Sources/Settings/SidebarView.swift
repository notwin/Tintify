// Sources/Settings/SidebarView.swift
import SwiftUI

/// 自绘侧边栏：染 sidebarBg，选中项 accent 底 + accentInk 字。
struct SidebarView: View {
    @EnvironmentObject var skinModel: SkinModel
    @Binding var selectedTab: SettingsTab

    var body: some View {
        let skin = skinModel.skin
        VStack(alignment: .leading, spacing: 3) {
            Text("Tintify")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(skin.textPrimaryColor)
                .padding(.horizontal, 12)
                .padding(.top, 38)   // 透明标题栏让位（红绿灯在上方）
                .padding(.bottom, 14)

            ForEach(SettingsTab.allCases) { tab in
                let isSelected = tab == selectedTab
                HStack(spacing: 7) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 11))
                        .frame(width: 15)
                    Text(tab.displayName)
                        .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                }
                .foregroundStyle(isSelected ? skin.accentInkColor : skin.textSecondaryColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isSelected ? skin.accentColor : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .contentShape(Rectangle())
                .onTapGesture { selectedTab = tab }
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(width: 172)
        .frame(maxHeight: .infinity)
        .background(skin.sidebarBgColor)
    }
}
