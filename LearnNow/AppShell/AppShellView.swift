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

            currentScreenView
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
    private var currentScreenView: some View {
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
            PathScreen(
                flow: flow,
                onBack: { flow.showRoutes() },
                onOpenLesson: { moduleID in
                    flow.openLesson(moduleID: moduleID)
                }
            )
        case .lesson:
            LessonScreen(flow: $flow)
        case .completion:
            CompletionScreen(
                flow: flow,
                onContinueLearning: { flow.openNextLesson() },
                onFinish: { flow.finishLearning() },
                onOpenReviewBoard: { flow.openReviewBoard() }
            )
        case .anki:
            ReviewBoardScreen(flow: $flow)
        case .dash:
            DashboardScreen(flow: flow)
        }
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
