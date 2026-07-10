// Sources/Settings/TerminalPreview.swift
import SwiftUI

/// 主题卡的迷你终端预览：窗口圆点 + 胶囊渐变提示符 + ls 彩色文件名。
/// 结构与配色遵循设计稿「Tintify 主题模板 T1–T14」的 .term 卡片。
struct TerminalPreview: View {
    let theme: Theme

    /// 设计稿速查表的「ls 三色」（html / docx / pptx）。
    /// 未列出的主题回退 blue/green/pink——T1 暮紫同款取色手法。
    static let lsColorOverrides: [String: [String]] = [
        "catppuccin-mocha": ["#89b4fa", "#a6e3a1", "#f5c2e7"],
        "rose-pine": ["#9ccfd8", "#f6c177", "#eb6f92"],
        "tokyo-night": ["#7aa2f7", "#9ece6a", "#bb9af7"],
        "kanagawa-wave": ["#7e9cd8", "#98bb6c", "#dca561"],
        "nord": ["#88c0d0", "#a3be8c", "#b48ead"],
        "everforest-dark": ["#7fbbb3", "#a7c080", "#dbbc7f"],
        "gruvbox-dark": ["#83a598", "#b8bb26", "#fabd2f"],
        "rose-pine-dawn": ["#56949f", "#ea9d34", "#b4637a"],
        "synthwave-sunset": ["#36f9f6", "#72f1b8", "#fede5d"],
        "phosphor-green": ["#9ceb8b", "#5fce62", "#d6fbc4"],
        "ink-vermilion": ["#d8d2c4", "#e34234", "#97917f"],
        "jewel-tones": ["#7dd3fc", "#6ee7b7", "#f9a8d4"],
        "caramel": ["#ddbd94", "#c39566", "#f0e0cb"],
        "soda-pop": ["#d81159", "#0f8a6d", "#7048b6"],
    ]

    /// 五段胶囊的示意文字（dir → git → lang → docker → time）
    private static let segmentLabels = ["~/code", "main", "node", "docker", "♥ 14:32"]

    private var lsColors: [String] {
        Self.lsColorOverrides[theme.id]
            ?? [theme.palette.blue, theme.palette.green, theme.palette.pink]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            // 窗口圆点：渐变前三色
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: theme.promptSegments[i].color))
                        .frame(width: 6, height: 6)
                }
            }

            // 提示符胶囊 + ls 命令
            HStack(spacing: 6) {
                promptBar
                Text("ls")
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundStyle(Color(hex: theme.palette.text))
            }

            // ls 输出：三个彩色下划线文件名
            HStack(spacing: 7) {
                fileName(L("架构图.html"), hex: lsColors[0])
                fileName(L("计划书.docx"), hex: lsColors[1])
                fileName(L("PPT.pptx"), hex: lsColors[2])
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: theme.palette.base))
        .cornerRadius(6)
        .overlay(
            // 浅色底的卡片需要一圈发丝边界定预览窗（设计稿同款）
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(hex: theme.palette.text).opacity(theme.appearance == .light ? 0.15 : 0), lineWidth: 1)
        )
        .accessibilityHidden(true)
    }

    private var promptBar: some View {
        HStack(spacing: -5) {
            ForEach(Array(zip(Self.segmentLabels, theme.promptSegments).enumerated()), id: \.offset) { i, pair in
                let isLast = i == theme.promptSegments.count - 1
                Text(pair.0)
                    .font(.system(size: 6.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: pair.1.ink))
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.leading, i == 0 ? 7 : 5)
                    .padding(.trailing, isLast ? 7 : 9)
                    .frame(height: 14)
                    .background(
                        SegmentShape(isFirst: i == 0, isLast: isLast)
                            .fill(Color(hex: pair.1.color))
                    )
                    .zIndex(Double(theme.promptSegments.count - i))
            }
        }
    }

    private func fileName(_ name: String, hex: String) -> some View {
        Text(name)
            .underline()
            .font(.system(size: 7, design: .monospaced))
            .foregroundStyle(Color(hex: hex))
            .lineLimit(1)
    }
}

/// 胶囊分段形状：首段左圆帽，中间段右侧尖角（powerline 箭头），末段右圆帽。
struct SegmentShape: Shape {
    let isFirst: Bool
    let isLast: Bool

    func path(in rect: CGRect) -> Path {
        let tip: CGFloat = 5
        let r = rect.height / 2
        var p = Path()

        p.move(to: CGPoint(x: isFirst ? r : 0, y: 0))
        if isLast {
            p.addLine(to: CGPoint(x: rect.width - r, y: 0))
            p.addArc(
                center: CGPoint(x: rect.width - r, y: r), radius: r,
                startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false
            )
        } else {
            p.addLine(to: CGPoint(x: rect.width - tip, y: 0))
            p.addLine(to: CGPoint(x: rect.width, y: r))
            p.addLine(to: CGPoint(x: rect.width - tip, y: rect.height))
        }
        p.addLine(to: CGPoint(x: isFirst ? r : 0, y: rect.height))
        if isFirst {
            p.addArc(
                center: CGPoint(x: r, y: r), radius: r,
                startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false
            )
        }
        p.closeSubpath()
        return p
    }
}
