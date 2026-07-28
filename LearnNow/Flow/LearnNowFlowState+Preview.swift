import Foundation

extension LearnNowFlowState {
    static var homePreview: Self {
        previewState()
    }

    static var routesPreview: Self {
        var flow = previewState()
        flow.showRoutes()
        return flow
    }

    static var pathPreview: Self {
        var flow = previewState()
        flow.openPath()
        return flow
    }

    static var lessonPreview: Self {
        var flow = previewState()
        flow.openLesson()
        return flow
    }

    static var completionPreview: Self {
        var flow = previewState()
        flow.openLesson()
        flow.answerCurrentLesson(with: "t-test-robust")
        flow.advanceLesson()
        flow.answerCurrentLesson(with: "p-value-meaning")
        flow.completeLesson()
        return flow
    }

    static var reviewBoardPreview: Self {
        var flow = previewState()
        flow.selectTab(.anki)
        return flow
    }

    static var reviewBoardEmptyPreview: Self {
        var flow = previewState()
        flow.appliedReviewFilters = LearnNowReviewFilters(
            topics: ["描述统计"],
            moduleIDs: ["regression"]
        )
        flow.draftReviewFilters = flow.appliedReviewFilters
        flow.applyReviewCardPoolFilters()
        flow.selectTab(.anki)
        return flow
    }

    static var reviewBoardFilteredPreview: Self {
        var flow = previewState()
        flow.appliedReviewFilters.favorite = .favoritedOnly
        flow.draftReviewFilters = flow.appliedReviewFilters
        flow.applyReviewCardPoolFilters()
        flow.selectTab(.anki)
        return flow
    }

    static var profilePreview: Self {
        var flow = previewState()
        flow.selectTab(.profile)
        return flow
    }

    static var profileMemoryPreview: Self {
        var flow = profilePreview
        let now = Date()
        flow.memoryTrend = MemoryTrend(
            points: (0...7).map { day in
                MemoryTrendPoint(
                    dayOffset: day,
                    date: Calendar.current.date(byAdding: .day, value: day, to: now) ?? now,
                    retrievability: 0.96 - (Double(day) * 0.025)
                )
            }
        )
        return flow
    }

    static var profileEmptyPreview: Self {
        var flow = Self(
            catalog: LearnNowFlowFixtures.catalog,
            snapshot: .empty,
            activeCloudSyncEnabled: false,
            desiredCloudSyncEnabled: false
        )
        flow.selectTab(.profile)
        return flow
    }

    private static func previewState() -> Self {
        Self(
            catalog: LearnNowFlowFixtures.catalog,
            snapshot: LearnNowFlowFixtures.learningSnapshot,
            activeCloudSyncEnabled: false,
            desiredCloudSyncEnabled: false
        )
    }
}
