//
//  LearnNowUITests.swift
//  LearnNowUITests
//
//  Created by Codex on 4/3/26.
//

import XCTest

final class LearnNowUITests: XCTestCase {

    /// Generous timeout that covers cold-launch + SwiftData init + animation settle.
    private let defaultTimeout: TimeInterval = 10

    private var app: XCUIApplication!

    // MARK: - Lifecycle

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()

        // Tell the app to skip animations so UI-element transitions are
        // synchronous and deterministic.
        app.launchArguments += ["-UIAnimationsDisabled", "YES"]
        app.launchArguments += ["-UITestingResetData", "YES"]
        app.launchArguments += ["-UITestingActiveCloudSyncEnabled"]
        app.launchArguments += ["-learnnow.settings.cloudSyncEnabled", "YES"]
        app.launchArguments += ["-learnnow.settings.nightMode", "NO"]

        app.launch()

        // Wait until the very first screen is fully rendered before any test
        // method starts interacting with elements.
        let home = element(matchingIdentifier: "screen.home")
        XCTAssertTrue(
            home.waitForExistence(timeout: defaultTimeout),
            "App did not present screen.home within \(defaultTimeout)s after launch."
        )
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Happy-path flow

    @MainActor
    func testHappyPathFromHomeToCompletion() throws {
        navigateToCompletion()
        assertExists(element(matchingIdentifier: "screen.completion"))
    }

    @MainActor
    func testHomeContinueLearningCardOpensCurrentLesson() throws {
        tapWhenHittable(element(matchingIdentifier: "home.continue"))

        assertExists(element(matchingIdentifier: "screen.lesson"))
        assertExists(app.staticTexts["描述统计与数据探索"])
    }

    @MainActor
    func testCompletionPrimaryCTAContinuesIntoNextLesson() throws {
        navigateToCompletion()

        tapWhenHittable(element(matchingIdentifier: "completion.cta.next"))

        assertExists(element(matchingIdentifier: "screen.lesson"))
        assertExists(app.staticTexts["概率论基础"])
    }

    @MainActor
    func testCompletedModuleCanBeReopenedFromPath() throws {
        navigateToCompletion()

        tapWhenHittable(element(matchingIdentifier: "completion.cta.finish"))
        assertExists(element(matchingIdentifier: "screen.path"))

        tapWhenHittable(element(matchingIdentifier: "path.module.stats"))
        assertExists(element(matchingIdentifier: "screen.lesson"))
        assertExists(app.staticTexts["描述统计与数据探索"])
    }

    @MainActor
    func testCompletionReviewCTAOpensReviewBoard() throws {
        navigateToCompletion()

        tapWhenHittable(element(matchingIdentifier: "completion.cta.review"))

        assertExists(element(matchingIdentifier: "screen.anki"))
    }

    @MainActor
    func testEasyRatingsAdvanceQueueAndMoveCardsToFutureReview() throws {
        navigateToCompletion()
        tapWhenHittable(element(matchingIdentifier: "completion.cta.review"))

        let newSummary = element(matchingIdentifier: "anki.summary.new")
        let reinforceSummary = element(matchingIdentifier: "anki.summary.reinforce")
        assertExists(newSummary)
        assertExists(reinforceSummary)
        XCTAssertEqual(newSummary.value as? String, "2")
        XCTAssertEqual(reinforceSummary.value as? String, "0")

        tapWhenHittable(element(matchingIdentifier: "anki.card"))
        tapWhenHittable(element(matchingIdentifier: "anki.rate.easy"))

        XCTAssertEqual(newSummary.value as? String, "1")
        XCTAssertEqual(reinforceSummary.value as? String, "1")
        assertExists(app.staticTexts["第 2 / 2 张"])

        tapWhenHittable(element(matchingIdentifier: "anki.card"))
        tapWhenHittable(element(matchingIdentifier: "anki.rate.easy"))

        assertExists(app.staticTexts["今日复习已完成"])
        XCTAssertEqual(newSummary.value as? String, "0")
        XCTAssertEqual(reinforceSummary.value as? String, "2")
    }

