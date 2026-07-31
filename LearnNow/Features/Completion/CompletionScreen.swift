import SwiftUI

struct CompletionScreen: View {
    let model: CompletionScreenModel
    let isActive: Bool
    let onContinueLearning: () -> Void
    let onFinish: () -> Void
    let onOpenReviewBoard: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.learnNowAnimationsEnabled) private var animationsEnabled
    @Environment(\.learnNowReduceMotionOverride) private var reduceMotionOverride
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var isHeroPresented = false
    @State private var isSymbolPresented = false
    @State private var revealedSectionCount = 0

    var body: some View {
        ScreenScaffold(spacing: 26) {
            Spacer(minLength: 60)

            CompletionHero(
                isPresented: displayedHeroIsPresented,
                isSymbolPresented: displayedSymbolIsPresented,
                usesDrawOn: usesFullMotion,
                showsGlow: !reduceTransparency
            )
            .frame(maxWidth: .infinity)

            Text(model.title)
                .font(LearnNowTypography.screenTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)
                .frame(maxWidth: .infinity)
                .completionReveal(
                    isVisible: displayedSectionCount >= 1,
                    usesMotion: usesFullMotion
                )
                .accessibilityAddTraits(.isHeader)

            SoftCard {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: 16) {
                        streakStat
                        Divider()
                            .overlay(LearnNowPalette.textMuted.opacity(0.25))
                        experienceStat
                    }
                } else {
                    HStack {
                        streakStat

                        Divider()
                            .frame(height: 48)
                            .overlay(LearnNowPalette.textMuted.opacity(0.25))

                        experienceStat
                    }
                }
            }
            .completionReveal(
                isVisible: displayedSectionCount >= 2,
                usesMotion: usesFullMotion
            )

            InsetCard {
                VStack(alignment: .leading, spacing: 16) {
                    Label("已提炼 \(model.reviewCount) 张记忆卡片", systemImage: "square.stack.3d.up")
                        .font(LearnNowTypography.cardTitle)
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    FlowLayout(items: model.reviewTags) { tag in
                        MetadataChip(text: tag, accent: .blue)
                    }

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(LearnNowPalette.color(for: .blue))

                        Text(model.reviewMessage)
                            .font(LearnNowTypography.body)
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }
            }
            .completionReveal(
                isVisible: displayedSectionCount >= 3,
                usesMotion: usesFullMotion
            )

            CompletionActionGroup(
                nextLessonTitle: model.nextLessonTitle,
                showsReviewAction: model.showsReviewAction,
                onContinueLearning: onContinueLearning,
                onFinish: onFinish,
                onOpenReviewBoard: onOpenReviewBoard
            )
            .completionReveal(
                isVisible: displayedSectionCount >= 4,
                usesMotion: usesFullMotion
            )
        }
        .accessibilityIdentifier("screen.completion")
        .task(id: isActive) {
            await updateCelebrationState()
        }
        .sensoryFeedback(.success, trigger: isActive) { oldValue, newValue in
            animationsEnabled && !oldValue && newValue
        }
    }

    private var streakStat: some View {
        CompletionStat(
            icon: "flame.fill",
            value: "\(model.streakDays)",
            title: "天连胜保持",
            role: .brand
        )
    }

    private var experienceStat: some View {
        CompletionStat(
            icon: "bolt.fill",
            value: model.gainedXPText,
            title: "XP 经验值",
            role: .brand
        )
    }

    private var usesFullMotion: Bool {
        animationsEnabled && !usesReducedMotion
    }

    private var usesReducedMotion: Bool {
        reduceMotionOverride ?? reduceMotion
    }

    private var displayedHeroIsPresented: Bool {
        animationsEnabled ? isHeroPresented : true
    }

    private var displayedSymbolIsPresented: Bool {
        animationsEnabled ? isSymbolPresented : true
    }

    private var displayedSectionCount: Int {
        animationsEnabled ? revealedSectionCount : 4
    }

    @MainActor
    private func updateCelebrationState() async {
        guard isActive else {
            prepareForCelebration()
            return
        }

        guard animationsEnabled else {
            settleCelebration()
            return
        }

        prepareForCelebration()
        await Task.yield()

        guard !Task.isCancelled, isActive else { return }

        if usesReducedMotion {
            withAnimation(.easeOut(duration: 0.18)) {
                settleCelebration()
            }
            return
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
            isHeroPresented = true
            isSymbolPresented = true
        }

        do {
            for section in 1...4 {
                try await Task.sleep(for: .milliseconds(80))
                guard !Task.isCancelled, isActive else { return }

                withAnimation(.easeOut(duration: 0.28)) {
                    revealedSectionCount = section
                }
            }
        } catch is CancellationError {
            return
        } catch {
            return
        }
    }

    @MainActor
    private func prepareForCelebration() {
        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            isHeroPresented = false
            isSymbolPresented = false
            revealedSectionCount = 0
        }
    }

    @MainActor
    private func settleCelebration() {
        isHeroPresented = true
        isSymbolPresented = true
        revealedSectionCount = 4
    }
}

