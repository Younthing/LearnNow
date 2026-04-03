import SwiftUI

struct PathScreen: View {
    let model: PathScreenModel
    let onBack: () -> Void
    let onSelectTrack: (LearnNowRouteTrack) -> Void
    let onOpenLesson: (String) -> Void

    @State private var animateNodes = false

    var body: some View {
        ScreenScaffold(bottomPadding: 60) {
            pathHeader
            RouteTrackTabs(
                tabs: model.trackTabs,
                onSelectTrack: onSelectTrack
            )
            selectedTrackHeader

            if model.nodes.isEmpty {
                PathEmptyStateCard(
                    title: model.emptyStateTitle ?? "",
                    message: model.emptyStateMessage ?? ""
                )
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(model.nodes.enumerated()), id: \.element.id) { index, node in
                        PathNodeRow(
                            node: node,
                            showsLineBelow: index < model.nodes.count - 1,
                            onTap: { onOpenLesson(node.id) }
                        )
                        .opacity(animateNodes ? 1 : 0)
                        .offset(y: animateNodes ? 0 : 30)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1),
                            value: animateNodes
                        )
                    }
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            animateNodes = true
        }
        .onDisappear {
            animateNodes = false
        }
        .accessibilityIdentifier("screen.path")
    }

    private var selectedTrackHeader: some View {
        VStack(spacing: 6) {
            Text(model.selectedTrackTitle)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(LearnNowPalette.textPrimary)
                .frame(maxWidth: .infinity)

            Text(model.selectedTrackSummary)
                .font(LearnNowTypography.screenSubtitle)
                .foregroundStyle(LearnNowPalette.textMuted)
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 4)
    }

    private var pathHeader: some View {
        HStack(spacing: 16) {
            CircleIconButton(systemImage: "arrow.left", accent: .blue, size: 42, action: onBack)

            VStack(alignment: .leading, spacing: 4) {
                Text(model.title)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(model.subtitle)
                    .font(LearnNowTypography.screenSubtitle)
                    .foregroundStyle(LearnNowPalette.textMuted)
            }
        }
        .padding(.top, 10)
    }
}

private struct RouteTrackTabs: View {
    let tabs: [PathScreenModel.TrackTab]
    let onSelectTrack: (LearnNowRouteTrack) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs) { tab in
                Button {
                    onSelectTrack(tab.track)
                } label: {
                    NeumorphicPill(
                        text: tab.title,
                        accent: tab.isSelected ? .blue : .mint,
                        isSelected: tab.isSelected,
                        isExpanded: true
                    )
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
                .accessibilityIdentifier("path.track.\(tab.track.rawValue)")
            }
        }
    }
}

private struct PathEmptyStateCard: View {
    let title: String
    let message: String

    var body: some View {
        SoftCard(contentPadding: 24) {
            VStack(spacing: 16) {
                InsetCircle(size: 72) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(LearnNowPalette.color(for: .amber))
                }

                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textMuted)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityIdentifier("path.empty")
    }
}

private enum PathNodeLayout {
    static let timelineSpacing: CGFloat = 20
    static let badgeColumnWidth: CGFloat = 56
    static let connectorWidth: CGFloat = 4
    static let connectorInset: CGFloat = 10
    static let rowGap: CGFloat = 18
    static let cardPadding: CGFloat = 18
    static let featuredCardPadding: CGFloat = 20
    static let cardCornerRadius: CGFloat = 22
    static let compactRowVerticalPadding: CGFloat = 14
    static let compactRowMinHeight: CGFloat = 76
    static let currentCardMinHeight: CGFloat = 138
    static let regularBadgeSize: CGFloat = 48
    static let currentBadgeSize: CGFloat = 56
}

