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
                        .font(LearnNowTypography.screenTitle)
                        .foregroundStyle(LearnNowPalette.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    ProfileIdentityCard(identity: model.identity, onEdit: onEditProfile)

                    ProfileInsightCard(
                        overview: model.overview,
                        memoryTrend: model.memoryTrend,
                        selection: $insightMode,
                        usesFlexibleHeight: usesFlexibleInsightHeight
                    )

                    ProfileShortcutCard(
                        shortcuts: model.shortcuts,
                        onSelect: handleShortcut
                    )
                }
                .padding(
                    .horizontal,
                    LearnNowSpacing.screenHorizontal(for: geometry.size.width)
                )
                .padding(.top, 12)
                .padding(
                    .bottom,
                    usesFlexibleInsightHeight
                        ? LearnNowSpacing.floatingTabBarClearance
                        : 12
                )
                .frame(
                    maxWidth: LearnNowSpacing.maximumContentWidth,
                    minHeight: geometry.size.height,
                    alignment: .top
                )
                .frame(maxWidth: .infinity)
            }
        }
        .accessibilityIdentifier("screen.profile")
    }

    private func spacing(for height: CGFloat) -> CGFloat {
        height < 700 ? 10 : 12
    }

    private var usesFlexibleInsightHeight: Bool {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium, .large:
            false
        default:
            true
        }
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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(LearnNowPalette.color(for: .blue), in: Circle())
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(identity.displayName)
                            .font(LearnNowTypography.sheetTitle)
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(identity.activityText)
                            .font(LearnNowTypography.body)
                            .foregroundStyle(LearnNowPalette.textSecondary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.bold))
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

    private let regularContentHeight: CGFloat = 200

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
                        ProfileMemoryTrendContent(
                            memoryTrend: memoryTrend,
                            fillsAvailableHeight: !usesFlexibleHeight
                        )
                            .transition(.opacity)
                    }
                }
                .frame(
                    height: usesFlexibleHeight ? nil : regularContentHeight,
                    alignment: .top
                )
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
            .font(LearnNowTypography.cardTitle)
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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var metricColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 8),
            count: dynamicTypeSize.isAccessibilitySize ? 1 : 3
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LazyVGrid(columns: metricColumns, spacing: 8) {
                ForEach(overview.metrics) { metric in
                    InsetCard(contentPadding: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(metric.title)
                                .font(LearnNowTypography.caption)
                                .foregroundStyle(LearnNowPalette.textMuted)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(metric.value)
                                .font(LearnNowTypography.sectionTitle)
                                .foregroundStyle(LearnNowPalette.color(for: metric.accent))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            heatmapTitle

            CompactHeatmap(cells: overview.heatmap)
        }
    }

    private var heatmapTitle: some View {
        Text("近期学习")
            .font(LearnNowTypography.caption)
            .foregroundStyle(LearnNowPalette.textSecondary)
    }
}

private struct CompactHeatmap: View {
    let cells: [LearnNowHeatCell]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ResponsiveHeatmapLayout(
            prefersLargerCells: dynamicTypeSize.isAccessibilitySize
        ) {
            ForEach(cells) { cell in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(color(for: cell.level))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("近期学习热力图")
    }

    private func color(for level: Int?) -> Color {
        switch level {
        case nil:
            LearnNowPalette.shadowDark.opacity(0.10)
        case 0:
            LearnNowPalette.color(for: .mint).opacity(0.14)
        case 1:
            LearnNowPalette.color(for: .mint).opacity(0.38)
        case 2:
            LearnNowPalette.color(for: .mint).opacity(0.66)
        default:
            LearnNowPalette.color(for: .mint)
        }
    }
}

private struct ResponsiveHeatmapLayout: Layout {
    let prefersLargerCells: Bool

