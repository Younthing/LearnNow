import SwiftUI

enum LearnNowSpacing {
    static let screenHorizontal: CGFloat = 20
    static let screenTop: CGFloat = 20
    static let screenBottom: CGFloat = 40
    static let section: CGFloat = 24
    static let cardGap: CGFloat = 20
    static let itemGap: CGFloat = 16
    static let compactGap: CGFloat = 10
    static let maximumContentWidth: CGFloat = 920
    static let floatingTabBarClearance: CGFloat = 106

    static func screenHorizontal(for width: CGFloat) -> CGFloat {
        switch width {
        case ...390:
            16
        case ..<700:
            screenHorizontal
        default:
            32
        }
    }
}

enum LearnNowTypography {
    static let screenTitle = Font.system(.title, design: .rounded, weight: .bold)
    static let sheetTitle = Font.system(.title2, design: .rounded, weight: .bold)
    static let sectionTitle = Font.system(.title3, design: .rounded, weight: .semibold)
    static let cardTitle = Font.system(.headline, design: .rounded, weight: .semibold)
    static let cardHeadline = Font.system(.title3, design: .rounded, weight: .bold)
    static let body = Font.system(.body, design: .default, weight: .regular)
    static let screenSubtitle = Font.system(.subheadline, design: .default, weight: .regular)
    static let label = Font.system(.subheadline, design: .rounded, weight: .semibold)
    static let metadata = Font.system(.footnote, design: .default, weight: .medium)
    static let caption = Font.system(.caption, design: .default, weight: .medium)
    static let metricValue = Font.system(.title, design: .rounded, weight: .bold)
    static let metricUnit = Font.system(.subheadline, design: .rounded, weight: .semibold)
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
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: spacing) {
                    content
                }
                .padding(
                    .horizontal,
                    LearnNowSpacing.screenHorizontal(for: geometry.size.width)
                )
                .padding(.top, LearnNowSpacing.screenTop)
                .padding(.bottom, bottomPadding)
                .frame(maxWidth: LearnNowSpacing.maximumContentWidth)
                .frame(maxWidth: .infinity)
            }
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
