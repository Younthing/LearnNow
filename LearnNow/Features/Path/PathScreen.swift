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

private struct PathNodeRow: View {
    let node: PathScreenModel.Node
    let showsLineBelow: Bool
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(spacing: 0) {
                nodeBadge

                if showsLineBelow {
                    Capsule()
                        .fill(lineColor)
                        .frame(width: 4)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 8)
                }
            }
            .frame(width: 48)

            content
        }
        .padding(.bottom, node.status == .current ? 24 : 0)
    }

    private var lineColor: Color {
        LearnNowPalette
            .color(for: node.status == .done ? .mint : (node.status == .current ? .blue : .purple))
            .opacity(node.status == .locked ? 0.2 : 0.6)
    }

    @ViewBuilder
    private var content: some View {
        if node.isInteractive {
            if node.status == .current {
                Button(action: onTap) {
                    moduleContent
                }
                .buttonStyle(SoftPressStyle(cornerRadius: 22))
                .accessibilityIdentifier("path.module.\(node.id)")
            } else {
                Button(action: onTap) {
                    moduleContent
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("path.module.\(node.id)")
            }
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
        InsetCard(contentPadding: 22) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(node.title)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.color(for: .blue))

                    Spacer()

                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(LearnNowPalette.color(for: .blue))
                }

                Text(node.subtitle)
                    .font(LearnNowTypography.body)
                    .foregroundStyle(LearnNowPalette.textMuted)

                if let progress = node.progress {
                    ProgressTrack(progress: progress, accent: .blue, height: 10)
                }
            }
        }
        .accessibilityIdentifier("path.currentModule")
    }

    private func compactModuleRow(showsChevron: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(node.title)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary.opacity(node.status == .locked ? 0.5 : 1))

                Text(node.subtitle)
                    .font(LearnNowTypography.body)
                    .foregroundStyle(LearnNowPalette.textMuted.opacity(node.status == .locked ? 0.5 : 1))
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(LearnNowPalette.textMuted.opacity(0.75))
                    .padding(.top, 2)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, node.status == .locked ? 24 : 0)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var nodeBadge: some View {
        switch node.status {
        case .done:
            InsetCircle(size: 48) {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(LearnNowPalette.color(for: .mint))
            }
            .overlay(Circle().stroke(LearnNowPalette.color(for: .mint).opacity(0.5), lineWidth: 2))
        case .current:
            ZStack {
                Circle()
                    .fill(LearnNowPalette.color(for: .blue).opacity(colorScheme == .dark ? 0.3 : 0.15))
                    .frame(width: 48, height: 48)
                    .blur(radius: 8)

                Circle()
                    .fill(LearnNowPalette.base)
                    .modifier(OuterSurface(cornerRadius: 24))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle().stroke(LearnNowPalette.gradient(for: .blue), lineWidth: 2)
                    )
                    .overlay {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(LearnNowPalette.color(for: .blue))
                    }
            }
        case .locked:
            InsetCircle(size: 48) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LearnNowPalette.textMuted.opacity(0.6))
            }
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
