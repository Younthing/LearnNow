import SwiftUI

struct AppShellView: View {
    @Bindable var store: LearnNowAppStore

    /// `true` when the app is launched by UI tests with `-UIAnimationsDisabled YES`.
    private var animationsDisabled: Bool {
        UserDefaults.standard.bool(forKey: "UIAnimationsDisabled")
    }

    var body: some View {
        GeometryReader { geometry in
            let contentSpacing = contentSpacing(for: geometry.size.height)

            ZStack {
                LearnNowPalette.canvas
                    .ignoresSafeArea()

                BackgroundGlow()
                    .ignoresSafeArea()

                tabContent(spacing: contentSpacing)
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        FloatingTabBar(selectedTab: store.flow.selectedTab) { tab in
                            store.selectTab(tab)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, contentSpacing)
                        .padding(.bottom, 18)
                    }
            }
        }
        .environment(\.learnNowAnimationsEnabled, !animationsDisabled)
        .alert(
            "暂时无法保存",
            isPresented: Binding(
                get: { store.lastActionError != nil },
                set: { if !$0 { store.lastActionError = nil } }
            )
        ) {
            Button("知道了", role: .cancel) { store.lastActionError = nil }
        } message: {
            Text(store.lastActionError ?? "请稍后重试。")
        }
    }

    private func tabContent(spacing: CGFloat) -> some View {
        ZStack {
            tabStage(tab: .home) {
                HomeScreen(
                    model: store.flow.homeScreenModel,
                    cardSpacing: spacing,
                    onContinueLearning: { store.openLesson() }
                )
            }

            tabStage(tab: .routes) {
                RoutesJourneyContainer(store: store)
            }

            tabStage(tab: .anki) {
                ReviewBoardContainer(store: store)
            }

            tabStage(tab: .profile) {
                ProfileScreen(
                    model: store.flow.profileScreenModel,
                    reminderTime: Binding(
                        get: { store.flow.reminderTime },
                        set: { store.setReminderTime($0) }
                    ),
                    remindersEnabled: Binding(
                        get: { store.flow.remindersEnabled },
                        set: { store.setRemindersEnabled($0) }
                    ),
                    isNightModeEnabled: Binding(
                        get: { store.flow.isNightModeEnabled },
                        set: { store.setNightModeEnabled($0) }
                    ),
                    onContinueLearning: { store.openLesson() },
                    onOpenFavorites: { store.openFavoritedReviewBoard() }
                )
            }
        }
        .animation(
            animationsDisabled ? nil : .spring(response: 0.4, dampingFraction: 0.75),
            value: store.flow.currentScreen
        )
    }

    private func contentSpacing(for height: CGFloat) -> CGFloat {
        switch height {
        case ..<700:
            10
        case ..<820:
            12
        default:
            14
        }
    }

    private func tabStage<Content: View>(
        tab: LearnNowTab,
        @ViewBuilder content: () -> Content
    ) -> some View {
        StableStage(isActive: store.flow.currentScreen == screen(for: tab)) {
            content()
        }
    }

    private func screen(for tab: LearnNowTab) -> LearnNowScreen {
        switch tab {
        case .home:
            .home
        case .routes:
            .routes
        case .anki:
            .anki
        case .profile:
            .profile
        }
    }
}

private struct RoutesJourneyContainer: View {
    @Bindable var store: LearnNowAppStore

    var body: some View {
        ZStack {
            routesStage(destination: .overview) {
                RoutesScreen(model: store.flow.routesOverviewModel) { _ in
                    store.openPath()
                }
            }

            routesStage(destination: .path) {
                PathScreen(
                    model: store.flow.pathScreenModel,
                    onBack: { store.showRoutes() },
                    onSelectTrack: { store.selectRouteTrack($0) },
                    onOpenLesson: { store.openLesson(moduleID: $0) }
                )
            }

            routesStage(destination: .lesson) {
                LessonScreen(
                    model: store.flow.lessonScreenModel,
                    onBack: { store.openPathForLoadedLesson() },
                    onSelectPage: { store.setCurrentLessonPageIndex($0) },
                    onAnswer: { store.answerCurrentLesson(with: $0) },
                    onCallToAction: { store.handleLessonCallToAction($0) }
                )
            }

            routesStage(destination: .completion) {
                CompletionScreen(
                    model: store.flow.completionScreenModel,
                    isActive: store.flow.routesDestination == .completion,
                    onContinueLearning: { store.openNextLesson() },
                    onFinish: { store.finishLearning() },
                    onOpenReviewBoard: { store.openReviewBoard() }
                )
            }
        }
    }

    private func routesStage<Content: View>(
        destination: LearnNowRoutesDestination,
        @ViewBuilder content: () -> Content
    ) -> some View {
        StableStage(isActive: store.flow.routesDestination == destination) {
            content()
        }
    }
}

private struct ReviewBoardContainer: View {
    @Bindable var store: LearnNowAppStore

    private var activeSheet: Binding<LearnNowReviewSheet?> {
        Binding(
            get: { store.flow.activeReviewSheet },
            set: { newValue in
                if let newValue {
                    store.flow.activeReviewSheet = newValue
                } else {
                    store.dismissReviewSheet()
                }
            }
        )
    }

    var body: some View {
        ReviewBoardScreen(
            model: store.flow.reviewBoardModel,
            onOpenFilters: { store.openReviewCardPool() },
            onFlipCard: { store.flipCurrentReviewCard() },
            onRate: { store.rateCurrentReviewCard($0) },
            onEmptyAction: { store.handleReviewEmptyPrimaryAction() }
        )
        .sheet(item: activeSheet) { sheet in
            switch sheet {
            case .cardPool:
                ReviewFiltersSheet(
                    model: store.flow.reviewFiltersSheetModel,
                    onReset: { store.resetDraftReviewFilters() },
                    onSelectTime: { store.setDraftTimeFilter($0) },
                    onToggleTopic: { store.toggleDraftTopic($0) },
                    onToggleModule: { store.toggleDraftModule($0) },
                    onSelectMastery: { store.setDraftMasteryFilter($0) },
                    onSelectFavorite: { store.setDraftFavoriteFilter($0) },
                    onToggleFavorite: { store.toggleReviewCardFavorited(id: $0) },
                    onToggleMastered: { store.toggleReviewCardMastered(id: $0) },
                    onApply: { store.applyReviewCardPoolFilters() }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

private struct StableStage<Content: View>: View {
    let isActive: Bool
    @ViewBuilder let content: Content

    var body: some View {
        content
            .opacity(isActive ? 1 : 0)
            .zIndex(isActive ? 1 : 0)
            .allowsHitTesting(isActive)
            .accessibilityHidden(!isActive)
    }
}

#Preview("App Shell") {
    AppShellPreviewContainer()
}

private struct AppShellPreviewContainer: View {
    @State private var store = LearnNowAppStore()

    var body: some View {
        AppShellView(store: store)
    }
}
