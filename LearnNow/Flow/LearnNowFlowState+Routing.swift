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
        selectedRouteTrack = trackForModuleIndex(nextAvailableModuleIndex) ?? selectedRouteTrack
        routesDestination = .path
    }

    mutating func openPathForLoadedLesson() {
        selectedTab = .routes
        currentScreen = .routes
        selectedRouteTrack = trackForModuleIndex(loadedLessonModuleIndex) ?? selectedRouteTrack
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
        selectedRouteTrack = trackForModuleIndex(loadedLessonModuleIndex) ?? selectedRouteTrack
        routesDestination = .lesson
    }

    mutating func openLesson(moduleID: String) {
        guard let moduleIndex = Self.modules.firstIndex(where: { $0.id == moduleID }) else { return }
        guard isLessonAvailable(for: moduleIndex) else { return }

        loadLesson(for: moduleIndex)
        selectedTab = .routes
        currentScreen = .routes
        selectedRouteTrack = trackForModuleIndex(moduleIndex) ?? selectedRouteTrack
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
