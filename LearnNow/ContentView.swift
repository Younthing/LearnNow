//
//  ContentView.swift
//  LearnNow
//
//  Created by fanxi on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    @State private var flow = LearnNowFlowState()

    /// `true` when the app is launched by UI tests with `-UIAnimationsDisabled YES`.
    private var animationsDisabled: Bool {
        UserDefaults.standard.bool(forKey: "UIAnimationsDisabled")
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LearnNowPalette.canvas
                .ignoresSafeArea()

            BackgroundGlow()
                .ignoresSafeArea()

            screenView
                .padding(.bottom, 112)
                .animation(
                    animationsDisabled
                        ? nil
                        : .spring(response: 0.4, dampingFraction: 0.75),
                    value: flow.currentScreen
                )

            FloatingTabBar(selectedTab: flow.selectedTab) { tab in
                flow.selectTab(tab)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
    }

    @ViewBuilder
    private var screenView: some View {
        switch flow.currentScreen {
        case .home:
            HomeScreen(flow: flow) {
                flow.openLesson()
            }
        case .routes:
            RoutesScreen(flow: flow) {
                flow.openPath()
            }
        case .path:
            PathScreen(flow: flow, onBack: {
                flow.showRoutes()
            }, onOpenLesson: {
                flow.openLesson()
            })
        case .lesson:
            LessonScreen(flow: $flow)
        case .completion:
            CompletionScreen(flow: flow, onFinish: {
                flow.finishLearning()
            }, onOpenReviewBoard: {
                flow.openReviewBoard()
            })
        case .anki:
            ReviewBoardScreen(flow: $flow)
        case .dash:
            DashboardScreen(flow: flow)
        }
    }
}

private struct HomeScreen: View {
    let flow: LearnNowFlowState
    let onContinueLearning: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                ScreenHeader(
                    title: "学习概览",
                    subtitle: flow.todayLabel,
                    trailing: {
                        AvatarBadge()
                    }
                )

                SoftCard {
                    HStack(alignment: .center, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("绝佳状态")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textPrimary)
                            Text("累计获得 \(flow.totalXP) XP")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }

                        Spacer()

                        InsetCircle(size: 72) {
                            VStack(spacing: 2) {
                                Text("\(flow.streakDays)")
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.color(for: .pink))
                                Text("天连胜")
                                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.textMuted)
                            }
                        }
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(flow.homeMetrics) { metric in
                        InsetCard {
                            VStack(spacing: 10) {
                                Text(metric.title)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.textMuted)

                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text(metric.value)
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundStyle(LearnNowPalette.color(for: metric.accent))
                                    if let unit = metric.unit {
                                        Text(unit)
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundStyle(LearnNowPalette.textMuted)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }

                sectionTitle("继续学习")

                SoftCard(contentPadding: 20) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                NeumorphicPill(text: "第3单元 · 课时4", accent: .blue)
                                Text("假设检验：均值比较")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.textPrimary)
                            }

                            Spacer()

                            CircleIconButton(
                                systemImage: "play.fill",
                                accent: .blue,
                                action: onContinueLearning
                            )
                        }

                        ProgressTrack(progress: 0.40, accent: .blue, height: 12)

                        HStack {
                            Spacer()
                            Text("完成 40%")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }
                    }
                }

                SoftCard(contentPadding: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("本月学习记录")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }

                        HeatmapGrid(cells: flow.heatmap)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .accessibilityIdentifier("screen.home")
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .heavy, design: .rounded))
            .foregroundStyle(LearnNowPalette.textPrimary)
    }
}

private struct RoutesScreen: View {
    let flow: LearnNowFlowState
    let onOpenCurrentRoute: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                ScreenHeader(title: "学习路线", subtitle: "选择你的探索方向")

                VStack(spacing: 20) {
                    ForEach(flow.routes) { route in
                        RouteCard(route: route) {
                            if route.interactive {
                                onOpenCurrentRoute()
                            }
                        }
                        .accessibilityIdentifier(route.id == "datascience" ? "route.datascience" : "")
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .accessibilityIdentifier("screen.routes")
    }
}

private struct PathScreen: View {
    let flow: LearnNowFlowState
    let onBack: () -> Void
    let onOpenLesson: () -> Void
    
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
                                if node.status == .current {
                                    onOpenLesson()
                                }
                            }
                        )
                        .opacity(animateNodes ? 1 : 0)
                        .offset(y: animateNodes ? 0 : 30)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateNodes)
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

private struct LessonScreen: View {
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
                CircleIconButton(systemImage: "arrow.left", accent: .blue, action: {
                    flow.openPath()
                })

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

private struct CompletionScreen: View {
    let flow: LearnNowFlowState
    let onFinish: () -> Void
    let onOpenReviewBoard: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 26) {
                Spacer(minLength: 60)

                InsetCircle(size: 112) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(LearnNowPalette.color(for: .mint))
                }

