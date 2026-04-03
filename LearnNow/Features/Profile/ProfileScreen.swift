import SwiftUI

struct ProfileScreen: View {
    let model: ProfileScreenModel
    @Binding var reminderTime: Date
    @Binding var remindersEnabled: Bool
    @Binding var isNightModeEnabled: Bool
    let onContinueLearning: () -> Void
    let onOpenFavorites: () -> Void

    var body: some View {
        ScreenScaffold {
            ScreenHeader(title: model.title, subtitle: model.subtitle)

            ProfileHeaderCard(
                profileName: model.profileName,
                profileHeadline: model.profileHeadline,
                profileLevel: model.profileLevel
            )

            ProfileOverviewCard(model: model.overviewCTA, onContinueLearning: onContinueLearning)

            FavoriteSummaryCard(
                title: model.favoritesTitle,
                subtitle: model.favoritesSubtitle,
                summary: model.favoriteSummary,
                onOpenFavorites: onOpenFavorites
            )

            InsightCard(title: model.retentionTitle) {
                InsetCard(contentPadding: 14) {
                    RetentionChart(
                        primarySeries: model.primarySeries,
                        baselineSeries: model.baselineSeries
                    )
                    .frame(height: 180)
                }
            }

            SectionHeader(title: model.knowledgeTitle)

            SoftCard(contentPadding: 20) {
                VStack(spacing: 22) {
                    ForEach(model.knowledgeMetrics) { metric in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(metric.title)
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.textPrimary)

                                Spacer()

                                Text("\(Int(metric.progress * 100))%")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.color(for: metric.accent))
                            }

                            ProgressTrack(progress: metric.progress, accent: metric.accent, height: 8)
                        }
                    }
                }
            }

            SectionHeader(title: model.settingsTitle, subtitle: model.settingsSubtitle)

            ReminderSettingsCard(
                title: model.reminderTitle,
                subtitle: model.reminderSubtitle,
                timeText: model.reminderTimeText,
                reminderTime: $reminderTime,
                remindersEnabled: $remindersEnabled
            )

            AppearanceSettingsCard(
                title: model.appearanceTitle,
                subtitle: model.appearanceSubtitle,
                isNightModeEnabled: $isNightModeEnabled
            )
        }
        .accessibilityIdentifier("screen.profile")
    }
}

private struct ProfileHeaderCard: View {
    let profileName: String
    let profileHeadline: String
    let profileLevel: String

    var body: some View {
        SoftCard(contentPadding: 20) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [LearnNowPalette.color(for: .purple), LearnNowPalette.color(for: .blue)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)
                        .softOuter(radius: 10, x: 4, y: 6)

                    Image(systemName: "person.fill")
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(.white.opacity(0.96))
                }

                VStack(alignment: .leading, spacing: 8) {
                    NeumorphicPill(text: profileLevel, accent: .purple)

                    Text(profileName)
                        .font(LearnNowTypography.cardHeadline)
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Text(profileHeadline)
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

private struct ProfileOverviewCard: View {
    let model: ProfileScreenModel.OverviewCTA
    let onContinueLearning: () -> Void

    var body: some View {
        SoftCard(contentPadding: 22) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        NeumorphicPill(text: "学习概览", accent: .blue)

                        Text(model.title)
                            .font(LearnNowTypography.cardHeadline)
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        Text(model.subtitle)
                            .font(LearnNowTypography.body)
                            .foregroundStyle(LearnNowPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    InsetCircle(size: 74) {
                        VStack(spacing: 4) {
                            Text("XP")
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textMuted)

                            Text(model.xpText.replacingOccurrences(of: "累计获得 ", with: "").replacingOccurrences(of: " XP", with: ""))
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(LearnNowPalette.color(for: .blue))
                        }
                    }
                }

                HStack {
                    Text(model.badge)
                        .font(LearnNowTypography.screenSubtitle)
                        .foregroundStyle(LearnNowPalette.textMuted)

                    Spacer()

                    Text(model.progressText)
                        .font(LearnNowTypography.label)
                        .foregroundStyle(LearnNowPalette.color(for: .blue))
                }

                ProgressTrack(progress: model.progress, accent: .blue, height: 10)

                MetricGridSection(items: model.metrics, columns: 3, spacing: 12) { metric in
                    ProfileMetricCard(metric: metric)
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("本月学习记录")
                            .font(LearnNowTypography.cardTitle)
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        Spacer()

                        Text(model.xpText)
                            .font(LearnNowTypography.screenSubtitle)
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }

                    StudyHeatmapGrid(cells: model.heatmap)
                }

                FullWidthButton(
                    title: "继续学习",
                    accent: .blue,
                    systemImage: "play.fill",
                    action: onContinueLearning
                )
            }
        }
    }
}

