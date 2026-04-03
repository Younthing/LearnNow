import SwiftUI

struct ReviewBoardScreen: View {
    @Binding var flow: LearnNowFlowState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                ScreenHeader(title: "复习卡片", centered: true)

                HStack(spacing: 12) {
                    NeumorphicPill(text: "新卡 8", accent: .blue)
                    NeumorphicPill(text: "巩固 12", accent: .mint)
                    NeumorphicPill(text: "待复习 5", accent: .pink)
                }

                Button {
                    if !flow.isCurrentReviewCardFlipped {
                        flow.flipCurrentReviewCard()
                    }
                } label: {
                    FlashcardView(card: flow.currentReviewCard, isFlipped: flow.isCurrentReviewCardFlipped)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("anki.card")

                if flow.isCurrentReviewCardFlipped {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(LearnNowReviewRating.allCases) { rating in
                            Button {
                                flow.rateCurrentReviewCard(rating)
                            } label: {
                                VStack(spacing: 4) {
                                    Text(rating.title)
                                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                                    Text(rating.interval)
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                }
                                .foregroundStyle(LearnNowPalette.color(for: rating.accent))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                            }
                            .buttonStyle(SoftPressStyle(cornerRadius: 18))
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .accessibilityIdentifier("screen.anki")
    }
}

private struct FlashcardView: View {
    let card: LearnNowReviewCard
    let isFlipped: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(LearnNowPalette.base)
                .softOuter(radius: 16, x: 8, y: 8)

            VStack(spacing: 20) {
                Text(isFlipped ? card.backTitle : card.topic)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(isFlipped ? LearnNowPalette.color(for: .pink) : LearnNowPalette.color(for: .blue))
                    .textCase(.uppercase)

                if isFlipped {
                    VStack(spacing: 18) {
                        Text(card.backBody)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                        InsetCard(contentPadding: 16) {
                            Text(card.backHighlight)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundStyle(LearnNowPalette.color(for: .pink))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Text(card.frontTitle)
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(card.frontSubtitle)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textMuted)

                        Label("点击卡片翻转", systemImage: "hand.tap")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }
            }
            .padding(.horizontal, 26)
        }
        .frame(height: 340)
    }
}

#Preview("Anki") {
    ReviewBoardScreenPreviewContainer()
}

private struct ReviewBoardScreenPreviewContainer: View {
    @State private var flow = LearnNowFlowState.reviewBoardPreview

    var body: some View {
        ZStack {
            LearnNowPalette.canvas.ignoresSafeArea()
            ReviewBoardScreen(flow: $flow)
        }
    }
}
