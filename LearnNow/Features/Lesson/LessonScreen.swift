import SwiftUI

struct LessonScreen: View {
    @Binding var flow: LearnNowFlowState

    private var selectionBinding: Binding<Int> {
        Binding(
            get: { flow.currentLessonPageIndex },
            set: { flow.currentLessonPageIndex = $0 }
        )
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                CircleIconButton(systemImage: "arrow.left", accent: .blue) {
                    flow.openPath()
                }

                Spacer()

                Text("假设检验")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)

                Spacer()

                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            LessonSegments(
                count: flow.lessonPages.count,
                currentIndex: flow.currentLessonPageIndex
            )
            .padding(.horizontal, 24)

            TabView(selection: selectionBinding) {
                ForEach(Array(flow.lessonPages.enumerated()), id: \.element.id) { index, page in
                    LessonPageScreen(
                        page: page,
                        feedback: LearnNowFlowState.feedback(for: page),
                        onAnswer: { optionID in
                            flow.answerCurrentLesson(with: optionID)
                        },
                        onCallToAction: {
                            switch page.callToAction {
                            case .retry:
                                flow.retryCurrentLessonQuestion()
                            case .nextPage:
                                flow.advanceLesson()
                            case .completeLesson:
                                flow.completeLesson()
                            case nil:
                                break
                            }
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .accessibilityIdentifier("screen.lesson")
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

private struct LessonPageScreen: View {
    let page: LearnNowLessonPage
    let feedback: LearnNowLessonFeedback?
    let onAnswer: (String) -> Void
    let onCallToAction: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .center, spacing: 16) {
                    NeumorphicPill(text: page.badge, accent: page.accent)
                    Text(page.title)
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                Text(page.summary)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textSecondary)
                    .lineSpacing(6)

                CalloutCard(
                    title: page.calloutTitle,
                    message: page.calloutBody,
                    accent: page.calloutAccent
                )

                if let codeSample = page.codeSample {
                    CodeSampleCard(code: codeSample)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Label("随堂练习", systemImage: "square.and.pencil")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Text(page.question.prompt)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textSecondary)
                        .lineSpacing(4)

                    ForEach(page.question.options) { option in
                        LessonOptionButton(option: option, page: page) {
                            onAnswer(option.id)
                        }
                        .accessibilityIdentifier("lesson.option.\(option.id)")
                    }

                    if let feedback {
                        FeedbackCard(feedback: feedback)
                    }

                    if let action = page.callToAction {
                        FullWidthButton(
                            title: action.title,
                            accent: action == .retry ? nil : .blue,
                            action: onCallToAction
                        )
                        .accessibilityIdentifier("lesson.cta")
                    }
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
    }
}

private struct LessonOptionButton: View {
    let option: LearnNowLessonOption
    let page: LearnNowLessonPage
    let action: () -> Void

    private var isAnswered: Bool {
        if case .unanswered = page.answerState {
            false
        } else {
            true
        }
    }

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
        .disabled(isAnswered)
    }

    private var borderColor: Color {
        switch page.answerState {
        case .correct(let optionID) where optionID == option.id:
            LearnNowPalette.color(for: .mint)
        case .incorrect(let optionID) where optionID == option.id:
            LearnNowPalette.color(for: .pink)
        default:
            .clear
        }
    }

    private var borderWidth: CGFloat {
        switch page.answerState {
        case .correct(let optionID) where optionID == option.id:
            2
        case .incorrect(let optionID) where optionID == option.id:
            2
        default:
            0
        }
    }

    private var labelColor: Color {
        switch page.answerState {
        case .correct(let optionID) where optionID == option.id:
            LearnNowPalette.color(for: .mint)
        case .incorrect(let optionID) where optionID == option.id:
            LearnNowPalette.color(for: .pink)
        default:
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
    let title: String
    let message: String
    let accent: LearnNowAccent

    var body: some View {
        InsetCard(contentPadding: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: accent == .amber ? "exclamationmark.triangle.fill" : "lightbulb.fill")
                    Text(title)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                }
                .foregroundStyle(LearnNowPalette.color(for: accent))

                Text(message)
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
    LessonScreenPreviewContainer()
}

private struct LessonScreenPreviewContainer: View {
    @State private var flow = LearnNowFlowState.lessonPreview

    var body: some View {
        ZStack {
            LearnNowPalette.canvas.ignoresSafeArea()
            LessonScreen(flow: $flow)
        }
    }
}
