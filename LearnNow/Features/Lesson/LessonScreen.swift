import SwiftUI

struct LessonScreen: View {
    let model: LessonScreenModel
    let onBack: () -> Void
    let onSelectPage: (Int) -> Void
    let onAnswer: (String) -> Void
    let onCallToAction: (LearnNowLessonCallToAction) -> Void

    private var selectionBinding: Binding<Int> {
        Binding(
            get: { model.currentPageIndex },
            set: { onSelectPage($0) }
        )
    }

    var body: some View {
        VStack(spacing: 18) {
            LessonTopBar(title: model.title, onBack: onBack)

            LessonSegments(count: model.pageCount, currentIndex: model.currentPageIndex)
                .padding(.horizontal, LearnNowSpacing.screenHorizontal)

            TabView(selection: selectionBinding) {
                ForEach(Array(model.pages.enumerated()), id: \.element.id) { index, page in
                    LessonPageView(
                        page: page,
                        onAnswer: onAnswer,
                        onCallToAction: onCallToAction
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .accessibilityIdentifier("screen.lesson")
    }
}

private struct LessonTopBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack {
            CircleIconButton(systemImage: "arrow.left", accent: .blue, action: onBack)

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(LearnNowPalette.textPrimary)
                .accessibilityIdentifier("lesson.title")

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, LearnNowSpacing.screenHorizontal)
        .padding(.top, LearnNowSpacing.screenTop)
    }
}

private struct LessonSegments: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(LearnNowPalette.base)
                        .frame(height: index == currentIndex ? 7 : 6)
                        .softOuter(radius: 4, x: 2, y: 2)

                    Capsule()
                        .fill(LearnNowPalette.gradient(for: .blue))
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: index == currentIndex ? 7 : 6,
                            alignment: .leading
                        )
                        .opacity(index <= currentIndex ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct LessonPageView: View {
    let page: LessonScreenModel.Page
    let onAnswer: (String) -> Void
    let onCallToAction: (LearnNowLessonCallToAction) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                LessonHeroSection(page: page)
                LessonExplanationSection(page: page)
                LessonPracticeSection(
                    page: page,
                    onAnswer: onAnswer,
                    onCallToAction: onCallToAction
                )
            }
            .padding(.horizontal, LearnNowSpacing.screenHorizontal)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
    }
}

private struct LessonHeroSection: View {
    let page: LessonScreenModel.Page

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            NeumorphicPill(text: page.badge, accent: page.accent)

            Text(page.title)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(LearnNowPalette.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LessonExplanationSection: View {
    let page: LessonScreenModel.Page

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(page.summary)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(LearnNowPalette.textSecondary)
                .lineSpacing(6)

            CalloutCard(callout: page.callout)

            if let codeSample = page.codeSample {
                CodeSampleCard(code: codeSample)
            }
        }
    }
}

private struct LessonPracticeSection: View {
    let page: LessonScreenModel.Page
    let onAnswer: (String) -> Void
    let onCallToAction: (LearnNowLessonCallToAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("随堂练习", systemImage: "square.and.pencil")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(LearnNowPalette.textPrimary)

            Text(page.questionPrompt)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(LearnNowPalette.textSecondary)
                .lineSpacing(4)

            ForEach(page.options) { option in
                LessonOptionButton(option: option) {
                    onAnswer(option.id)
                }
                .accessibilityIdentifier("lesson.option.\(option.id)")
            }

            if let feedback = page.feedback {
                FeedbackCard(feedback: feedback)
            }

            if let action = page.callToAction {
                FullWidthButton(
                    title: action.title,
                    accent: action.accent,
                    action: { onCallToAction(action.kind) }
                )
                .accessibilityIdentifier("lesson.cta")
            }
        }
        .padding(.top, 10)
    }
}

private struct LessonOptionButton: View {
    let option: LessonScreenModel.Option
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                InsetCircle(size: 34) {
                    Text(option.badge)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textMuted)
                }

                Text(option.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(labelColor)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LearnNowPalette.base)
                    .softOuter(radius: 10, x: 5, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!option.isEnabled)
    }

    private var borderColor: Color {
        switch option.presentation {
        case .correct:
            LearnNowPalette.color(for: .mint)
        case .incorrect:
            LearnNowPalette.color(for: .pink)
        case .normal:
            .clear
        }
    }

    private var borderWidth: CGFloat {
        switch option.presentation {
        case .correct, .incorrect:
            2
        case .normal:
            0
        }
    }

    private var labelColor: Color {
        switch option.presentation {
        case .correct:
            LearnNowPalette.color(for: .mint)
        case .incorrect:
            LearnNowPalette.color(for: .pink)
        case .normal:
            LearnNowPalette.textSecondary
        }
    }
}

private struct FeedbackCard: View {
    let feedback: LearnNowLessonFeedback

    var body: some View {
        InsetCard(contentPadding: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(feedback.title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(LearnNowPalette.color(for: feedback.accent))

                Text(feedback.body)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textSecondary)
                    .lineSpacing(4)
            }
        }
    }
}

private struct CalloutCard: View {
    let callout: LessonScreenModel.Callout

    var body: some View {
        InsetCard(contentPadding: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: callout.accent == .amber ? "exclamationmark.triangle.fill" : "lightbulb.fill")

                    Text(callout.title)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                }
                .foregroundStyle(LearnNowPalette.color(for: callout.accent))

                Text(callout.message)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textSecondary)
                    .lineSpacing(4)
            }
        }
    }
}

private struct CodeSampleCard: View {
    let code: String

    var body: some View {
        InsetCard(contentPadding: 18) {
            Text(code)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(LearnNowPalette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview("Lesson") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        LessonScreen(
            model: LearnNowFlowState.lessonPreview.lessonScreenModel,
            onBack: {},
            onSelectPage: { _ in },
            onAnswer: { _ in },
            onCallToAction: { _ in }
        )
    }
}
