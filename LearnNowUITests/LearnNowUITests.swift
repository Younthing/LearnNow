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
        // 1  Home → Routes tab
        tapWhenHittable(element(matchingIdentifier: "tab.routes"))
        assertExists(element(matchingIdentifier: "screen.routes"))

        // 2  Routes → Path (data-science route)
        tapWhenHittable(element(matchingIdentifier: "route.datascience"))
        assertExists(element(matchingIdentifier: "screen.path"))

        // 3  Path → Lesson (current module)
        tapWhenHittable(element(matchingIdentifier: "path.currentModule"))
        assertExists(element(matchingIdentifier: "screen.lesson"))

        // 4  Lesson page 1: answer + advance
        tapWhenHittable(element(matchingIdentifier: "lesson.option.t-test-robust"))
        tapWhenHittable(element(matchingIdentifier: "lesson.cta"))

        // 5  Lesson page 2: answer + complete
        tapWhenHittable(element(matchingIdentifier: "lesson.option.p-value-meaning"))
        tapWhenHittable(element(matchingIdentifier: "lesson.cta"))

        // 6  Completion screen
        assertExists(element(matchingIdentifier: "screen.completion"))
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
        app.descendants(matching: .any)[identifier]
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

        element.tap()
    }

    /// Some lesson controls live below the initial viewport inside a scroll view.
    /// A few upward swipes are enough to expose them on the tested device size.
    private func scrollIntoViewIfNeeded(_ element: XCUIElement, maxSwipes: Int = 4) {
        guard element.exists else { return }

        var remainingSwipes = maxSwipes
        while !element.isHittable && remainingSwipes > 0 {
            app.swipeUp()
            remainingSwipes -= 1
        }
    }
}
