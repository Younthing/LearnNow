import SwiftUI

struct ProfileScreen: View {
    let model: ProfileScreenModel
    let onEditProfile: () -> Void
    let onOpenCareer: () -> Void
    let onOpenFavorites: () -> Void
    let onOpenSettings: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var insightMode: ProfileInsightMode = .overview

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: spacing(for: geometry.size.height)) {
                    Text(model.title)
                        .font(.system(.largeTitle, design: .rounded, weight: .black))
                        .foregroundStyle(LearnNowPalette.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    ProfileIdentityCard(identity: model.identity, onEdit: onEditProfile)

                    ProfileInsightCard(
                        overview: model.overview,
                        memoryTrend: model.memoryTrend,
                        selection: $insightMode,
                        usesFlexibleHeight: dynamicTypeSize.isAccessibilitySize
                    )

                    ProfileShortcutCard(
                        shortcuts: model.shortcuts,
                        onSelect: handleShortcut
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 12)
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
        }
        .accessibilityIdentifier("screen.profile")
    }

    private func spacing(for height: CGFloat) -> CGFloat {
        height < 700 ? 10 : 12
    }

    private func handleShortcut(_ shortcut: ProfileShortcutKind) {
        switch shortcut {
        case .career:
            onOpenCareer()
        case .favorites:
            onOpenFavorites()
        case .settings:
            onOpenSettings()
        }
    }
}

private struct ProfileIdentityCard: View {
    let identity: ProfileScreenModel.Identity
    let onEdit: () -> Void

    private var avatar: AvatarOption {
        AvatarOption.option(for: identity.avatarID)
    }