private struct ProfileMetricCard: View {
    let metric: LearnNowHeaderMetric

    var body: some View {
        InsetCard(contentPadding: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(metric.title)
                    .font(LearnNowTypography.screenSubtitle)
                    .foregroundStyle(LearnNowPalette.textMuted)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(metric.value)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.color(for: metric.accent))

                    if let unit = metric.unit {
                        Text(unit)
                            .font(LearnNowTypography.screenSubtitle)
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct FavoriteSummaryCard: View {
    let title: String
    let subtitle: String
    let summary: ProfileScreenModel.FavoriteSummary
    let onOpenFavorites: () -> Void

    var body: some View {
        SoftCard(contentPadding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(LearnNowTypography.cardHeadline)
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        Text(subtitle)
                            .font(LearnNowTypography.body)
                            .foregroundStyle(LearnNowPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 6) {
                        Text(summary.countText)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(LearnNowPalette.color(for: .pink))

                        Text(summary.masteredText)
                            .font(LearnNowTypography.screenSubtitle)
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }

                if summary.highlights.isEmpty {
                    InsetCard {
                        Text("还没有收藏卡片。遇到值得反复看的内容时，把它们放到这里。")
                            .font(LearnNowTypography.body)
                            .foregroundStyle(LearnNowPalette.textSecondary)
                    }
                } else {
                    VStack(spacing: 12) {
                        ForEach(summary.highlights) { highlight in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(LearnNowPalette.base)
                                        .frame(width: 38, height: 38)
                                        .modifier(InsetSurface(cornerRadius: 19))

                                    Image(systemName: "bookmark.fill")
                                        .font(.system(size: 13, weight: .black))
                                        .foregroundStyle(LearnNowPalette.color(for: highlight.accent))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(highlight.title)
                                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                                        .foregroundStyle(LearnNowPalette.textPrimary)

                                    Text(highlight.subtitle)
                                        .font(LearnNowTypography.screenSubtitle)
                                        .foregroundStyle(LearnNowPalette.textMuted)
                                }

                                Spacer()
                            }
                        }
                    }
                }

                FullWidthButton(
                    title: summary.actionTitle,
                    accent: .pink,
                    systemImage: "bookmark.fill",
                    action: onOpenFavorites
                )
            }
        }
    }
}

private struct ReminderSettingsCard: View {
    let title: String
    let subtitle: String
    let timeText: String
    @Binding var reminderTime: Date
    @Binding var remindersEnabled: Bool

    var body: some View {
        InsetCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    SettingsIcon(systemImage: "bell.badge.fill", accent: .blue)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(LearnNowTypography.cardTitle)
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        Text(subtitle)
                            .font(LearnNowTypography.body)
                            .foregroundStyle(LearnNowPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Toggle("", isOn: $remindersEnabled)
                        .labelsHidden()
                        .tint(LearnNowPalette.color(for: .blue))
                }

                Divider()
                    .overlay(LearnNowPalette.shadowDark.opacity(0.18))

                HStack {
                    Text("当前时间")
                        .font(LearnNowTypography.screenSubtitle)
                        .foregroundStyle(LearnNowPalette.textMuted)

                    Spacer()

                    Text(remindersEnabled ? timeText : "已关闭")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)
                }

                if remindersEnabled {
                    DatePicker(
                        "提醒时间",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .font(LearnNowTypography.body)
                    .tint(LearnNowPalette.color(for: .blue))
                }
            }
        }
    }
}

private struct AppearanceSettingsCard: View {
    let title: String
    let subtitle: String
    @Binding var isNightModeEnabled: Bool

