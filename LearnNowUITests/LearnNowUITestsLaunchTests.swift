//
//  LearnNowUITestsLaunchTests.swift
//  LearnNowUITests
//
//  Created by fanxi on 3/31/26.
//

import XCTest

final class LearnNowUITestsLaunchTests: XCTestCase {

    // ⚠️  Setting this to `false` prevents Xcode from spawning one test-run
    //     per UI configuration (light / dark / locale / …).  When `true` and
    //     the project has even two configurations, Xcode launches multiple
    //     simulator instances in parallel and they race for the same app
    //     bundle — the #1 root cause of flaky launch-screenshot tests.
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-UIAnimationsDisabled", "YES"]
        app.launch()

        // Give the first screen enough time to fully render before
        // capturing the screenshot (SwiftData init + view layout).
        let home = app.descendants(matching: .any)["screen.home"]
        XCTAssertTrue(
            home.waitForExistence(timeout: 10),
            "Home screen did not appear within 10s of launch."
        )

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
