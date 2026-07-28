import Foundation

/// Owns screen and destination transitions. The app store coordinates data writes,
/// while the router keeps navigation decisions independent of persistence.
struct LearnNowRouter {
    func selectTab(_ tab: LearnNowTab, flow: inout LearnNowFlowState) {
        flow.selectTab(tab)
    }

    func showRoutes(flow: inout LearnNowFlowState) {
        flow.showRoutes()
    }

    func openPath(routeID: String? = nil, flow: inout LearnNowFlowState) {
        flow.openPath(routeID: routeID)
    }

    func openPathForLoadedLesson(flow: inout LearnNowFlowState) {
        flow.openPathForLoadedLesson()
    }

    func selectRouteTrack(_ trackID: String, flow: inout LearnNowFlowState) {
        flow.selectRouteTrack(trackID)
    }

    func openLesson(flow: inout LearnNowFlowState) {
        flow.openLesson()
    }

    func openLesson(moduleID: String, flow: inout LearnNowFlowState) {
        flow.openLesson(moduleID: moduleID)
    }

    func openNextLesson(flow: inout LearnNowFlowState) {
        flow.openNextLesson()
    }

    func finishLearning(flow: inout LearnNowFlowState) {
        flow.finishLearning()
    }

    func openReviewBoard(flow: inout LearnNowFlowState) {
        flow.openReviewBoard()
    }

    func openFavoritedReviewBoard(flow: inout LearnNowFlowState) {
        flow.openFavoritedReviewBoard()
    }
}
