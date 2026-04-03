import SwiftUI

struct PathScreen: View {
    let flow: LearnNowFlowState
    let onBack: () -> Void
    let onOpenLesson: (String) -> Void

    @State private var animateNodes = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 16) {
                    CircleIconButton(systemImage: "arrow.left", accent: .blue, size: 42, action: onBack)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(flow.routeCategoryTitle)
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text("专业学习路线")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }
                .padding(.top, 10)

                HStack(spacing: 8) {
                    ForEach(flow.routeTabs, id: \.self) { tab in
                        NeumorphicPill(
                            text: tab,
                            accent: tab == flow.routeTabs.first ? .blue : .mint,
                            isSelected: tab == flow.routeTabs.first,
                            isExpanded: true
                        )
                    }
                }
                .padding(.vertical, 6)

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(flow.pathNodes.enumerated()), id: \.element.id) { index, node in
                        PathNodeRow(
                            node: node,
                            showsLineBelow: index < flow.pathNodes.count - 1,
                            onTap: {
                                if node.isInteractive {
                                    onOpenLesson(node.id)
                                }
                            }
                        )
                        .opacity(animateNodes ? 1 : 0)
                        .offset(y: animateNodes ? 0 : 30)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1),
                            value: animateNodes
                        )
                    }
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 60)
        }
        .onAppear {
            animateNodes = true
        }
        .onDisappear {
            animateNodes = false
        }
        .accessibilityIdentifier("screen.path")
    }
}

private struct PathNodeRow: View {
    let node: LearnNowPathNode
    let showsLineBelow: Bool
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(spacing: 0) {
                nodeBadge

                if showsLineBelow {
                    Capsule()
                        .fill(
                            LearnNowPalette
                                .color(for: node.status == .done ? .mint : (node.status == .current ? .blue : .purple))
                                .opacity(node.status == .locked ? 0.2 : 0.6)
                        )
                        .frame(width: 4)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 8)
                }
            }
            .frame(width: 48)

            VStack {
                if node.status == .current {
                    Button(action: onTap) {
                        currentModuleCard
                    }
                    .buttonStyle(SoftPressStyle(cornerRadius: 22))
                    .accessibilityIdentifier("path.module.\(node.id)")
                } else if node.status == .done && node.isInteractive {
                    Button(action: onTap) {
                        completedModuleRow
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("path.module.\(node.id)")
                } else {
                    staticModuleRow
                }
            }
        }
        .padding(.bottom, node.status == .current ? 24 : 0)
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
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textMuted)

                ProgressTrack(progress: 0.40, accent: .blue, height: 10)
            }
        }
        .accessibilityIdentifier("path.currentModule")
    }

    private var completedModuleRow: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(node.title)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)

                Text(node.subtitle)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textMuted)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(LearnNowPalette.textMuted.opacity(0.75))
                .padding(.top, 2)
        }
        .padding(.top, 12)
        .contentShape(Rectangle())
    }

    private var staticModuleRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(node.title)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(LearnNowPalette.textPrimary.opacity(node.status == .locked ? 0.5 : 1))
            Text(node.subtitle)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(LearnNowPalette.textMuted.opacity(node.status == .locked ? 0.5 : 1))
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
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
        PathScreen(flow: .pathPreview, onBack: {}, onOpenLesson: { _ in })
    }
}
