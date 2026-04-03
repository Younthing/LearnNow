import SwiftUI

struct AppShellView: View {
    @Binding var flow: LearnNowFlowState

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

            ZStack {
                tabStage(tab: .home) {
                    HomeScreen(
                        model: flow.homeScreenModel,
                        onContinueLearning: { flow.openLesson() },
                        onOpenReviewBoard: { flow.openReviewBoard() },
                        onOpenRoutes: { flow.showRoutes() },
                        onOpenFavorites: { flow.openFavoritedReviewBoard() },
                        onOpenProfile: { flow.selectTab(.profile) }
                    )
                }

                tabStage(tab: .routes) {
                    RoutesJourneyContainer(flow: $flow)
                }

                tabStage(tab: .anki) {
                    ReviewBoardContainer(flow: $flow)
                }

                tabStage(tab: .profile) {
                    ProfileScreen(
                        model: flow.profileScreenModel,
                        reminderTime: Binding(
                            get: { flow.reminderTime },
                            set: { flow.setReminderTime($0) }
                        ),
                        remindersEnabled: Binding(
                            get: { flow.remindersEnabled },
                            set: { flow.setRemindersEnabled($0) }
                        ),
                        isNightModeEnabled: Binding(
                            get: { flow.isNightModeEnabled },
                            set: { flow.setNightModeEnabled($0) }
                        ),
                        onContinueLearning: { flow.openLesson() },
                        onOpenFavorites: { flow.openFavoritedReviewBoard() }
                    )
                }
            }
            .padding(.bottom, 112)
            .animation(
                animationsDisabled ? nil : .spring(response: 0.4, dampingFraction: 0.75),
                value: flow.currentScreen
            )

            FloatingTabBar(selectedTab: flow.selectedTab) { tab in
                flow.selectTab(tab)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
    }

    private func tabStage<Content: View>(
        tab: LearnNowTab,
        @ViewBuilder content: () -> Content
    ) -> some View {
        StableStage(isActive: flow.currentScreen == screen(for: tab)) {
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
    @Binding var flow: LearnNowFlowState

    var body: some View {
        ZStack {
            routesStage(destination: .overview) {
                RoutesScreen(model: flow.routesOverviewModel) { _ in
                    flow.openPath()
                }
            }

            routesStage(destination: .path) {
                PathScreen(
                    model: flow.pathScreenModel,
                    onBack: { flow.showRoutes() },
                    onSelectTrack: { flow.selectRouteTrack($0) },
                    onOpenLesson: { flow.openLesson(moduleID: $0) }
                )
            }

            routesStage(destination: .lesson) {
                LessonScreen(
                    model: flow.lessonScreenModel,
                    onBack: { flow.openPathForLoadedLesson() },
                    onSelectPage: { flow.setCurrentLessonPageIndex($0) },
                    onAnswer: { flow.answerCurrentLesson(with: $0) },
                    onCallToAction: { flow.handleLessonCallToAction($0) }
                )
            }

            routesStage(destination: .completion) {
                CompletionScreen(
                    model: flow.completionScreenModel,
                    onContinueLearning: { flow.openNextLesson() },
                    onFinish: { flow.finishLearning() },
                    onOpenReviewBoard: { flow.openReviewBoard() }
                )
            }
        }
    }

    private func routesStage<Content: View>(
        destination: LearnNowRoutesDestination,
        @ViewBuilder content: () -> Content
    ) -> some View {
        StableStage(isActive: flow.routesDestination == destination) {
            content()
        }
    }
}

private struct ReviewBoardContainer: View {
    @Binding var flow: LearnNowFlowState

    private var activeSheet: Binding<LearnNowReviewSheet?> {
        Binding(
            get: { flow.activeReviewSheet },
            set: { newValue in
                if let newValue {
                    flow.activeReviewSheet = newValue
                } else {
                    flow.dismissReviewSheet()
                }
            }
        )
    }

    var body: some View {
        ReviewBoardScreen(
            model: flow.reviewBoardModel,
            onOpenFilters: { flow.openReviewCardPool() },
            onFlipCard: { flow.flipCurrentReviewCard() },
            onRate: { flow.rateCurrentReviewCard($0) },
            onEmptyAction: { flow.handleReviewEmptyPrimaryAction() }
        )
        .sheet(item: activeSheet) { sheet in
            switch sheet {
            case .cardPool:
                ReviewFiltersSheet(
                    model: flow.reviewFiltersSheetModel,
                    onReset: { flow.resetDraftReviewFilters() },
                    onSelectTime: { flow.setDraftTimeFilter($0) },
                    onToggleTopic: { flow.toggleDraftTopic($0) },
                    onToggleModule: { flow.toggleDraftModule($0) },
                    onSelectMastery: { flow.setDraftMasteryFilter($0) },
                    onSelectFavorite: { flow.setDraftFavoriteFilter($0) },
                    onToggleFavorite: { flow.toggleReviewCardFavorited(id: $0) },
                    onToggleMastered: { flow.toggleReviewCardMastered(id: $0) },
                    onApply: { flow.applyReviewCardPoolFilters() }
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
    @State private var flow = LearnNowFlowState()

    var body: some View {
        AppShellView(flow: $flow)
    }
}