    var body: some View {
        Button(action: onEdit) {
            SoftCard(contentPadding: 14) {
                HStack(spacing: 14) {
                    ZStack(alignment: .bottomTrailing) {
                        Image(avatar.assetName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(.white.opacity(0.85), lineWidth: 2)
                            }
                            .softOuter(radius: 8, x: 3, y: 5)

                        Image(systemName: "pencil")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(LearnNowPalette.color(for: .blue), in: Circle())
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(identity.displayName)
                            .font(.system(.title2, design: .rounded, weight: .heavy))
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .lineLimit(1)

                        Text(identity.activityText)
                            .font(.body)
                            .foregroundStyle(LearnNowPalette.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(LearnNowPalette.textMuted)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(identity.displayName)，\(identity.activityText)")
        .accessibilityHint("编辑昵称和头像")
        .accessibilityIdentifier("profile.edit")
    }
}

private struct ProfileInsightCard: View {
    let overview: ProfileScreenModel.Overview
    let memoryTrend: ProfileScreenModel.MemoryTrend
    @Binding var selection: ProfileInsightMode
    let usesFlexibleHeight: Bool

    var body: some View {
        SoftCard(contentPadding: 14) {
            VStack(alignment: .leading, spacing: 12) {
                insightHeader

                Group {
                    switch selection {
                    case .overview:
                        ProfileOverviewContent(overview: overview)
                            .transition(.opacity)
                    case .memoryTrend:
                        ProfileMemoryTrendContent(memoryTrend: memoryTrend)
                            .transition(.opacity)
                    }
                }
                .frame(height: usesFlexibleHeight ? nil : 150, alignment: .top)
                .animation(.easeInOut(duration: 0.2), value: selection)
            }
        }
        .accessibilityIdentifier("profile.insight")
    }

    @ViewBuilder
    private var insightHeader: some View {
        if usesFlexibleHeight {
            VStack(alignment: .leading, spacing: 8) {
                insightTitle
                insightPicker
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        } else {
            HStack(spacing: 10) {
                insightTitle
                Spacer(minLength: 0)
                insightPicker
                    .frame(maxWidth: 194, minHeight: 44)
            }
        }
    }

    private var insightTitle: some View {
        Text("学习洞察")
            .font(.system(.headline, design: .rounded, weight: .heavy))
            .foregroundStyle(LearnNowPalette.textPrimary)
    }

    private var insightPicker: some View {
        Picker("学习洞察展示", selection: $selection) {
            ForEach(ProfileInsightMode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("profile.insight.picker")
    }
}

private struct ProfileOverviewContent: View {
    let overview: ProfileScreenModel.Overview

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                ForEach(overview.metrics) { metric in
                    InsetCard(contentPadding: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(metric.title)
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .foregroundStyle(LearnNowPalette.textMuted)
                                .lineLimit(1)

                            Text(metric.value)
                                .font(.system(.title3, design: .rounded, weight: .black))
                                .foregroundStyle(LearnNowPalette.color(for: metric.accent))
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            HStack {
                Text("近四周学习")
                    .font(.caption)
                    .foregroundStyle(LearnNowPalette.textSecondary)

                Spacer()

                Text("越深代表学习越多")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(LearnNowPalette.textMuted)
            }

            CompactHeatmap(cells: overview.heatmap)
        }
    }
}

private struct CompactHeatmap: View {
    let cells: [LearnNowHeatCell]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 7) {
            ForEach(cells) { cell in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(color(for: cell.level))
                    .frame(height: 9)
                    .opacity(cell.level == nil ? 0.18 : 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("近四周学习热力图")
    }

    private func color(for level: Int?) -> Color {
        switch level {
        case nil, 0:
            LearnNowPalette.shadowDark.opacity(0.14)
        case 1:
            LearnNowPalette.color(for: .mint).opacity(0.55)
        case 2:
            LearnNowPalette.color(for: .blue).opacity(0.72)
        default:
            LearnNowPalette.color(for: .purple)
        }
    }
}

private struct ProfileMemoryTrendContent: View {
    let memoryTrend: ProfileScreenModel.MemoryTrend

    var body: some View {
        if memoryTrend.isEmpty {
            InsetCard(contentPadding: 16) {
                HStack(spacing: 14) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(LearnNowPalette.color(for: .blue))

                    VStack(alignment: .leading, spacing: 5) {
                        Text("完成首次复习后生成趋势")
                            .font(.system(.headline, design: .rounded, weight: .heavy))
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        Text("LearnNow 会依据 FSRS 预测未来 7 天的平均记忆保持率。")
                            .font(.body)
                            .foregroundStyle(LearnNowPalette.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .accessibilityIdentifier("profile.memory.empty")
        } else {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    MemoryTrendValue(title: "当前保持率", value: memoryTrend.currentText ?? "—")

                    Spacer()

                    MemoryTrendValue(title: "7 天预测", value: memoryTrend.seventhDayText ?? "—")
                }

                MemoryTrendChart(values: memoryTrend.values)
                    .frame(height: 92)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(
                        "记忆趋势，当前 \(memoryTrend.currentText ?? "未知")，7 天后 \(memoryTrend.seventhDayText ?? "未知")，目标百分之九十"
                    )
            }
        }
    }
}

private struct MemoryTrendValue: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(LearnNowPalette.textMuted)

            Text(value)
                .font(.system(.title2, design: .rounded, weight: .black))
                .foregroundStyle(LearnNowPalette.color(for: .blue))
        }
    }
}

private struct MemoryTrendChart: View {
    let values: [Double]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                Path { path in
                    let y = (1 - 0.9) * geometry.size.height
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                .stroke(
                    LearnNowPalette.color(for: .mint).opacity(0.7),
                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                )

                ProfileChartAreaShape(values: values)
                    .fill(LearnNowPalette.gradient(for: .blue).opacity(0.18))

                ProfileChartLineShape(values: values)
                    .stroke(
                        LearnNowPalette.color(for: .blue),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )

                Text("目标 90%")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(LearnNowPalette.color(for: .mint))
                    .padding(.horizontal, 5)
                    .background(LearnNowPalette.base.opacity(0.86), in: Capsule())
            }
        }
    }
}

private struct ProfileChartLineShape: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        guard !values.isEmpty else { return Path() }
        var path = Path()
        for index in values.indices {
            let point = point(at: index, in: rect)
            index == values.startIndex ? path.move(to: point) : path.addLine(to: point)
        }
        return path
    }

    private func point(at index: Int, in rect: CGRect) -> CGPoint {
        let step = rect.width / CGFloat(max(values.count - 1, 1))
        return CGPoint(
            x: CGFloat(index) * step,
            y: (1 - values[index].clamped(to: 0...1)) * rect.height
        )
    }
}

private struct ProfileChartAreaShape: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        guard !values.isEmpty else { return Path() }
        var path = ProfileChartLineShape(values: values).path(in: rect)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct ProfileShortcutCard: View {
    let shortcuts: [ProfileScreenModel.Shortcut]
    let onSelect: (ProfileShortcutKind) -> Void

    var body: some View {
        SoftCard(contentPadding: 8) {
            VStack(spacing: 0) {
                ForEach(Array(shortcuts.enumerated()), id: \.element.id) { index, shortcut in
                    Button {
                        onSelect(shortcut.kind)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LearnNowPalette.base)
                                    .frame(width: 38, height: 38)
                                    .modifier(InsetSurface(cornerRadius: 19))

                                Image(systemName: shortcut.systemImage)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(LearnNowPalette.color(for: shortcut.accent))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(shortcut.title)
                                    .font(.system(.body, design: .rounded, weight: .heavy))
                                    .foregroundStyle(LearnNowPalette.textPrimary)

                                Text(shortcut.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(LearnNowPalette.textMuted)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }
                        .frame(minHeight: 48)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("profile.shortcut.\(shortcut.kind.rawValue)")

                    if index < shortcuts.count - 1 {
                        Divider()
                            .overlay(LearnNowPalette.shadowDark.opacity(0.16))
                            .padding(.leading, 50)
                    }
                }
            }
        }
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

#Preview("Profile · Memory empty") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        ProfileScreen(
            model: LearnNowFlowState.profilePreview.profileScreenModel,
            onEditProfile: {},
            onOpenCareer: {},
            onOpenFavorites: {},
            onOpenSettings: {}
        )
    }
}

#Preview("Profile · Memory trend") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        ProfileScreen(
            model: LearnNowFlowState.profileMemoryPreview.profileScreenModel,
            onEditProfile: {},
            onOpenCareer: {},
            onOpenFavorites: {},
            onOpenSettings: {}
        )
    }
}

#Preview("Profile · Empty data") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        ProfileScreen(
            model: LearnNowFlowState.profileEmptyPreview.profileScreenModel,
            onEditProfile: {},
            onOpenCareer: {},
            onOpenFavorites: {},
            onOpenSettings: {}
        )
    }
}