    @MainActor
    func testCardPoolUsesProgressiveDisclosureAndCompactCopy() throws {
        navigateToCompletion()
        openReviewCardPool()

        let moreFilters = element(matchingIdentifier: "review.filters.more")
        let resultCount = element(matchingIdentifier: "review.filters.result-count")

        assertExists(moreFilters)
        XCTAssertEqual(moreFilters.value as? String, "已折叠")
        XCTAssertFalse(element(matchingIdentifier: "review.filters.topic.描述统计").exists)
        assertExists(resultCount)
        XCTAssertTrue(resultCount.label.contains("共 2 张卡片"))
        assertExists(element(matchingIdentifier: "review.filters.apply"))

        [
            "先浏览这一轮卡池，再按需收窄范围。",
            "当前范围",
            "先用时间范围快速收窄，再浏览下方卡池。",
            "按当前条件实时刷新，默认按到期时间排序。",
        ].forEach { oldHint in
            XCTAssertFalse(app.staticTexts[oldHint].exists)
        }
    }

    @MainActor
    func testCardPoolNoMatchesHidesApplyAndClearRestoresResults() throws {
        navigateToCompletion()
        completeProbabilityLesson()
        openReviewCardPool()

        let moreFilters = element(matchingIdentifier: "review.filters.more")
        tapWhenHittable(moreFilters)
        XCTAssertEqual(moreFilters.value as? String, "已展开")

        tapWhenHittable(element(matchingIdentifier: "review.filters.topic.描述统计"))
        tapWhenHittable(element(matchingIdentifier: "review.filters.module.probability"))

        let resultCount = element(matchingIdentifier: "review.filters.result-count")
        let clearFilters = element(matchingIdentifier: "review.filters.empty.reset")
        assertExists(resultCount)
        XCTAssertTrue(resultCount.label.contains("共 0 张卡片"))
        assertExists(clearFilters)
        XCTAssertFalse(element(matchingIdentifier: "review.filters.apply").exists)

        tapWhenHittable(clearFilters)

        XCTAssertTrue(clearFilters.waitForNonExistence(timeout: defaultTimeout))
        assertExists(element(matchingIdentifier: "review.filters.apply"))
        XCTAssertTrue(resultCount.label.contains("共 3 张卡片"))
    }

    @MainActor
    func testPathTrackTabsSwitchVisibleContent() throws {
        tapWhenHittable(element(matchingIdentifier: "tab.routes"))
        tapWhenHittable(element(matchingIdentifier: "route.datascience"))
        assertExists(element(matchingIdentifier: "screen.path"))

        tapWhenHittable(element(matchingIdentifier: "path.track.machineLearning"))
        assertExists(element(matchingIdentifier: "path.module.regression"))

        tapWhenHittable(element(matchingIdentifier: "path.track.deepLearning"))
        assertExists(element(matchingIdentifier: "path.empty"))
    }

    @MainActor
    func testProfileRootFitsWithoutScrollingAndInsightSwitchKeepsLayoutStable() throws {
        let profileTab = element(matchingIdentifier: "tab.profile")
        tapWhenHittable(profileTab)

        let editProfile = element(matchingIdentifier: "profile.edit")
        let insight = element(matchingIdentifier: "profile.insight")
        let career = element(matchingIdentifier: "profile.shortcut.career")
        let favorites = element(matchingIdentifier: "profile.shortcut.favorites")
        let settings = element(matchingIdentifier: "profile.shortcut.settings")

        [editProfile, insight, career, favorites, settings].forEach {
            assertExists($0)
            XCTAssertGreaterThan($0.frame.height, 0, "\($0) should have a visible frame.")
        }
        [editProfile, career, favorites, settings].forEach {
            XCTAssertTrue($0.isHittable, "\($0) should be tappable without scrolling.")
        }
        [career, favorites, settings].forEach {
            XCTAssertGreaterThanOrEqual(
                $0.frame.height,
                60,
                "\($0) should keep enough vertical breathing room."
            )
        }
        XCTAssertEqual(
            career.frame.height,
            favorites.frame.height,
            accuracy: 2,
            "Profile shortcut rows should use consistent heights."
        )
        XCTAssertEqual(
            favorites.frame.height,
            settings.frame.height,
            accuracy: 2,
            "Profile shortcut rows should use consistent heights."
        )
        XCTAssertLessThanOrEqual(
            settings.frame.maxY,
            profileTab.frame.minY,
            "The last shortcut should remain above the floating tab bar."
        )

        let shortcutY = career.frame.minY
        tapWhenHittable(app.buttons["记忆趋势"].firstMatch)
        assertExists(app.staticTexts["完成首次复习后生成趋势"])
        XCTAssertEqual(
            career.frame.minY,
            shortcutY,
            accuracy: 2,
            "Switching insight modes should not move content below the card."
        )
    }