    private let rowCount = 4
    private let preferredCellSize: CGFloat = 20
    private let preferredLargeCellSize: CGFloat = 24
    private let spacing: CGFloat = 6

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let metrics = metrics(
            for: proposedWidth(proposal.width),
            itemCount: subviews.count
        )
        return CGSize(width: metrics.containerWidth, height: metrics.height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let metrics = metrics(for: bounds.width, itemCount: subviews.count)
        let leadingInset = max(0, (bounds.width - metrics.contentWidth) / 2)
        let hiddenItemCount = subviews.count - metrics.visibleItemCount

        for subview in subviews.prefix(hiddenItemCount) {
            subview.place(
                at: CGPoint(x: bounds.minX, y: bounds.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: 0, height: 0)
            )
        }

        for (index, subview) in subviews.suffix(metrics.visibleItemCount).enumerated() {
            let column = index % metrics.columnCount
            let row = index / metrics.columnCount
            let x = bounds.minX
                + leadingInset
                + CGFloat(column) * (metrics.cellSize + spacing)
            let y = bounds.minY + CGFloat(row) * (metrics.cellSize + spacing)

            subview.place(
                at: CGPoint(x: x, y: y),
                anchor: .topLeading,
                proposal: ProposedViewSize(
                    width: metrics.cellSize,
                    height: metrics.cellSize
                )
            )
        }
    }

    private func proposedWidth(_ width: CGFloat?) -> CGFloat {
        guard let width, width.isFinite else {
            return 360
        }
        return max(width, 1)
    }

    private func metrics(for availableWidth: CGFloat, itemCount: Int) -> Metrics {
        let preferredSize = prefersLargerCells
            ? preferredLargeCellSize
            : preferredCellSize
        let proposedColumnCount = max(
            1,
            Int(
                (
                    (availableWidth + spacing)
                    / (preferredSize + spacing)
                ).rounded()
            )
        )
        let maximumCompleteColumnCount = max(1, itemCount / rowCount)
        let columnCount = min(
            proposedColumnCount,
            maximumCompleteColumnCount
        )
        let visibleItemCount = min(itemCount, columnCount * rowCount)
        let availableCellSize =
            (availableWidth - CGFloat(columnCount - 1) * spacing)
            / CGFloat(columnCount)
        let cellSize = max(1, availableCellSize)
        let visibleRowCount = max(
            1,
            Int(ceil(Double(visibleItemCount) / Double(columnCount)))
        )
        let contentWidth = requiredWidth(
            columnCount: columnCount,
            cellSize: cellSize
        )
        let height =
            CGFloat(visibleRowCount) * cellSize
            + CGFloat(visibleRowCount - 1) * spacing

        return Metrics(
            containerWidth: availableWidth,
            contentWidth: contentWidth,
            height: height,
            cellSize: cellSize,
            columnCount: columnCount,
            visibleItemCount: visibleItemCount
        )
    }

    private func requiredWidth(
        columnCount: Int,
        cellSize: CGFloat
    ) -> CGFloat {
        CGFloat(columnCount) * cellSize
            + CGFloat(columnCount - 1) * spacing
    }

