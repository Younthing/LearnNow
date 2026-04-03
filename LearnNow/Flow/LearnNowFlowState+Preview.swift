import Foundation

extension LearnNowFlowState {
    static var homePreview: Self {
        Self()
    }

    static var routesPreview: Self {
        var flow = Self()
        flow.showRoutes()
        return flow
    }

    static var pathPreview: Self {
        var flow = Self()
        flow.openPath()
        return flow
    }

    static var lessonPreview: Self {
        var flow = Self()
        flow.openLesson()
        return flow
    }

    static var completionPreview: Self {
        var flow = Self()
        flow.openLesson()
        flow.answerCurrentLesson(with: "t-test-robust")
        flow.advanceLesson()
        flow.answerCurrentLesson(with: "p-value-meaning")
        flow.completeLesson()
        return flow
    }

    static var reviewBoardPreview: Self {
        var flow = Self()
        flow.selectTab(.anki)
        return flow
    }

    static var dashboardPreview: Self {
        var flow = Self()
        flow.selectTab(.dash)
        return flow
    }
}