                Text("课程通关！")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)

                SoftCard {
                    HStack {
                        CompletionStat(
                            icon: "flame.fill",
                            value: "\(flow.streakDays)",
                            title: "天连胜保持",
                            accent: .pink
                        )

                        Divider()
                            .frame(height: 48)
                            .overlay(LearnNowPalette.textMuted.opacity(0.25))

                        CompletionStat(
                            icon: "bolt.fill",
                            value: "+15",
                            title: "XP 经验值",
                            accent: .blue
                        )
                    }
                }

                InsetCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("已提炼 3 张记忆卡片", systemImage: "square.stack.3d.up")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        FlowLayout(items: flow.generatedReviewTags) { tag in
                            NeumorphicPill(text: tag, accent: .blue)
                        }

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(LearnNowPalette.color(for: .blue))
                            Text("智能调度系统已将考点放入你的明日复习池中。")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }
                    }
                }

                VStack(spacing: 16) {
                    FullWidthButton(title: "完成学习", accent: .blue, systemImage: "checkmark", action: onFinish)
                    FullWidthButton(title: "去复习看板看看", accent: nil, action: onOpenReviewBoard)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .accessibilityIdentifier("screen.completion")
    }
}

private struct ReviewBoardScreen: View {
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

private struct DashboardScreen: View {
    let flow: LearnNowFlowState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                ScreenHeader(title: "学习数据", subtitle: "你的进步雷达")

                SoftCard(contentPadding: 20) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("艾宾浩斯记忆曲线")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .center)

                        InsetCard(contentPadding: 14) {
                            RetentionChart(
                                primarySeries: flow.retentionSeries,
                                baselineSeries: flow.baselineSeries
                            )
                            .frame(height: 180)
                        }
                    }
                }

                Text("知识图谱")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)

                SoftCard(contentPadding: 20) {
                    VStack(spacing: 22) {
                        ForEach(flow.knowledgeMetrics) { metric in
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
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .accessibilityIdentifier("screen.dash")
    }
}

private struct ScreenHeader<Trailing: View>: View {
    let title: String
    var subtitle: String?
    var centered = false
    @ViewBuilder var trailing: () -> Trailing

    init(
        title: String,
        subtitle: String? = nil,
        centered: Bool = false,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.centered = centered
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: centered ? .center : .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: centered ? .center : .leading)

            if !centered {
                trailing()
            }
        }
    }
}

private struct AvatarBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [LearnNowPalette.color(for: .blue), LearnNowPalette.color(for: .purple)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 52, height: 52)
                .softOuter(radius: 8, x: 4, y: 4)

            Image(systemName: "person.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white.opacity(0.95))
        }
    }
}

private struct RouteCard: View {
    let route: LearnNowRoute
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SoftCard(contentPadding: 20) {
                HStack(alignment: .top, spacing: 16) {
                    InsetCircle(size: 52) {
                        Image(systemName: iconName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(LearnNowPalette.color(for: route.accent))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text(route.title)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .multilineTextAlignment(.leading)

                        Text(route.subtitle)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textMuted)
                            .multilineTextAlignment(.leading)

                        HStack {
                            Text(route.progress == 0 ? "未开始" : "已完成 \(Int(route.progress * 100))%")
                            Spacer()
                            Text(route.cta)
                                .foregroundStyle(LearnNowPalette.color(for: route.accent))
                        }
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textMuted)

                        ProgressTrack(progress: route.progress, accent: route.accent, height: 6)
                    }
                }
            }
            .opacity(route.interactive ? 1 : 0.96)
        }
        .buttonStyle(.plain)
        .disabled(!route.interactive)
    }

    private var iconName: String {
        switch route.id {
        case "datascience": "cpu"
        case "design": "paintpalette"
        default: "chevron.left.forwardslash.chevron.right"
        }
    }
}

private struct PathNodeRow: View {
    let node: LearnNowPathNode
    let showsLineBelow: Bool
    let onTap: () -> Void
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(spacing: 0) {
                nodeBadge

                if showsLineBelow {
                    Capsule()
                        .fill(LearnNowPalette.color(for: node.status == .done ? .mint : (node.status == .current ? .blue : .purple)).opacity(node.status == .locked ? 0.2 : 0.6))
                        .frame(width: 4)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 8)
                }
            }
            .frame(width: 48)

            VStack {
                if node.status == .current {
                    Button(action: onTap) {
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
                    }
                    .buttonStyle(SoftPressStyle(cornerRadius: 22))
                    .accessibilityIdentifier("path.currentModule")
                } else {
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
            }
        }
        .padding(.bottom, node.status == .current ? 24 : 0)
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
                        LessonOptionButton(
                            option: option,
                            page: page,
                            action: {
                                onAnswer(option.id)
                            }
                        )
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

