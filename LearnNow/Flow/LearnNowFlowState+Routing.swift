import Foundation

extension LearnNowFlowState {
    mutating func selectTab(_ tab: LearnNowTab) {
        selectedTab = tab

        switch tab {
        case .home:
            currentScreen = .home
        case .routes:
            currentScreen = .routes
        case .anki:
            currentScreen = .anki
            normalizeReviewState()
        case .profile:
            currentScreen = .profile
        }
    }

    mutating func showRoutes() {
        selectedTab = .routes
        currentScreen = .routes
        routesDestination = .overview
    }

    mutating func openPath() {
        selectedTab = .routes
        currentScreen = .routes
        if let track = trackForModuleIndex(nextAvailableModuleIndex) {
            selectedRouteTrack = track
            selectedRouteID = routeID(for: track)
        }
        routesDestination = .path
    }

    mutating func openPath(routeID: String) {
        selectedTab = .routes
        currentScreen = .routes
        selectedRouteID = routeID
        selectedRouteTrack = defaultTrack(for: routeID)
        routesDestination = .path
    }

    mutating func openPathForLoadedLesson() {
        selectedTab = .routes
        currentScreen = .routes
        if let track = trackForModuleIndex(loadedLessonModuleIndex) {
            selectedRouteTrack = track
            selectedRouteID = routeID(for: track)
        }
        routesDestination = .path
    }

    mutating func selectRouteTrack(_ track: LearnNowRouteTrack) {
        selectedRouteTrack = track
    }

    mutating func openLesson() {
        guard nextAvailableModuleIndex < Self.modules.count else { return }

        if loadedLessonModuleIndex != nextAvailableModuleIndex {
            loadLesson(for: nextAvailableModuleIndex)
        }

        selectedTab = .routes
        currentScreen = .routes
        if let track = trackForModuleIndex(loadedLessonModuleIndex) {
            selectedRouteTrack = track
            selectedRouteID = routeID(for: track)
        }
        routesDestination = .lesson
    }

    mutating func openLesson(moduleID: String) {
        guard let moduleIndex = Self.modules.firstIndex(where: { $0.id == moduleID }) else { return }
        guard isLessonAvailable(for: moduleIndex) else { return }

        loadLesson(for: moduleIndex)
        selectedTab = .routes
        currentScreen = .routes
        if let track = trackForModuleIndex(moduleIndex) {
            selectedRouteTrack = track
            selectedRouteID = routeID(for: track)
        }
        routesDestination = .lesson
    }

    mutating func setCurrentLessonPageIndex(_ index: Int) {
        guard lessonPages.indices.contains(index) else { return }
        currentLessonPageIndex = index
    }

    mutating func answerCurrentLesson(with optionID: String) {
        guard lessonPages.indices.contains(currentLessonPageIndex) else { return }
        guard case .unanswered = lessonPages[currentLessonPageIndex].answerState else { return }

        let correctOptionID = lessonPages[currentLessonPageIndex].question.correctOptionID
        if optionID == correctOptionID {
            lessonPages[currentLessonPageIndex].answerState = .correct(optionID: optionID)
        } else {
            lessonPages[currentLessonPageIndex].answerState = .incorrect(optionID: optionID)
        }
    }

    mutating func retryCurrentLessonQuestion() {
        guard lessonPages.indices.contains(currentLessonPageIndex) else { return }
        guard case .incorrect = lessonPages[currentLessonPageIndex].answerState else { return }
        lessonPages[currentLessonPageIndex].answerState = .unanswered
    }

    mutating func advanceLesson() {
        guard lessonPages.indices.contains(currentLessonPageIndex) else { return }
        guard lessonPages[currentLessonPageIndex].callToAction == .nextPage else { return }
        currentLessonPageIndex = min(currentLessonPageIndex + 1, lessonPages.count - 1)
    }

    mutating func handleLessonCallToAction(_ action: LearnNowLessonCallToAction) {
        switch action {
        case .nextPage:
            advanceLesson()
        case .retry:
            retryCurrentLessonQuestion()
        case .completeLesson:
            completeLesson()
        }
    }

