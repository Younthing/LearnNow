import SwiftUI

struct HomeScreen: View {
    let flow: LearnNowFlowState
    let onContinueLearning: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                ScreenHeader(
                    title: "学习概览",
                    subtitle: flow.todayLabel,
                    trailing: { AvatarBadge() }
                )

                SoftCard {
                    HStack(alignment: .center, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("绝佳状态")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textPrimary)
                            Text("累计获得 \(flow.totalXP) XP")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }

                        Spacer()

                        InsetCircle(size: 72) {
                            VStack(spacing: 2) {
                                Text("\(flow.streakDays)")
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.color(for: .pink))
                                Text("天连胜")
                                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.textMuted)
                            }
                        }
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(flow.homeMetrics) { metric in
                        InsetCard {
                            VStack(spacing: 10) {
                                Text(metric.title)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.textMuted)

                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text(metric.value)
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundStyle(LearnNowPalette.color(for: metric.accent))
                                    if let unit = metric.unit {
                                        Text(unit)
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundStyle(LearnNowPalette.textMuted)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }

                sectionTitle("继续学习")

                SoftCard(contentPadding: 20) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                NeumorphicPill(text: "第3单元 · 课时4", accent: .blue)
                                Text("假设检验：均值比较")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.textPrimary)
                            }

                            Spacer()

                            CircleIconButton(
                                systemImage: "play.fill",
                                accent: .blue,
                                action: onContinueLearning
                            )
                        }

                        ProgressTrack(progress: 0.40, accent: .blue, height: 12)

                        HStack {
                            Spacer()
                            Text("完成 40%")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }
                    }
                }

                SoftCard(contentPadding: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("本月学习记录")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }

                        HeatmapGrid(cells: flow.heatmap)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .accessibilityIdentifier("screen.home")
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .heavy, design: .rounded))
            .foregroundStyle(LearnNowPalette.textPrimary)
    }
}

private struct AvatarBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [LearnNowPalette.color(for: .blue), LearnNowPalette.color(for: .purple)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 52, height: 52)
                .softOuter(radius: 8, x: 4, y: 4)

            Image(systemName: "person.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white.opacity(0.95))
        }
    }
}

private struct HeatmapGrid: View {
    let cells: [LearnNowHeatCell]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(cells) { cell in
                if cell.level == 0 {
                    Circle()
                        .fill(fillColor(for: cell.level))
                        .frame(height: 22)
                        .opacity(cell.level == nil ? 0 : 1)
                        .modifier(OuterSurface(cornerRadius: 11))
                } else {
                    Circle()
                        .fill(fillColor(for: cell.level))
                        .frame(height: 22)
                        .opacity(cell.level == nil ? 0 : 1)
                        .modifier(InsetSurface(cornerRadius: 11))
                }
            }
        }
    }

    private func fillColor(for level: Int?) -> Color {
        switch level {
        case nil:
            .clear
        case 0:
            LearnNowPalette.base
        case 1:
            LearnNowPalette.color(for: .mint)
        case 2:
            LearnNowPalette.color(for: .blue)
        default:
            LearnNowPalette.color(for: .pink)
        }
    }
}

#Preview("Home") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        HomeScreen(flow: .homePreview, onContinueLearning: {})
    }
}