    var body: some View {
        InsetCard {
            HStack(alignment: .top, spacing: 12) {
                SettingsIcon(
                    systemImage: isNightModeEnabled ? "moon.stars.fill" : "sun.max.fill",
                    accent: isNightModeEnabled ? .purple : .amber
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(LearnNowTypography.cardTitle)
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Text(subtitle)
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(isNightModeEnabled ? "当前为夜间模式" : "当前为白天模式")
                        .font(LearnNowTypography.screenSubtitle)
                        .foregroundStyle(LearnNowPalette.textMuted)
                }

                Spacer()

                Toggle("", isOn: $isNightModeEnabled)
                    .labelsHidden()
                    .tint(LearnNowPalette.color(for: isNightModeEnabled ? .purple : .amber))
            }
        }
    }
}

private struct SettingsIcon: View {
    let systemImage: String
    let accent: LearnNowAccent

    var body: some View {
        ZStack {
            Circle()
                .fill(LearnNowPalette.base)
                .frame(width: 42, height: 42)
                .modifier(InsetSurface(cornerRadius: 21))

            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(LearnNowPalette.color(for: accent))
        }
    }
}

private struct StudyHeatmapGrid: View {
    let cells: [LearnNowHeatCell]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(cells) { cell in
                Group {
                    if cell.level == 0 {
                        Circle()
                            .fill(fillColor(for: cell.level))
                            .modifier(OuterSurface(cornerRadius: 9))
                    } else {
                        Circle()
                            .fill(fillColor(for: cell.level))
                            .modifier(InsetSurface(cornerRadius: 9))
                    }
                }
                .frame(height: 18)
                .opacity(cell.level == nil ? 0 : 1)
            }
        }
    }

    private func fillColor(for level: Int?) -> Color {
        switch level {
        case nil:
            .clear
        case 0:
            LearnNowPalette.base
        case 1:
            LearnNowPalette.color(for: .mint)
        case 2:
            LearnNowPalette.color(for: .blue)
        default:
            LearnNowPalette.color(for: .pink)
        }
    }
}

private struct RetentionChart: View {
    let primarySeries: [Double]
    let baselineSeries: [Double]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    Divider().background(LearnNowPalette.shadowDark.opacity(0.5))
                    Spacer()
                    Divider().background(LearnNowPalette.shadowDark.opacity(0.5))
                    Spacer()
                }

                ChartAreaShape(values: primarySeries)
                    .fill(LearnNowPalette.gradient(for: .blue).opacity(0.28))

                ChartLineShape(values: baselineSeries)
                    .stroke(
                        LearnNowPalette.shadowDark,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 5])
                    )

                ChartLineShape(values: primarySeries)
                    .stroke(
                        LearnNowPalette.color(for: .blue),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )

                ForEach(primarySeries.indices, id: \.self) { index in
                    let point = point(at: index, values: primarySeries, size: geometry.size)

                    Circle()
                        .fill(LearnNowPalette.base)
                        .frame(width: 9, height: 9)
                        .overlay(
                            Circle()
                                .stroke(LearnNowPalette.color(for: .blue), lineWidth: 2)
                        )
                        .position(point)
                }
            }
        }
    }

    private func point(at index: Int, values: [Double], size: CGSize) -> CGPoint {
        let step = size.width / CGFloat(max(values.count - 1, 1))
        let x = CGFloat(index) * step
        let y = (1 - values[index]) * size.height
        return CGPoint(x: x, y: y)
    }
}

private struct ChartLineShape: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        Path { path in
            guard !values.isEmpty else { return }

            let step = rect.width / CGFloat(max(values.count - 1, 1))
            for index in values.indices {
                let point = CGPoint(
                    x: CGFloat(index) * step,
                    y: (1 - values[index]) * rect.height
                )

                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
        }
    }
}

private struct ChartAreaShape: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        var path = ChartLineShape(values: values).path(in: rect)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview("Profile") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        ProfileScreenPreview()
    }
}

private struct ProfileScreenPreview: View {
    @State private var flow = LearnNowFlowState.profilePreview

    var body: some View {
        ProfileScreen(
            model: flow.profileScreenModel,
            reminderTime: $flow.reminderTime,
            remindersEnabled: $flow.remindersEnabled,
            isNightModeEnabled: $flow.isNightModeEnabled,
            onContinueLearning: {},
            onOpenFavorites: {}
        )
    }
}