private struct CompletionStat: View {
    let icon: String
    let value: String
    let title: String
    let accent: LearnNowAccent

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                Text(value)
            }
            .font(.system(size: 26, weight: .black, design: .rounded))
            .foregroundStyle(LearnNowPalette.color(for: accent))

            Text(title)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(LearnNowPalette.textMuted)
        }
        .frame(maxWidth: .infinity)
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

private struct FloatingTabBar: View {
    let selectedTab: LearnNowTab
    let onSelect: (LearnNowTab) -> Void

    var body: some View {
        HStack(spacing: 10) {
            ForEach(LearnNowTab.allCases) { tab in
                Button {
                    onSelect(tab)
                } label: {
                    ZStack {
                        if tab == selectedTab {
                            Circle()
                                .fill(LearnNowPalette.base)
                                .frame(width: 50, height: 50)
                                .modifier(InsetSurface(cornerRadius: 25))
                        } else {
                            Circle()
                                .fill(LearnNowPalette.base)
                                .frame(width: 50, height: 50)
                                .modifier(OuterSurface(cornerRadius: 25))
                        }

                        Image(systemName: tab.systemImage)
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(tab == selectedTab ? LearnNowPalette.color(for: .blue) : LearnNowPalette.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("tab.\(tab.rawValue)")
                .accessibilityLabel(tab.title)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule(style: .continuous)
                .fill(LearnNowPalette.base)
                .modifier(OuterSurface(cornerRadius: 999))
        )
    }
}

private struct HeatmapGrid: View {
    let cells: [LearnNowHeatCell]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(cells) { cell in
                if cell.level == 0 {
                    Circle()
                        .fill(fillColor(for: cell.level))
                        .frame(height: 22)
                        .opacity(cell.level == nil ? 0 : 1)
                        .modifier(OuterSurface(cornerRadius: 11))
                } else {
                    Circle()
                        .fill(fillColor(for: cell.level))
                        .frame(height: 22)
                        .opacity(cell.level == nil ? 0 : 1)
                        .modifier(InsetSurface(cornerRadius: 11))
                }
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

private struct SoftCard<Content: View>: View {
    var contentPadding: CGFloat = 24
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(contentPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LearnNowPalette.base)
                    .modifier(OuterSurface(cornerRadius: 26))
            )
    }
}

private struct InsetCard<Content: View>: View {
    var contentPadding: CGFloat = 20
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(contentPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LearnNowPalette.base)
                    .modifier(InsetSurface(cornerRadius: 22))
            )
    }
}

private struct ProgressTrack: View {
    let progress: Double
    let accent: LearnNowAccent
    let height: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(LearnNowPalette.base)
                    .modifier(InsetSurface(cornerRadius: height / 2))

                Capsule(style: .continuous)
                    .fill(LearnNowPalette.gradient(for: accent))
                    .frame(width: max(geometry.size.width * progress, 0), height: height)
            }
        }
        .frame(height: height)
    }
}

private struct NeumorphicPill: View {
    let text: String
    let accent: LearnNowAccent
    var isSelected = false
    var isExpanded = false

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .foregroundStyle(isSelected ? LearnNowPalette.color(for: accent) : LearnNowPalette.textMuted)
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .frame(maxWidth: isExpanded ? .infinity : nil)
            .background(
                Group {
                    if isSelected {
                        Capsule(style: .continuous)
                            .fill(LearnNowPalette.base)
                            .modifier(InsetSurface(cornerRadius: 999))
                    } else {
                        Capsule(style: .continuous)
                            .fill(LearnNowPalette.base)
                            .modifier(OuterSurface(cornerRadius: 999))
                    }
                }
            )
    }
}

private struct CircleIconButton: View {
    let systemImage: String
    let accent: LearnNowAccent
    var size: CGFloat = 44
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(LearnNowPalette.base)
                .frame(width: size, height: size)
                .modifier(OuterSurface(cornerRadius: size / 2))
                .overlay {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(LearnNowPalette.color(for: accent))
                }
        }
        .buttonStyle(.plain)
    }
}

private struct InsetCircle<Content: View>: View {
    let size: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        Circle()
            .fill(LearnNowPalette.base)
            .frame(width: size, height: size)
            .modifier(InsetSurface(cornerRadius: size / 2))
            .overlay {
                content
            }
    }
}

private struct FullWidthButton: View {
    let title: String
    var accent: LearnNowAccent? = nil
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))

                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundStyle(accentColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
        }
        .buttonStyle(SoftPressStyle(cornerRadius: 999))
    }

    private var accentColor: Color {
        if let accent {
            LearnNowPalette.color(for: accent)
        } else {
            LearnNowPalette.textPrimary
        }
    }
}