    @MainActor
    func testProfileEditingUpdatesAvatarAndNicknameAcrossNavigation() throws {
        tapWhenHittable(element(matchingIdentifier: "tab.profile"))
        tapWhenHittable(element(matchingIdentifier: "profile.edit"))

        let nameField = element(matchingIdentifier: "profile.name.field")
        tapWhenHittable(nameField)
        nameField.typeText("Nova")
        tapWhenHittable(element(matchingIdentifier: "profile.avatar.cat"))
        tapWhenHittable(element(matchingIdentifier: "profile.edit.save"))

        tapWhenHittable(element(matchingIdentifier: "tab.home"))
        tapWhenHittable(element(matchingIdentifier: "tab.profile"))

        let editProfile = element(matchingIdentifier: "profile.edit")
        assertExists(editProfile)
        XCTAssertTrue(editProfile.label.contains("Nova"))

        tapWhenHittable(editProfile)
        assertExists(nameField)
        XCTAssertTrue((nameField.value as? String)?.contains("Nova") == true)
        XCTAssertEqual(
            element(matchingIdentifier: "profile.avatar.cat").value as? String,
            "已选择"
        )
    }

    @MainActor
    func testProfileSecondaryPagesAndCloudSyncConfirmation() throws {
        let profileTab = element(matchingIdentifier: "tab.profile")
        tapWhenHittable(profileTab)
        tapWhenHittable(element(matchingIdentifier: "profile.shortcut.settings"))
        assertExists(element(matchingIdentifier: "screen.profile.settings"))

        let cloudToggle = app.switches
            .matching(identifier: "settings.cloud.toggle")
            .firstMatch
        assertExists(cloudToggle)
        XCTAssertEqual(cloudToggle.value as? String, "1")
        scrollIntoViewIfNeeded(cloudToggle)
        XCTAssertFalse(
            isCoveredByFloatingTabBar(cloudToggle),
            "Cloud sync toggle should be visible above the floating tab bar."
        )
        cloudToggle
            .coordinate(withNormalizedOffset: CGVector(dx: 0.88, dy: 0.5))
            .tap()

        let confirmation = app.alerts.firstMatch
        assertExists(confirmation)
        XCTAssertTrue(confirmation.label.contains("关闭云同步"))
        tapWhenHittable(confirmation.buttons["关闭"])
        assertExists(
            app.staticTexts
                .matching(NSPredicate(format: "label CONTAINS %@", "等待关闭"))
                .firstMatch
        )
        assertExists(app.staticTexts["重新打开 App 后生效"])

        tapWhenHittable(profileTab)
        let settingsScreen = element(matchingIdentifier: "screen.profile.settings")
        XCTAssertTrue(
            settingsScreen.waitForNonExistence(timeout: defaultTimeout),
            "Settings should finish dismissing before interacting with profile shortcuts."
        )
        assertExists(element(matchingIdentifier: "screen.profile"))

        tapWhenHittable(element(matchingIdentifier: "profile.shortcut.favorites"))
        assertExists(element(matchingIdentifier: "screen.favorites"))
        XCTAssertFalse(app.buttons["开始收藏复习"].exists)

        tapWhenHittable(profileTab)
        assertExists(element(matchingIdentifier: "screen.profile"))
    }

    @MainActor
    func testFavoriteCanBeManagedAndStartedAsFilteredReview() throws {
        navigateToCompletion()

        tapWhenHittable(element(matchingIdentifier: "tab.anki"))
        assertExists(element(matchingIdentifier: "screen.anki"))
        tapWhenHittable(element(matchingIdentifier: "anki.filters"))
        let favorite = element(matchingIdentifier: "review.pool.favorite.mean")
        tapWhenHittable(favorite)
        XCTAssertTrue(favorite.label.contains("已收藏"))
        let masteredInPool = element(matchingIdentifier: "review.pool.mastered.mean")
        tapWhenHittable(masteredInPool)
        XCTAssertTrue(masteredInPool.label.contains("已掌握"))
        tapWhenHittable(element(matchingIdentifier: "review.filters.apply"))

        tapWhenHittable(element(matchingIdentifier: "tab.profile"))
        tapWhenHittable(element(matchingIdentifier: "profile.shortcut.favorites"))
        assertExists(element(matchingIdentifier: "screen.favorites"))

        let mastered = element(matchingIdentifier: "favorites.mastered.mean")
        assertExists(mastered)
        XCTAssertTrue(mastered.label.contains("已掌握"))
        tapWhenHittable(mastered)
        XCTAssertTrue(mastered.label.contains("标为掌握"))

        tapWhenHittable(app.buttons["开始收藏复习"].firstMatch)
        assertExists(element(matchingIdentifier: "screen.anki"))
    }

