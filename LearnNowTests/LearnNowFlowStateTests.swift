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
        var sut = LearnNowFlowState.homePreview

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
        var sut = LearnNowFlowState.homePreview
        sut.streakDays = 14

        #expect(sut.homeScreenModel.streakDays == 14)
        #expect(sut.homeScreenModel.statusMetrics.first?.value == "14")
    }

    @Test
    func nestedLearningFlowKeepsRoutesTabSelected() {
        var sut = LearnNowFlowState.homePreview

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
    func homeContinueLearningReopensLastVisitedLessonWhenAllModulesAreComplete() {
        let catalog = LearnNowFlowFixtures.catalog
        var snapshot = LearningSnapshot.empty
        snapshot.completedLessonIDs = Set(catalog.modules.map(\.id))
        snapshot.lastVisitedLessonID = "regression"

        var sut = LearnNowFlowState(catalog: catalog, snapshot: snapshot)

        #expect(sut.nextAvailableModuleIndex == sut.modules.count)
        #expect(sut.modules[sut.loadedLessonModuleIndex].id == "regression")

        sut.openLesson()

        #expect(sut.selectedTab == .routes)
        #expect(sut.currentScreen == .routes)
        #expect(sut.routesDestination == .lesson)
        #expect(sut.modules[sut.loadedLessonModuleIndex].id == "regression")
        #expect(sut.currentLessonTitle == "线性回归模型")
    }

    @Test
    func selectingRouteTrackFiltersVisiblePathNodes() {
        var sut = LearnNowFlowState.homePreview
        sut.openPath()

        #expect(sut.selectedRouteTrackID == "statistics")
        #expect(
            sut.visiblePathNodes.map(\.id) ==
            ["stats", "probability", "hypothesis"]
        )

        sut.selectRouteTrack("machineLearning")
        #expect(sut.visiblePathNodes.map(\.id) == ["regression"])

        sut.selectRouteTrack("deepLearning")
        #expect(sut.visiblePathNodes.isEmpty)
    }

    @Test
    func unlockedCompletedModuleCanBeReopenedByChapterID() {
        var sut = LearnNowFlowState.completionPreview

        sut.finishLearning()
        #expect(sut.currentScreen == .routes)
        #expect(sut.routesDestination == .path)
        #expect(sut.selectedRouteTrackID == "statistics")

        sut.openLesson(moduleID: "hypothesis")
        #expect(sut.currentScreen == .routes)
        #expect(sut.routesDestination == .lesson)
        #expect(sut.currentLessonTitle == "假设检验")
        #expect(sut.currentLessonPageIndex == 1)
        #expect(sut.currentLessonPage.id == "hypothesis-page-2")
    }

    @Test
    func incorrectLessonAnswerCanBeRetried() {
        var sut = LearnNowFlowState.homePreview
        sut.openLesson()

        sut.answerCurrentLesson(with: "strict-normality")

        #expect(sut.currentLessonPage.answerState == .incorrect(optionID: "strict-normality"))
        #expect(sut.currentLessonPage.callToAction == .retry)
        #expect(
            sut.lessonScreenModel.pages[0]
                .exercisesByID["hypothesis-page-1.quiz"]?
                .feedback?
                .body
                .map(\.plainText)
                .joined() ==
                "正态性是常用假设，但轻微偏离并不等于方法绝对不可用。"
        )

        sut.retryCurrentLessonQuestion()

        #expect(sut.currentLessonPage.answerState == .unanswered)
        #expect(sut.currentLessonPage.callToAction == nil)
    }

    @Test
    func completingLessonAwardsXPAndShowsCompletionScreen() {
        var sut = LearnNowFlowState.homePreview
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
        #expect(sut.generatedReviewTags == ["P值", "第一类错误"])
        #expect(sut.hasNextLesson)
        #expect(sut.nextLessonTitle == "线性回归模型")
        #expect(sut.pathNodes[2].status == .done)
        #expect(sut.pathNodes[3].status == .current)
    }

    @Test
    func tipRotationIsStableAndOnlyIncludesUnlockedModules() {
        var locked = LearnNowFlowState(
            catalog: LearnNowFlowFixtures.catalog,
            snapshot: .empty,
            now: Date(timeIntervalSince1970: 1_752_787_800)
        )
        locked.tipRotationDayOrdinal = 1
        #expect(locked.homeScreenModel.knowledgeTip.title == "偏态分布别只看均值")

        var unlocked = LearnNowFlowState.homePreview
        unlocked.tipRotationDayOrdinal = 0
        let firstTitle = unlocked.homeScreenModel.knowledgeTip.title
        #expect(firstTitle == "偏态分布别只看均值")
        #expect(unlocked.homeScreenModel.knowledgeTip.title == firstTitle)

        unlocked.tipRotationDayOrdinal = 1
        #expect(unlocked.homeScreenModel.knowledgeTip.title == "p 值不是「原假设为真的概率」")
    }

    @Test
    func completedModuleWithAnUnvisitedStablePageIsMarkedAsNewContent() {
        var snapshot = LearnNowFlowFixtures.learningSnapshot
        snapshot.completedLessonIDs.insert("hypothesis")
        snapshot.visitedPageIDsByLessonID["hypothesis"] = ["hypothesis-page-1"]

        let sut = LearnNowFlowState(
            catalog: LearnNowFlowFixtures.catalog,
            snapshot: snapshot
        )
        let hypothesis = sut.pathNodes.first(where: { $0.id == "hypothesis" })

        #expect(hypothesis?.status == .done)
        #expect(hypothesis?.hasNewContent == true)
        #expect(hypothesis?.subtitle.contains("有新内容") == true)
    }

    @Test
    func reopeningCompletedModuleWithNewContentStartsAtFirstUnvisitedPage() {
        var snapshot = LearnNowFlowFixtures.learningSnapshot
        snapshot.completedLessonIDs.insert("hypothesis")
        snapshot.visitedPageIDsByLessonID["hypothesis"] = ["hypothesis-page-1"]
        var sut = LearnNowFlowState(
            catalog: LearnNowFlowFixtures.catalog,
            snapshot: snapshot
        )

        sut.openLesson(moduleID: "hypothesis")

        #expect(sut.completedLessonIDs.contains("hypothesis"))
        #expect(sut.currentLessonPage.id == "hypothesis-page-2")
        #expect(sut.pathNodes.first(where: { $0.id == "hypothesis" })?.status == .done)
    }

    @Test
    func stablePageIDRestoresAfterPageReorderAndStillMarksUnvisitedContent() throws {
        let catalog = try catalogByReversingPages(in: "hypothesis")
        var snapshot = LearnNowFlowFixtures.learningSnapshot
        snapshot.completedLessonIDs.insert("hypothesis")
        snapshot.lastVisitedLessonID = "hypothesis"
        snapshot.lastVisitedPageID = "hypothesis-page-2"
        snapshot.highestPageOrderByLessonID["hypothesis"] = 1
        snapshot.visitedPageIDsByLessonID["hypothesis"] = ["hypothesis-page-2"]

        let sut = LearnNowFlowState(catalog: catalog, snapshot: snapshot)
        let hypothesis = sut.pathNodes.first(where: { $0.id == "hypothesis" })

        #expect(sut.currentLessonPage.id == "hypothesis-page-2")
        #expect(sut.currentLessonPageIndex == 0)
        #expect(hypothesis?.status == .done)
        #expect(hypothesis?.hasNewContent == true)
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
    func easyReviewConsumesCurrentQueueCardAndMovesItToFutureReview() throws {
        let timeZone = try #require(TimeZone(identifier: "Asia/Shanghai"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let now = Date(timeIntervalSince1970: 1_752_787_800)
        let previousReviewDate = try #require(
            calendar.date(byAdding: .day, value: -9, to: now)
        )
        let scheduler = FSRSReviewScheduler()
        let dueMemory = try scheduler.schedule(
            cardID: "mean",
            memory: nil,
            rating: .easy,
            now: previousReviewDate
        ).memory
        var sut = LearnNowFlowState(
            catalog: LearnNowFlowFixtures.catalog,
            snapshot: LearningSnapshot(
                reviewMemoryByCardID: ["mean": dueMemory]
            ),
            now: now
        )

        #expect(dueMemory.dueAt <= now)
        #expect(sut.currentReviewCard?.id == "mean")
        #expect(sut.reviewSummaryByBucket[.review] == 1)
        #expect(sut.reviewCardsDueTodayCount(asOf: now, calendar: calendar) == 1)

        let outcome = try scheduler.schedule(
            cardID: "mean",
            memory: dueMemory,
            rating: .easy,
            now: now
        )
        sut.applyReviewOutcome(outcome, now: now)

        #expect(outcome.dueAt > now)
        #expect(sut.activeReviewCards.isEmpty)
        #expect(sut.reviewQueueCards.count == 1)
        #expect(sut.reviewSummaryByBucket[.review, default: 0] == 0)
        #expect(sut.reviewSummaryByBucket[.reinforce] == 1)
        #expect(sut.reviewCardsDueTodayCount(asOf: now, calendar: calendar) == 0)
        guard case .empty(let state) = sut.reviewBoardModel.stage else {
            Issue.record("完成本轮唯一卡片后应进入复习完成态")
            return
        }
        #expect(state.title == "今日复习已完成")

        sut.selectTab(.profile, now: now)
        sut.selectTab(.anki, now: now)

        #expect(sut.activeReviewCards.isEmpty)

        sut.selectTab(.anki, now: outcome.dueAt)

        #expect(sut.currentReviewCard?.id == "mean")
        #expect(sut.reviewSummaryByBucket[.review] == 1)
    }

    @Test
    func completedFilteredQueueStaysCompletedWhenReturningToReviewTab() throws {
        let now = Date(timeIntervalSince1970: 1_752_787_800)
        let memory = ReviewMemorySnapshot(
            cardID: "mean",
            dueAt: now,
            lastReviewAt: nil,
            stability: 0,
            difficulty: 0,
            elapsedDays: 0,
            scheduledDays: 0,
            stateRawValue: 0,
            learningSteps: 0,
            reps: 0,
            lapses: 0,
            retrievability: 0,
            isFavorited: false,
            isMastered: false
        )
        var sut = LearnNowFlowState(
            catalog: LearnNowFlowFixtures.catalog,
            snapshot: LearningSnapshot(
                reviewMemoryByCardID: ["mean": memory]
            ),
            now: now
        )
        sut.toggleDraftTopic("描述统计")
        sut.applyReviewCardPoolFilters(now: now)
        let outcome = try FSRSReviewScheduler().schedule(
            cardID: "mean",
            memory: memory,
            rating: .easy,
            now: now
        )

        sut.applyReviewOutcome(outcome, now: now)
        sut.selectTab(.profile, now: now)
        sut.selectTab(.anki, now: now)

        #expect(sut.activeReviewCards.isEmpty)
        #expect(sut.isReviewQueueCompleted)
        guard case .empty(let state) = sut.reviewBoardModel.stage else {
            Issue.record("带筛选的本轮复习完成后应保持完成态")
            return
        }
        #expect(!state.hasActiveFilters)
        #expect(state.title == "今日复习已完成")
        #expect(state.actionTitle == "返回概览")
    }

    @Test
    func futureNewCardStaysInCardPoolButNotDefaultReviewQueue() throws {
        let now = Date(timeIntervalSince1970: 1_752_787_800)
        let future = now.addingTimeInterval(86_400)
        let memory = ReviewMemorySnapshot(
            cardID: "mean",
            dueAt: future,
            lastReviewAt: nil,
            stability: 0,
            difficulty: 0,
            elapsedDays: 0,
            scheduledDays: 0,
            stateRawValue: 0,
            learningSteps: 0,
            reps: 0,
            lapses: 0,
            retrievability: 0,
            isFavorited: false,
            isMastered: false
        )
        let sut = LearnNowFlowState(
            catalog: LearnNowFlowFixtures.catalog,
            snapshot: LearningSnapshot(
                reviewMemoryByCardID: ["mean": memory]
            ),
            now: now
        )

        #expect(sut.reviewCards.map(\.id) == ["mean"])
        #expect(sut.stagedReviewCards.map(\.id) == ["mean"])
        #expect(sut.activeReviewCards.isEmpty)
    }

    @Test
    func reviewFiltersDefaultModelContainsEveryCardAndNoEmptyState() {
        let sut = LearnNowFlowState.homePreview
        let model = sut.reviewFiltersSheetModel

        #expect(model.resultCount == 7)
        #expect(model.resultCards.count == 7)
        #expect(model.emptyState == nil)
        #expect(!model.canReset)
        #expect(model.activeFilterCount == 0)
    }

    @Test
    func incompatibleReviewFacetsShowNoMatchesAndResetRestoresDefaultResults() {
        var sut = LearnNowFlowState.homePreview

        sut.toggleDraftTopic("描述统计")
        sut.toggleDraftModule("regression")

        #expect(sut.reviewFiltersSheetModel.resultCount == 0)
        #expect(sut.reviewFiltersSheetModel.emptyState == .noMatches)
        #expect(sut.reviewFiltersSheetModel.canReset)

        sut.resetDraftReviewFilters()

        #expect(sut.draftReviewFilters == .empty)
        #expect(sut.reviewFiltersSheetModel.resultCount == 7)
        #expect(sut.reviewFiltersSheetModel.emptyState == nil)
        #expect(!sut.reviewFiltersSheetModel.canReset)
    }

    @Test
    func reviewFiltersDistinguishAnEmptyCardPoolFromNoMatches() {
        let sut = LearnNowFlowState(catalog: LearnNowFlowFixtures.catalog, snapshot: .empty)
        let model = sut.reviewFiltersSheetModel

        #expect(sut.reviewCards.isEmpty)
        #expect(model.resultCount == 0)
        #expect(model.resultCards.isEmpty)
        #expect(model.emptyState == .noCards)
        #expect(!model.canReset)
    }

    @Test
    func draftReviewFiltersDoNotChangeActiveCardsUntilApplied() {
        var sut = LearnNowFlowState.homePreview
        let initialActiveIDs = sut.activeReviewCards.map(\.id)

        sut.toggleDraftTopic("描述统计")

        #expect(sut.stagedReviewCards.map(\.id) == ["mean", "variance"])
        #expect(sut.activeReviewCards.map(\.id) == initialActiveIDs)
        #expect(sut.appliedReviewFilters == .empty)
        #expect(sut.draftReviewFilters.topics == ["描述统计"])

        sut.applyReviewCardPoolFilters()

        #expect(sut.appliedReviewFilters == sut.draftReviewFilters)
        #expect(sut.activeReviewCards.map(\.id) == ["mean", "variance"])
        #expect(sut.activeReviewSheet == nil)
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
        var sut = LearnNowFlowState.homePreview
        sut.activeCloudSyncEnabled = true
        sut.desiredCloudSyncEnabled = false
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

    private func catalogByReversingPages(in moduleID: String) throws -> CourseCatalog {
        let catalog = LearnNowFlowFixtures.catalog
        var modules = catalog.modules
        let moduleIndex = try #require(modules.firstIndex(where: { $0.id == moduleID }))
        let module = modules[moduleIndex]
        modules[moduleIndex] = LearnNowModuleDefinition(
            id: module.id,
            trackID: module.trackID,
            title: module.title,
            subtitle: module.subtitle,
            lessonTitle: module.lessonTitle,
            lessonPages: Array(module.lessonPages.reversed()),
            reviewTags: module.reviewTags,
            reviewMessage: module.reviewMessage,
            prerequisiteModuleIDs: module.prerequisiteModuleIDs,
            completionXP: module.completionXP,
            reviewCardIDs: module.reviewCardIDs
        )
        return CourseCatalog(
            schemaVersion: catalog.schemaVersion,
            releaseVersion: catalog.releaseVersion,
            locale: catalog.locale,
            contentRootURL: catalog.contentRootURL,
            primaryRouteID: catalog.primaryRouteID,
            tracks: catalog.tracks,
            routes: catalog.routes,
            moduleIDsByRouteID: catalog.moduleIDsByRouteID,
            modules: modules,
            reviewCards: catalog.reviewCards,
            dailyTips: catalog.dailyTips,
            retiredIDs: catalog.retiredIDs
        )
    }
}