private struct SoftPressStyle: ButtonStyle {
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(LearnNowPalette.base)
                            .modifier(InsetSurface(cornerRadius: cornerRadius))
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(LearnNowPalette.base)
                            .modifier(OuterSurface(cornerRadius: cornerRadius))
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#if canImport(UIKit)
import UIKit
#endif

private struct BackgroundGlow: View {
    @State private var phase = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let opacityMultiplier: Double = colorScheme == .dark ? 0.7 : 1.0
        
        ZStack {
            Circle()
                .fill(LearnNowPalette.color(for: .blue).opacity(0.35 * opacityMultiplier))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: phase ? 100 : -100, y: phase ? -200 : -350)

            Circle()
                .fill(LearnNowPalette.color(for: .purple).opacity(0.30 * opacityMultiplier))
                .frame(width: 280, height: 280)
                .blur(radius: 50)
                .offset(x: phase ? -120 : 120, y: phase ? -80 : 80)

            Circle()
                .fill(LearnNowPalette.color(for: .mint).opacity(0.35 * opacityMultiplier))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: phase ? 140 : -140, y: phase ? 250 : 380)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                phase.toggle()
            }
        }
    }
}

private struct OuterSurface: ViewModifier {
    let cornerRadius: CGFloat
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(LinearGradient(colors: [Color.white.opacity(colorScheme == .dark ? 0.15 : 0.6), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.5)
            )
            .shadow(color: LearnNowPalette.shadowDark, radius: 16, x: 0, y: 8)
    }
}

private struct InsetSurface: ViewModifier {
    let cornerRadius: CGFloat
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(Color.black.opacity(colorScheme == .dark ? 0.35 : 0.05), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.05 : 0.4), lineWidth: 1)
            )
            .shadow(color: LearnNowPalette.shadowDark.opacity(0.3), radius: 8, x: 0, y: 4)
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

private struct FlowLayout<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 84), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

private enum LearnNowPalette {
    static let base = Color.dynamic(light: 0xFFFFFF, dark: 0x1E1E24, lightOpacity: 0.55, darkOpacity: 0.5)
    static let canvas = Color.dynamic(light: 0xF4F6F9, dark: 0x07070A)
    static let textPrimary = Color.dynamic(light: 0x1E293B, dark: 0xFFFFFF, lightOpacity: 1.0, darkOpacity: 0.95)
    static let textSecondary = Color.dynamic(light: 0x475569, dark: 0xFFFFFF, lightOpacity: 1.0, darkOpacity: 0.75)
    static let textMuted = Color.dynamic(light: 0x94A3B8, dark: 0xFFFFFF, lightOpacity: 1.0, darkOpacity: 0.5)
    static let shadowDark = Color.dynamic(light: 0xA4ADC1, dark: 0x000000, lightOpacity: 0.4, darkOpacity: 0.5)
    static let shadowLight = Color.dynamic(light: 0xFFFFFF, dark: 0xFFFFFF, lightOpacity: 0.9, darkOpacity: 0.1)

    static func color(for accent: LearnNowAccent) -> Color {
        switch accent {
        case .blue:
            return Color.dynamic(light: 0x2563EB, dark: 0x5E6AD2)
        case .pink:
            return Color.dynamic(light: 0xEC4899, dark: 0xF43F5E)
        case .mint:
            return Color.dynamic(light: 0x10B981, dark: 0x10B981)
        case .purple:
            return Color.dynamic(light: 0x8B5CF6, dark: 0x8B5CF6)
        case .amber:
            return Color.dynamic(light: 0xF59E0B, dark: 0xF59E0B)
        }
    }

    static func gradient(for accent: LearnNowAccent) -> LinearGradient {
        let col = color(for: accent)
        return LinearGradient(
            colors: [col.opacity(0.85), col],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private extension View {
    func softOuter(radius: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        self
            .shadow(color: LearnNowPalette.shadowDark, radius: radius, x: 0, y: y)
    }
}

private extension Color {
#if canImport(UIKit)
    static func dynamic(light: UInt, dark: UInt, lightOpacity: Double = 1.0, darkOpacity: Double = 1.0) -> Color {
        Color(UIColor { trait in
            let hex = trait.userInterfaceStyle == .dark ? dark : light
            let opacity = trait.userInterfaceStyle == .dark ? darkOpacity : lightOpacity
            
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255.0,
                green: CGFloat((hex >> 8) & 0xFF) / 255.0,
                blue: CGFloat(hex & 0xFF) / 255.0,
                alpha: CGFloat(opacity)
            )
        })
    }
#endif

    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

#Preview {
    ContentView()
}
