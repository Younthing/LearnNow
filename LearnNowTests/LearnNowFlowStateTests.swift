//
//  LearnNowFlowStateTests.swift
//  LearnNowTests
//
//  Created by Codex on 4/3/26.
//

import Testing
@testable import LearnNow

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

        sut.selectTab(.dash)
        #expect(sut.selectedTab == .dash)
        #expect(sut.currentScreen == .dash)

        sut.selectTab(.home)
        #expect(sut.selectedTab == .home)
        #expect(sut.currentScreen == .home)
    }

    @Test
    func nestedLearningFlowKeepsRoutesTabSelected() {
        var sut = LearnNowFlowState()

        sut.openPath()
        #expect(sut.currentScreen == .path)
        #expect(sut.selectedTab == .routes)

        sut.openLesson()
        #expect(sut.currentScreen == .lesson)
        #expect(sut.selectedTab == .routes)
    }

    @Test
    func unlockedCompletedModuleCanBeReopenedByChapterID() {
        var sut = LearnNowFlowState.completionPreview

        sut.finishLearning()
        #expect(sut.currentScreen == .path)

        sut.openLesson(moduleID: "hypothesis")
        #expect(sut.currentScreen == .lesson)
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

        #expect(sut.currentScreen == .completion)
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
        #expect(sut.currentScreen == .lesson)
        #expect(sut.currentLessonTitle == "线性回归模型")
        #expect(sut.currentLessonPageIndex == 0)

        sut = .completionPreview
        sut.finishLearning()
        #expect(sut.selectedTab == .routes)
        #expect(sut.currentScreen == .path)
        #expect(sut.pathNodes[2].status == .done)
        #expect(sut.pathNodes[3].status == .current)

        sut = .completionPreview
        sut.openReviewBoard()
        #expect(sut.selectedTab == .anki)
        #expect(sut.currentScreen == .anki)
    }
}
