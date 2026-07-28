//
//  LearnNowFlowStateTests.swift
//  LearnNowTests
//
//  Created by Codex on 4/3/26.
//

import Foundation
import Testing
@testable import LearnNow

@MainActor
struct LearnNowFlowStateTests {

    @Test
    func selectingTopLevelTabsUpdatesSelectedTabAndScreen() {
        var sut = LearnNowFlowState()

        sut.selectTab(.routes)
        #expect(sut.selectedTab == .routes)
        #expect(sut.currentScreen == .routes)

        sut.selectTab(.anki)
        #expect(sut.selectedTab == .anki)
        #expect(sut.currentScreen == .anki)

        sut.selectTab(.profile)
        #expect(sut.selectedTab == .profile)
        #expect(sut.currentScreen == .profile)

        sut.selectTab(.home)
        #expect(sut.selectedTab == .home)
        #expect(sut.currentScreen == .home)
    }

    @Test
    func homePresentationKeepsTypedStreakValue() {
        var sut = LearnNowFlowState()
        sut.streakDays = 14

        #expect(sut.homeScreenModel.streakDays == 14)
        #expect(sut.homeScreenModel.statusMetrics.first?.value == "14")
    }

    @Test
    func nestedLearningFlowKeepsRoutesTabSelected() {
        var sut = LearnNowFlowState()

        sut.openPath()
        #expect(sut.currentScreen == .routes)
        #expect(sut.selectedTab == .routes)
        #expect(sut.routesDestination == .path)

        sut.openLesson()
        #expect(sut.currentScreen == .routes)
        #expect(sut.selectedTab == .routes)
        #expect(sut.routesDestination == .lesson)
    }

    @Test
    func selectingRouteTrackFiltersVisiblePathNodes() {
        var sut = LearnNowFlowState()
        sut.openPath()

        #expect(sut.selectedRouteTrack == .statistics)
        #expect(
            sut.visiblePathNodes.map(\.id) ==
            ["stats", "probability", "hypothesis", "confidence-intervals", "anova", "experiment-design", "modeling-hypothesis"]
        )

        sut.selectRouteTrack(.machineLearning)
        #expect(sut.visiblePathNodes.map(\.id) == ["regression"])