private struct CompletionHero: View {
    let isPresented: Bool
    let isSymbolPresented: Bool
    let usesDrawOn: Bool
    let showsGlow: Bool

    var body: some View {
        AchievementSymbolBadge(
            size: 104,
            role: .brand,
            glowSize: 132,
            glowOpacity: 0.18,
            glowBlur: 18,
            strokeOpacity: 0.38,
            strokeWidth: 1.25,
            showsGlow: showsGlow
        ) {
            symbol
        }
        .scaleEffect(usesDrawOn ? (isPresented ? 1 : 0.86) : 1)
        .opacity(isPresented ? 1 : 0)
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var symbol: some View {
        if usesDrawOn {
            if isSymbolPresented {
                completionSymbol
                    .transition(.opacity.combined(with: .scale(scale: 0.86)))
            }
        } else {
            completionSymbol
                .opacity(isSymbolPresented ? 1 : 0)
        }
    }

    private var completionSymbol: some View {
        Image(systemName: "checkmark.seal.fill")
            .font(.largeTitle.weight(.semibold))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(LearnNowSemanticRole.brand.foreground)
    }
}

private struct CompletionActionGroup: View {
    let nextLessonTitle: String?
    let showsReviewAction: Bool
    let onContinueLearning: () -> Void
    let onFinish: () -> Void
    let onOpenReviewBoard: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 14) {
            if let nextLessonTitle {
                actionRow(nextLessonTitle: nextLessonTitle)
            } else {
                CompletionFinishCTAButton(
                    title: "完成学习",
                    isPrimary: true,
                    action: onFinish
                )
                .accessibilityIdentifier("completion.cta.finish")
            }

            if showsReviewAction {
                Button(action: onOpenReviewBoard) {
                    HStack(spacing: 6) {
                        Text("去复习看板看看")

                        Image(systemName: "chevron.forward")
                            .font(.caption.weight(.bold))
                            .accessibilityHidden(true)
                    }
                    .font(LearnNowTypography.label)
                    .foregroundStyle(LearnNowPalette.textMuted)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("completion.cta.review")
            }
        }
    }

    @ViewBuilder
    private func actionRow(nextLessonTitle: String) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: 12) {
                nextLessonButton(nextLessonTitle: nextLessonTitle)

                CompletionFinishCTAButton(
                    title: "完成学习",
                    isPrimary: false,
                    action: onFinish
                )
                .accessibilityIdentifier("completion.cta.finish")
            }
        } else {
            HStack(spacing: 12) {
                nextLessonButton(nextLessonTitle: nextLessonTitle)
                    .frame(maxWidth: .infinity)

                CompletionSecondaryCTAButton(
                    title: "完成学习",
                    action: onFinish
                )
                .frame(minWidth: 104, maxWidth: 140)
                .accessibilityIdentifier("completion.cta.finish")
            }
        }
    }

    private func nextLessonButton(nextLessonTitle: String) -> some View {
        CompletionPrimaryCTAButton(
            title: "学习下一章节",
            subtitle: nextLessonTitle,
            action: onContinueLearning
        )
        .accessibilityIdentifier("completion.cta.next")
    }
}