private struct PathNodeRow: View {
    let node: PathScreenModel.Node
    let showsLineBelow: Bool
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: PathNodeLayout.timelineSpacing) {
            VStack(spacing: 0) {
                nodeBadge

                if showsLineBelow {
                    Capsule()
                        .fill(lineColor)
                        .frame(width: PathNodeLayout.connectorWidth)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, PathNodeLayout.connectorInset)
                }
            }
            .frame(width: PathNodeLayout.badgeColumnWidth)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, showsLineBelow ? PathNodeLayout.rowGap : 0)
    }

    private var lineColor: Color {
        LearnNowPalette
            .color(for: node.status == .done ? .mint : (node.status == .current ? .blue : .purple))
            .opacity(node.status == .locked ? 0.2 : 0.6)
    }

    @ViewBuilder
    private var content: some View {
        if node.isInteractive {
            Button(action: onTap) {
                moduleContent
            }
            .buttonStyle(PathModulePressStyle())
            .accessibilityIdentifier("path.module.\(node.id)")
        } else {
            moduleContent
                .accessibilityIdentifier("path.module.\(node.id)")
        }
    }

    @ViewBuilder
    private var moduleContent: some View {
        switch node.status {
        case .current:
            currentModuleCard
        case .done:
            compactModuleRow(showsChevron: true)
        case .locked:
            compactModuleRow(showsChevron: false)
        }
    }

    private var currentModuleCard: some View {
        PathModuleSurface(accent: .blue, isInset: true, contentPadding: PathNodeLayout.featuredCardPadding) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    NeumorphicPill(
                        text: "正在学习",
                        accent: .blue,
                        isSelected: true
                    )
                    .fixedSize()

                    Spacer(minLength: 0)

                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(LearnNowPalette.color(for: .blue))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(node.title)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.color(for: .blue))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(node.subtitle)
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let progress = node.progress {
                    VStack(alignment: .leading, spacing: 8) {
                        ProgressTrack(progress: progress, accent: .blue, height: 10)

                        Text("已完成 \(Int(progress * 100))%")
                            .font(LearnNowTypography.label)
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: PathNodeLayout.currentCardMinHeight, alignment: .topLeading)
        }
        .accessibilityIdentifier("path.currentModule")
    }

    private func compactModuleRow(showsChevron: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(node.title)
                    .font(LearnNowTypography.cardTitle)
                    .foregroundStyle(LearnNowPalette.textPrimary.opacity(node.status == .locked ? 0.5 : 0.92))
                    .fixedSize(horizontal: false, vertical: true)

                Text(node.subtitle)
                    .font(LearnNowTypography.body)
                    .foregroundStyle(LearnNowPalette.textMuted.opacity(node.status == .locked ? 0.5 : 0.82))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(LearnNowPalette.textMuted.opacity(0.7))
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, PathNodeLayout.compactRowVerticalPadding)
        .padding(.horizontal, PathNodeLayout.cardPadding)
        .frame(maxWidth: .infinity, minHeight: PathNodeLayout.compactRowMinHeight, alignment: .topLeading)
        .opacity(node.status == .locked ? 0.74 : 1)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var nodeBadge: some View {
        switch node.status {
        case .done:
            InsetCircle(size: PathNodeLayout.regularBadgeSize) {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(LearnNowPalette.color(for: .mint))
            }
            .overlay(Circle().stroke(LearnNowPalette.color(for: .mint).opacity(0.5), lineWidth: 2))
        case .current:
            ZStack {
                Circle()
                    .fill(LearnNowPalette.color(for: .blue).opacity(colorScheme == .dark ? 0.3 : 0.15))
                    .frame(width: PathNodeLayout.currentBadgeSize, height: PathNodeLayout.currentBadgeSize)
                    .blur(radius: 12)

                Circle()
                    .fill(LearnNowPalette.base)
                    .modifier(OuterSurface(cornerRadius: PathNodeLayout.currentBadgeSize / 2))
                    .frame(width: PathNodeLayout.currentBadgeSize, height: PathNodeLayout.currentBadgeSize)
                    .overlay(
                        Circle().stroke(LearnNowPalette.gradient(for: .blue), lineWidth: 2)
                    )
                    .overlay {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(LearnNowPalette.color(for: .blue))
                    }
            }
        case .locked:
            InsetCircle(size: PathNodeLayout.regularBadgeSize) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LearnNowPalette.textMuted.opacity(0.6))
            }
        }
    }
}

private struct PathModulePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

private struct PathModuleSurface<Content: View>: View {
    let accent: LearnNowAccent?
    let isInset: Bool
    let contentPadding: CGFloat
    @ViewBuilder let content: Content

    init(
        accent: LearnNowAccent? = nil,
        isInset: Bool = false,
        contentPadding: CGFloat = 18,
        @ViewBuilder content: () -> Content
    ) {
        self.accent = accent
        self.isInset = isInset
        self.contentPadding = contentPadding
        self.content = content()
    }

    var body: some View {
        content
            .padding(contentPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(surface)
            .overlay(borderOverlay)
    }

    private var surface: some View {
        Group {
            if isInset {
                RoundedRectangle(cornerRadius: PathNodeLayout.cardCornerRadius, style: .continuous)
                    .fill(LearnNowPalette.base)
                    .modifier(InsetSurface(cornerRadius: PathNodeLayout.cardCornerRadius))
            } else {
                RoundedRectangle(cornerRadius: PathNodeLayout.cardCornerRadius, style: .continuous)
                    .fill(LearnNowPalette.base)
                    .modifier(OuterSurface(cornerRadius: PathNodeLayout.cardCornerRadius))
            }
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if let accent {
            RoundedRectangle(cornerRadius: PathNodeLayout.cardCornerRadius, style: .continuous)
                .stroke(LearnNowPalette.gradient(for: accent), lineWidth: 1)
        }
    }
}

#Preview("Path") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        PathScreen(
            model: LearnNowFlowState.pathPreview.pathScreenModel,
            onBack: {},
            onSelectTrack: { _ in },
            onOpenLesson: { _ in }
        )
    }
}

#Preview("Path Empty Track") {
    var flow = LearnNowFlowState.pathPreview
    flow.selectRouteTrack(.deepLearning)

    return ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        PathScreen(
            model: flow.pathScreenModel,
            onBack: {},
            onSelectTrack: { _ in },
            onOpenLesson: { _ in }
        )
    }
}