        sut.selectRouteTrack(.deepLearning)
        #expect(sut.visiblePathNodes.isEmpty)
    }

    @Test
    func unlockedCompletedModuleCanBeReopenedByChapterID() {
        var sut = LearnNowFlowState.completionPreview

        sut.finishLearning()
        #expect(sut.currentScreen == .routes)
        #expect(sut.routesDestination == .path)
        #expect(sut.selectedRouteTrack == .statistics)

        sut.openLesson(moduleID: "hypothesis")
        #expect(sut.currentScreen == .routes)
        #expect(sut.routesDestination == .lesson)
        #expect(sut.currentLessonTitle == "假设检验")
        #expect(sut.currentLessonPageIndex == 0)
    }

    @Test
    func incorrectLessonAnswerCanBeRetried() {
        var sut = LearnNowFlowState()
        sut.openLesson()

        sut.answerCurrentLesson(with: "strict-normality")

        #expect(sut.currentLessonPage.answerState == .incorrect(optionID: "strict-normality"))
        #expect(sut.currentLessonPage.callToAction == .retry)

        sut.retryCurrentLessonQuestion()

        #expect(sut.currentLessonPage.answerState == .unanswered)
        #expect(sut.currentLessonPage.callToAction == nil)
    }

    @Test
    func completingLessonAwardsXPAndShowsCompletionScreen() {
        var sut = LearnNowFlowState()
        sut.openLesson()

        sut.answerCurrentLesson(with: "t-test-robust")
        #expect(sut.currentLessonPage.answerState == .correct(optionID: "t-test-robust"))
        #expect(sut.currentLessonPage.callToAction == .nextPage)

        sut.advanceLesson()
        #expect(sut.currentLessonPageIndex == 1)

        sut.answerCurrentLesson(with: "p-value-meaning")
        #expect(sut.currentLessonPage.answerState == .correct(optionID: "p-value-meaning"))
        #expect(sut.currentLessonPage.callToAction == .completeLesson)

        sut.completeLesson()

        #expect(sut.currentScreen == .routes)
        #expect(sut.routesDestination == .completion)
        #expect(sut.totalXP == 1_255)
        #expect(sut.generatedReviewTags == ["t 检验", "P值定义", "数据稳健性"])
        #expect(sut.hasNextLesson)
        #expect(sut.nextLessonTitle == "线性回归模型")
        #expect(sut.pathNodes[2].status == .done)
        #expect(sut.pathNodes[3].status == .current)
    }

    @Test
    func completionActionsNavigateToNextLessonPathOrReviewBoard() {
        var sut = LearnNowFlowState.completionPreview

        sut.openNextLesson()
        #expect(sut.selectedTab == .routes)
        #expect(sut.currentScreen == .routes)
        #expect(sut.routesDestination == .lesson)
        #expect(sut.currentLessonTitle == "线性回归模型")
        #expect(sut.currentLessonPageIndex == 0)

        sut = .completionPreview
        sut.finishLearning()
        #expect(sut.selectedTab == .routes)
        #expect(sut.currentScreen == .routes)
        #expect(sut.routesDestination == .path)
        #expect(sut.pathNodes[2].status == .done)
        #expect(sut.pathNodes[3].status == .current)

        sut = .completionPreview
        sut.openReviewBoard()
        #expect(sut.selectedTab == .anki)
        #expect(sut.currentScreen == .anki)
    }

    @Test
    func profileModelUsesSavedIdentityAndShowsReviewedMemoryTrend() {
        var sut = LearnNowFlowState.profilePreview
        sut.profilePreference = ProfilePreference(
            displayName: "小岚",
            avatarID: "otter"
        )
        sut.memoryTrend = MemoryTrend(
            points: (0...7).map { day in
                MemoryTrendPoint(
                    dayOffset: day,
                    date: Date(timeIntervalSince1970: Double(day) * 86_400),
                    retrievability: 0.96 - (Double(day) * 0.02)
                )
            }
        )

        let model = sut.profileScreenModel

        #expect(model.identity.displayName == "小岚")
        #expect(model.identity.avatarID == "otter")
        #expect(model.identity.activityText == "12 天连续 · 累计 1240 XP")
        #expect(model.memoryTrend.values.count == 8)
        #expect(model.memoryTrend.currentText == "96%")
        #expect(model.memoryTrend.seventhDayText == "82%")
        #expect(model.overview.metrics.first(where: { $0.id == "mastery" })?.value == "—")
        #expect(model.overview.heatmap.count == 28)
    }

    @Test
    func favoritesModelContainsEveryFavoriteAndSupportsManagementAndReview() {
        var sut = LearnNowFlowState.profilePreview

        #expect(Set(sut.favoritesScreenModel.items.map(\.id)) == ["variance", "p-value", "r2"])
        #expect(sut.favoritesScreenModel.canStartReview)

        sut.toggleReviewCardMastered(id: "variance")
        #expect(
            sut.favoritesScreenModel.items
                .first(where: { $0.id == "variance" })?
                .isMastered == true
        )

        sut.toggleReviewCardFavorited(id: "variance")
        #expect(Set(sut.favoritesScreenModel.items.map(\.id)) == ["p-value", "r2"])

        sut.openFavoritedReviewBoard()
        #expect(sut.selectedTab == .anki)
        #expect(sut.appliedReviewFilters.favorite == .favoritedOnly)
        #expect(Set(sut.activeReviewCards.map(\.id)) == ["p-value", "r2"])
    }

    @Test
    func settingsModelSeparatesActiveAndNextLaunchCloudSyncChoices() {
        var sut = LearnNowFlowState(
            activeCloudSyncEnabled: true,
            desiredCloudSyncEnabled: false
        )
        sut.syncAvailability = .available

        #expect(sut.settingsScreenModel.requiresRestart)
        #expect(sut.settingsScreenModel.syncStatusText == "等待关闭")
        #expect(
            sut.profileScreenModel.shortcuts
                .first(where: { $0.kind == .settings })?
                .subtitle == "重新打开 App 后生效"
        )

        sut.activeCloudSyncEnabled = false
        sut.syncAvailability = .disabled

        #expect(!sut.settingsScreenModel.requiresRestart)
        #expect(sut.settingsScreenModel.syncStatusText == "同步已关闭")
        #expect(sut.settingsScreenModel.syncDetailText.contains("重新开启后可恢复合并"))
    }
}