    private struct Metrics {
        let containerWidth: CGFloat
        let contentWidth: CGFloat
        let height: CGFloat
        let cellSize: CGFloat
        let columnCount: Int
        let visibleItemCount: Int
    }
}

private struct ProfileMemoryTrendContent: View {
    let memoryTrend: ProfileScreenModel.MemoryTrend
    let fillsAvailableHeight: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if memoryTrend.isEmpty {
            InsetCard(contentPadding: 16) {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 12) {
                        memoryEmptyIcon
                        memoryEmptyCopy
                    }
                } else {
                    HStack(spacing: 14) {
                        memoryEmptyIcon
                        memoryEmptyCopy
                    }
                }
            }
            .accessibilityIdentifier("profile.memory.empty")
            .frame(
                maxHeight: fillsAvailableHeight ? .infinity : nil,
                alignment: .center
            )
        } else {
            VStack(alignment: .leading, spacing: 10) {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 8) {
                        currentValue
                        predictedValue
                    }
                } else {
                    HStack {
                        currentValue
                        Spacer()
                        predictedValue
                    }
                }

                trendChart
            }
            .frame(
                maxHeight: fillsAvailableHeight ? .infinity : nil,
                alignment: .top
            )
        }
    }

    @ViewBuilder
    private var trendChart: some View {
        if fillsAvailableHeight {
            chart
                .frame(minHeight: 92, maxHeight: .infinity)
        } else {
            chart
                .frame(height: 120)
        }
    }

    private var chart: some View {
        MemoryTrendChart(values: memoryTrend.values)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "记忆趋势，当前 \(memoryTrend.currentText ?? "未知")，7 天后 \(memoryTrend.seventhDayText ?? "未知")，目标百分之九十"
            )
    }

    private var memoryEmptyIcon: some View {
        Image(systemName: "brain.head.profile")
            .font(.title2.weight(.bold))
            .foregroundStyle(LearnNowPalette.color(for: .blue))
    }

    private var memoryEmptyCopy: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("完成首次复习后生成趋势")
                .font(LearnNowTypography.cardTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)

            Text("LearnNow 会依据 FSRS 预测未来 7 天的平均记忆保持率。")
                .font(LearnNowTypography.body)
                .foregroundStyle(LearnNowPalette.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var currentValue: some View {
        MemoryTrendValue(title: "当前保持率", value: memoryTrend.currentText ?? "—")
    }

    private var predictedValue: some View {
        MemoryTrendValue(title: "7 天预测", value: memoryTrend.seventhDayText ?? "—")
    }
}

private struct MemoryTrendValue: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(LearnNowTypography.caption)
                .foregroundStyle(LearnNowPalette.textMuted)

            Text(value)
                .font(LearnNowTypography.sectionTitle)
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
                    .font(LearnNowTypography.caption)
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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        SoftCard(contentPadding: LearnNowSpacing.compactGap) {
            VStack(spacing: 0) {
                ForEach(Array(shortcuts.enumerated()), id: \.element.id) { index, shortcut in
                    Button {
                        onSelect(shortcut.kind)
                    } label: {
                        HStack(spacing: ProfileShortcutLayout.horizontalSpacing) {
                            ZStack {
                                Circle()
                                    .fill(LearnNowPalette.base)
                                    .frame(
                                        width: ProfileShortcutLayout.iconSize,
                                        height: ProfileShortcutLayout.iconSize
                                    )
                                    .modifier(
                                        InsetSurface(
                                            cornerRadius: ProfileShortcutLayout.iconSize / 2
                                        )
                                    )

                                Image(systemName: shortcut.systemImage)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(LearnNowPalette.color(for: shortcut.accent))
                            }

                            VStack(
                                alignment: .leading,
                                spacing: ProfileShortcutLayout.copySpacing
                            ) {
                                Text(shortcut.title)
                                    .font(LearnNowTypography.cardTitle)
                                    .foregroundStyle(LearnNowPalette.textPrimary)

                                Text(shortcut.subtitle)
                                    .font(LearnNowTypography.caption)
                                    .foregroundStyle(LearnNowPalette.textMuted)
                                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }
                        .padding(.vertical, LearnNowSpacing.compactGap)
                        .frame(minHeight: ProfileShortcutLayout.minimumRowHeight)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("profile.shortcut.\(shortcut.kind.rawValue)")

                    if index < shortcuts.count - 1 {
                        Divider()
                            .overlay(LearnNowPalette.shadowDark.opacity(0.16))
                            .padding(
                                .leading,
                                ProfileShortcutLayout.dividerLeadingInset
                            )
                    }
                }
            }
        }
    }
}

private enum ProfileShortcutLayout {
    static let horizontalSpacing: CGFloat = 14
    static let iconSize: CGFloat = 42
    static let copySpacing: CGFloat = 4
    static let minimumRowHeight: CGFloat = 62
    static let dividerLeadingInset = iconSize + horizontalSpacing
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