    // MARK: - Helpers

    /// Assert that an element appears within the timeout.
    private func assertExists(
        _ element: XCUIElement,
        timeout: TimeInterval? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let t = timeout ?? defaultTimeout
        XCTAssertTrue(
            element.waitForExistence(timeout: t),
            "Expected \(element) to exist within \(t)s.",
            file: file,
            line: line
        )
    }

    /// Identifiers in the app are attached to a mix of `ScrollView`, `VStack`,
    /// and `Button` containers, so tests must not hard-code an element type.
    private func element(matchingIdentifier identifier: String) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(identifier: identifier)
            .firstMatch
    }

    /// Wait for the element to exist **and be hittable** (not obscured / off-screen),
    /// then tap it.  This avoids the common flake where `waitForExistence` passes
    /// but the element hasn't finished its layout pass yet.
    private func tapWhenHittable(
        _ element: XCUIElement,
        timeout: TimeInterval? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let t = timeout ?? defaultTimeout

        // First, make sure the element is in the hierarchy.
        assertExists(element, timeout: t, file: file, line: line)

        scrollIntoViewIfNeeded(element)

        // Then spin until it becomes hittable (visible & interactive).
        let hittable = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: hittable, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: t)
        XCTAssertEqual(
            result, .completed,
            "Element \(element) never became hittable within \(t)s.",
            file: file,
            line: line
        )
        XCTAssertFalse(
            isCoveredByFloatingTabBar(element),
            "Element \(element) remained behind the floating tab bar.",
            file: file,
            line: line
        )

        element.tap()
    }

    /// Some lesson controls live below the initial viewport inside a scroll view.
    /// A few upward swipes are enough to expose them on the tested device size.
    private func scrollIntoViewIfNeeded(_ element: XCUIElement, maxSwipes: Int = 8) {
        guard element.exists else { return }

        var remainingSwipes = maxSwipes
        while (!element.isHittable || isCoveredByFloatingTabBar(element)),
              remainingSwipes > 0 {
            app.swipeUp()
            remainingSwipes -= 1
        }
    }

    /// A translucent floating tab bar can leave an underlying control reporting
    /// `isHittable == true` even though its activation point belongs to a tab.
    private func isCoveredByFloatingTabBar(_ element: XCUIElement) -> Bool {
        guard !element.identifier.hasPrefix("tab.") else { return false }

        let homeTab = self.element(matchingIdentifier: "tab.home")
        guard homeTab.exists, homeTab.isHittable else { return false }

        let floatingBarHitRegionTop = homeTab.frame.minY - 24
        return element.frame.midY >= floatingBarHitRegionTop
    }

    @MainActor
    private func navigateToCompletion() {
        // 1  Home → Routes tab
        tapWhenHittable(element(matchingIdentifier: "tab.routes"))
        assertExists(element(matchingIdentifier: "screen.routes"))

        // 2  Routes → Path (data-science route)
        tapWhenHittable(element(matchingIdentifier: "route.datascience"))
        assertExists(element(matchingIdentifier: "screen.path"))

        // 3  Path → Lesson (current module)
        tapWhenHittable(element(matchingIdentifier: "path.module.stats"))
        assertExists(element(matchingIdentifier: "screen.lesson"))

        // 4  Lesson page 1: answer + advance
        tapWhenHittable(element(matchingIdentifier: "lesson.option.mean-rises"))
        tapWhenHittable(element(matchingIdentifier: "lesson.cta"))

        // 5  Lesson page 2: answer + complete
        tapWhenHittable(element(matchingIdentifier: "lesson.option.variance-second"))
        tapWhenHittable(element(matchingIdentifier: "lesson.cta"))

        // 6  Completion screen
        assertExists(element(matchingIdentifier: "screen.completion"))
    }

    @MainActor
    private func completeProbabilityLesson() {
        tapWhenHittable(element(matchingIdentifier: "completion.cta.next"))
        assertExists(element(matchingIdentifier: "screen.lesson"))

        tapWhenHittable(element(matchingIdentifier: "lesson.option.bayes-update"))
        tapWhenHittable(element(matchingIdentifier: "lesson.cta"))

        assertExists(element(matchingIdentifier: "screen.completion"))
    }

    @MainActor
    private func openReviewCardPool() {
        tapWhenHittable(element(matchingIdentifier: "tab.anki"))
        assertExists(element(matchingIdentifier: "screen.anki"))
        tapWhenHittable(element(matchingIdentifier: "anki.filters"))
        assertExists(element(matchingIdentifier: "screen.review.filters"))
    }
}