    mutating func completeLesson() {
        guard lessonPages.indices.contains(currentLessonPageIndex) else { return }
        guard lessonPages[currentLessonPageIndex].callToAction == .completeLesson else { return }

        if !didAwardCompletionXP {
            totalXP += 15
            mastery = 0.68
            didAwardCompletionXP = true
        }

        let completedModule = Self.modules[loadedLessonModuleIndex]
        let upcomingIndex = loadedLessonModuleIndex + 1
        let nextModuleTitle = upcomingIndex < Self.modules.count ? Self.modules[upcomingIndex].lessonTitle : nil

        completionSummary = LearnNowCompletionSummary(
            completedModuleTitle: completedModule.title,
            reviewTags: completedModule.reviewTags,
            reviewMessage: completedModule.reviewMessage,
            nextModuleTitle: nextModuleTitle
        )

        nextAvailableModuleIndex = min(upcomingIndex, Self.modules.count)
        selectedTab = .routes
        currentScreen = .routes
        routesDestination = .completion
    }

    mutating func openNextLesson() {
        guard hasNextLesson else {
            finishLearning()
            return
        }

        openLesson()
    }

    mutating func finishLearning() {
        openPathForLoadedLesson()
    }

    func pathNodeSubtitle(
        for index: Int,
        baseSubtitle: String,
        status: LearnNowPathNode.Status
    ) -> String {
        switch status {
        case .done:
            "\(baseSubtitle) · 已掌握"
        case .current:
            "\(baseSubtitle) · 进行中"
        case .locked:
            "\(baseSubtitle) · 未解锁"
        }
    }

    func isLessonAvailable(for moduleIndex: Int) -> Bool {
        guard Self.modules.indices.contains(moduleIndex) else { return false }
        return moduleIndex <= nextAvailableModuleIndex && !Self.modules[moduleIndex].lessonPages.isEmpty
    }

    func trackForModuleIndex(_ moduleIndex: Int) -> LearnNowRouteTrack? {
        guard Self.modules.indices.contains(moduleIndex) else { return nil }
        return Self.modules[moduleIndex].track
    }

    func routeID(for track: LearnNowRouteTrack) -> String {
        switch track {
        case .computerScience:
            Self.computerScienceCourseID
        case .statistics, .machineLearning, .deepLearning:
            "datascience"
        }
    }

    func routeTracks(for routeID: String) -> [LearnNowRouteTrack] {
        switch routeID {
        case Self.computerScienceCourseID:
            [.computerScience]
        case "datascience":
            [.statistics, .machineLearning, .deepLearning]
        default:
            []
        }
    }

    func defaultTrack(for routeID: String) -> LearnNowRouteTrack {
        if let currentTrack = trackForModuleIndex(nextAvailableModuleIndex),
           self.routeID(for: currentTrack) == routeID {
            return currentTrack
        }

        return routeTracks(for: routeID).first ?? .computerScience
    }

    func routeProgress(for tracks: [LearnNowRouteTrack]) -> Double {
        let moduleIndexes = Self.modules.indices.filter { tracks.contains(Self.modules[$0].track) }
        guard !moduleIndexes.isEmpty else { return 0 }

        let completedCount = moduleIndexes.filter { $0 < nextAvailableModuleIndex }.count

        let currentProgress = moduleIndexes.contains(nextAvailableModuleIndex) ? 0.4 : 0

        return min((Double(completedCount) + currentProgress) / Double(moduleIndexes.count), 1)
    }
}

extension LearnNowFlowState {
    mutating func setReminderTime(_ date: Date) {
        reminderTime = date
    }

    mutating func setRemindersEnabled(_ enabled: Bool) {
        remindersEnabled = enabled
    }

    mutating func setNightModeEnabled(_ enabled: Bool) {
        isNightModeEnabled = enabled
    }
}

private extension LearnNowFlowState {
    mutating func loadLesson(for moduleIndex: Int) {
        guard Self.modules.indices.contains(moduleIndex) else { return }

        loadedLessonModuleIndex = moduleIndex
        lessonPages = Self.modules[moduleIndex].lessonPages
        currentLessonPageIndex = 0
    }
}
