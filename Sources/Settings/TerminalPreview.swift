// Sources/Settings/TerminalPreview.swift
import SwiftUI

/// 主题卡的迷你终端预览：窗口圆点 + 胶囊渐变提示符 + ls 彩色文件名。
/// 结构与配色遵循设计稿「Tintify 主题模板 T1–T14」的 .term 卡片。
struct TerminalPreview: View {
    let theme: Theme
    var scale: CGFloat = 1
    var embedded: Bool = false

    /// 五段胶囊的示意文字（dir → git → lang → docker → time）
    private static let segmentLabels = ["~/code", "main", "node", "docker", "♥ 14:32"]

    /// 「ls 三色」与 eza 的 extensions 段共用 LsThemeColors，预览即现实
    private var lsColors: [String] {
        LsThemeColors.colors(for: theme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7 * scale) {
            HStack(spacing: 4 * scale) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: theme.promptSegments[i].color))
                        .frame(width: 6 * scale, height: 6 * scale)
                }
            }

            HStack(spacing: 6 * scale) {
                promptBar
                Text("ls")
                    .font(.system(size: 7 * scale, design: .monospaced))
                    .foregroundStyle(Color(hex: theme.palette.text))
            }

            HStack(spacing: 7 * scale) {
                fileName(L("架构图.html"), hex: lsColors[0])
                fileName(L("计划书.docx"), hex: lsColors[1])
                fileName(L("PPT.pptx"), hex: lsColors[2])
            }
        }
        .padding(.horizontal, 8 * scale)
        .padding(.vertical, 9 * scale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(embedded ? Color.clear : Color(hex: theme.palette.base))
        .cornerRadius(embedded ? 0 : 6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(
                    Color(hex: theme.palette.text)
                        .opacity(!embedded && theme.appearance == .light ? 0.15 : 0),
                    lineWidth: 1
                )
        )
        .accessibilityHidden(true)
    }

    private var promptBar: some View {
        HStack(spacing: -5 * scale) {
            ForEach(Array(zip(Self.segmentLabels, theme.promptSegments).enumerated()), id: \.offset) { i, pair in
                let isLast = i == theme.promptSegments.count - 1
                Text(pair.0)
                    .font(.system(size: 6.5 * scale, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: pair.1.ink))
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.leading, (i == 0 ? 7 : 5) * scale)
                    .padding(.trailing, (isLast ? 7 : 9) * scale)
                    .frame(height: 14 * scale)
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
            .font(.system(size: 7 * scale, design: .monospaced))
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
