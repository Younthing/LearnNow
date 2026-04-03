import SwiftUI

struct CompletionScreen: View {
    let flow: LearnNowFlowState
    let onContinueLearning: () -> Void
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
                        Label("已提炼 \(flow.generatedReviewCount) 张记忆卡片", systemImage: "square.stack.3d.up")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        FlowLayout(items: flow.generatedReviewTags) { tag in
                            NeumorphicPill(text: tag, accent: .blue)
                        }

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(LearnNowPalette.color(for: .blue))
                            Text(flow.completionReviewMessage)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }
                    }
                }

                CompletionActionGroup(
                    nextLessonTitle: flow.nextLessonTitle,
                    showsReviewAction: flow.generatedReviewCount > 0,
                    onContinueLearning: onContinueLearning,
                    onFinish: onFinish,
                    onOpenReviewBoard: onOpenReviewBoard
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .accessibilityIdentifier("screen.completion")
    }
}

private struct CompletionActionGroup: View {
    let nextLessonTitle: String?
    let showsReviewAction: Bool
    let onContinueLearning: () -> Void
    let onFinish: () -> Void
    let onOpenReviewBoard: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            if let nextLessonTitle {
                GeometryReader { proxy in
                    let spacing: CGFloat = 12
                    let primaryWidth = max((proxy.size.width - spacing) * 0.66, 0)
                    let secondaryWidth = max((proxy.size.width - spacing) * 0.34, 0)

                    HStack(spacing: spacing) {
                        CompletionPrimaryCTAButton(
                            title: "学习下一章节",
                            subtitle: nextLessonTitle,
                            systemImage: "arrow.right"
                        ) {
                            onContinueLearning()
                        }
                        .frame(width: primaryWidth)
                        .accessibilityIdentifier("completion.cta.next")

                        CompletionCompactCTAButton(
                            title: "完成学习",
                            systemImage: "checkmark"
                        ) {
                            onFinish()
                        }
                        .frame(width: secondaryWidth)
                        .accessibilityIdentifier("completion.cta.finish")
                    }
                }
                .frame(height: 74)
            } else {
                FullWidthButton(
                    title: "完成学习",
                    accent: .blue,
                    systemImage: "checkmark",
                    action: onFinish
                )
                .accessibilityIdentifier("completion.cta.finish")
            }

            if showsReviewAction {
                Button(action: onOpenReviewBoard) {
                    HStack(spacing: 6) {
                        Text("去复习看板看看")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textMuted)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("completion.cta.review")
            }
        }
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

private struct CompletionPrimaryCTAButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                    Text(subtitle)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Spacer(minLength: 0)

                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .black))
            }
            .foregroundStyle(LearnNowPalette.color(for: .blue))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
        }
        .buttonStyle(SoftPressStyle(cornerRadius: 22))
    }
}

private struct CompletionCompactCTAButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .black))
                Text(title)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(LearnNowPalette.textPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 14)
        }
        .buttonStyle(SoftPressStyle(cornerRadius: 22))
    }
}

#Preview("Completion") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        CompletionScreen(
            flow: .completionPreview,
            onContinueLearning: {},
            onFinish: {},
            onOpenReviewBoard: {}
        )
    }
}
