import SwiftUI

struct CompletionScreen: View {
    let flow: LearnNowFlowState
    let onFinish: () -> Void
    let onOpenReviewBoard: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 26) {
                Spacer(minLength: 60)

                InsetCircle(size: 112) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(LearnNowPalette.color(for: .mint))
                }

                Text("课程通关！")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)

                SoftCard {
                    HStack {
                        CompletionStat(
                            icon: "flame.fill",
                            value: "\(flow.streakDays)",
                            title: "天连胜保持",
                            accent: .pink
                        )

                        Divider()
                            .frame(height: 48)
                            .overlay(LearnNowPalette.textMuted.opacity(0.25))

                        CompletionStat(
                            icon: "bolt.fill",
                            value: "+15",
                            title: "XP 经验值",
                            accent: .blue
                        )
                    }
                }

                InsetCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("已提炼 3 张记忆卡片", systemImage: "square.stack.3d.up")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        FlowLayout(items: flow.generatedReviewTags) { tag in
                            NeumorphicPill(text: tag, accent: .blue)
                        }

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(LearnNowPalette.color(for: .blue))
                            Text("智能调度系统已将考点放入你的明日复习池中。")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }
                    }
                }

                VStack(spacing: 16) {
                    FullWidthButton(title: "完成学习", accent: .blue, systemImage: "checkmark", action: onFinish)
                    FullWidthButton(title: "去复习看板看看", accent: nil, action: onOpenReviewBoard)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .accessibilityIdentifier("screen.completion")
    }
}

private struct CompletionStat: View {
    let icon: String
    let value: String
    let title: String
    let accent: LearnNowAccent

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                Text(value)
            }
            .font(.system(size: 26, weight: .black, design: .rounded))
            .foregroundStyle(LearnNowPalette.color(for: accent))

            Text(title)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(LearnNowPalette.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Completion") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        CompletionScreen(flow: .completionPreview, onFinish: {}, onOpenReviewBoard: {})
    }
}