private struct CompletionStat: View {
    let icon: String
    let value: String
    let title: String
    let role: LearnNowSemanticRole

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                Text(value)
            }
            .font(LearnNowTypography.metricValue)
            .foregroundStyle(role.foreground)

            Text(title)
                .font(LearnNowTypography.label)
                .foregroundStyle(LearnNowPalette.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CompletionPrimaryCTAButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(LearnNowTypography.cardTitle)

                    Text(subtitle)
                        .font(LearnNowTypography.screenSubtitle)
                        .foregroundStyle(LearnNowPalette.textMuted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                ZStack {
                    Circle()
                        .fill(LearnNowSemanticRole.brand.foreground.opacity(0.12))

                    Image(systemName: "chevron.forward")
                        .font(.subheadline.weight(.bold))
                }
                .frame(width: 32, height: 32)
                .overlay {
                    Circle()
                        .stroke(
                            LearnNowSemanticRole.brand.foreground.opacity(0.18),
                            lineWidth: 1
                        )
                }
                .accessibilityHidden(true)
            }
            .foregroundStyle(LearnNowSemanticRole.brand.foreground)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
        }
        .buttonStyle(SoftPressStyle(cornerRadius: 22))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(subtitle)
        .accessibilityHint("打开下一章节")
    }
}

private struct CompletionSecondaryCTAButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LearnNowTypography.label)
                .multilineTextAlignment(.center)
                .foregroundStyle(LearnNowPalette.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 14)
        }
        .buttonStyle(SoftPressStyle(cornerRadius: 22))
        .accessibilityLabel(title)
        .accessibilityHint("返回学习路径")
    }
}

private struct CompletionFinishCTAButton: View {
    let title: String
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LearnNowTypography.cardTitle)
                .foregroundStyle(
                    isPrimary
                        ? LearnNowSemanticRole.brand.foreground
                        : LearnNowPalette.textPrimary
                )
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
        }
        .buttonStyle(SoftPressStyle(cornerRadius: isPrimary ? 999 : 22))
        .accessibilityLabel(title)
        .accessibilityHint("返回学习路径")
    }
}

private extension View {
    func completionReveal(isVisible: Bool, usesMotion: Bool) -> some View {
        opacity(isVisible ? 1 : 0)
            .offset(y: usesMotion && !isVisible ? 12 : 0)
    }
}

private extension CompletionScreenModel {
    var finalChapterPreview: Self {
        CompletionScreenModel(
            title: title,
            streakDays: streakDays,
            gainedXPText: gainedXPText,
            reviewCount: reviewCount,
            reviewTags: reviewTags,
            reviewMessage: reviewMessage,
            nextLessonTitle: nil,
            showsReviewAction: showsReviewAction
        )
    }
}

private struct CompletionPreviewSurface: View {
    let model: CompletionScreenModel
    var animationsEnabled = true

    var body: some View {
        ZStack {
            LearnNowPalette.canvas.ignoresSafeArea()
            CompletionScreen(
                model: model,
                isActive: true,
                onContinueLearning: {},
                onFinish: {},
                onOpenReviewBoard: {}
            )
        }
        .environment(\.learnNowAnimationsEnabled, animationsEnabled)
    }
}

#Preview("Completion · Animated") {
    CompletionPreviewSurface(
        model: LearnNowFlowState.completionPreview.completionScreenModel
    )
}

#Preview("Completion · Reduce Motion") {
    CompletionPreviewSurface(
        model: LearnNowFlowState.completionPreview.completionScreenModel
    )
    .environment(\.learnNowReduceMotionOverride, true)
}

#Preview("Completion · Accessibility Type") {
    CompletionPreviewSurface(
        model: LearnNowFlowState.completionPreview.completionScreenModel,
        animationsEnabled: false
    )
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("Completion · Final Chapter") {
    CompletionPreviewSurface(
        model: LearnNowFlowState.completionPreview.completionScreenModel.finalChapterPreview,
        animationsEnabled: false
    )
}
