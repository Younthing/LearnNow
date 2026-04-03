import SwiftUI

enum LearnNowSpacing {
    static let screenHorizontal: CGFloat = 24
    static let screenTop: CGFloat = 20
    static let screenBottom: CGFloat = 40
    static let section: CGFloat = 24
    static let cardGap: CGFloat = 20
    static let itemGap: CGFloat = 16
    static let compactGap: CGFloat = 10
}

enum LearnNowTypography {
    static let screenTitle = Font.system(size: 30, weight: .black, design: .rounded)
    static let screenSubtitle = Font.system(size: 13, weight: .bold, design: .rounded)
    static let sectionTitle = Font.system(size: 20, weight: .heavy, design: .rounded)
    static let cardTitle = Font.system(size: 17, weight: .heavy, design: .rounded)
    static let cardHeadline = Font.system(size: 20, weight: .heavy, design: .rounded)
    static let body = Font.system(size: 14, weight: .semibold, design: .rounded)
    static let label = Font.system(size: 13, weight: .heavy, design: .rounded)
    static let metricValue = Font.system(size: 28, weight: .black, design: .rounded)
    static let metricUnit = Font.system(size: 14, weight: .bold, design: .rounded)
}

struct ScreenScaffold<Content: View>: View {
    let spacing: CGFloat
    let bottomPadding: CGFloat
    @ViewBuilder let content: Content

    init(
        spacing: CGFloat = LearnNowSpacing.section,
        bottomPadding: CGFloat = LearnNowSpacing.screenBottom,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.bottomPadding = bottomPadding
        self.content = content()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: spacing) {
                content
            }
            .padding(.horizontal, LearnNowSpacing.screenHorizontal)
            .padding(.top, LearnNowSpacing.screenTop)
            .padding(.bottom, bottomPadding)
        }
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(LearnNowTypography.sectionTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(LearnNowTypography.screenSubtitle)
                    .foregroundStyle(LearnNowPalette.textMuted)
            }
        }
    }
}

struct MetricGridSection<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let columns: Int
    let spacing: CGFloat
    let content: (Item) -> Content

    init(
        items: [Item],
        columns: Int = 2,
        spacing: CGFloat = LearnNowSpacing.cardGap,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.columns = columns
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            ForEach(items) { item in
                content(item)
            }
        }
    }
}

struct HeroProgressCard: View {
    let badge: String
    let title: String
    let progress: Double
    let progressText: String
    let accent: LearnNowAccent
    let action: () -> Void

    var body: some View {
        SoftCard(contentPadding: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        NeumorphicPill(text: badge, accent: accent)

                        Text(title)
                            .font(LearnNowTypography.cardHeadline)
                            .foregroundStyle(LearnNowPalette.textPrimary)
                    }

                    Spacer(minLength: 0)

                    CircleIconButton(systemImage: "play.fill", accent: accent, action: action)
                }

                ProgressTrack(progress: progress, accent: accent, height: 12)

                HStack {
                    Spacer()

                    Text(progressText)
                        .font(LearnNowTypography.label)
                        .foregroundStyle(LearnNowPalette.textMuted)
                }
            }
        }
    }
}

struct InsightCard<Accessory: View, Content: View>: View {
    let title: String
    @ViewBuilder let accessory: Accessory
    @ViewBuilder let content: Content

    init(
        title: String,
        @ViewBuilder accessory: () -> Accessory = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.accessory = accessory()
        self.content = content()
    }

    var body: some View {
        SoftCard(contentPadding: 20) {
            VStack(alignment: .leading, spacing: LearnNowSpacing.itemGap) {
                HStack {
                    Text(title)
                        .font(LearnNowTypography.cardTitle)
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Spacer()

                    accessory
                }

                content
            }
        }
    }
}
