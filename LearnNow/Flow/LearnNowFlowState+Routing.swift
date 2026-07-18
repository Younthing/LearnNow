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
        guard nextAvailableModuleIndex < modules.count else { return }

        if loadedLessonModuleIndex != nextAvailableModuleIndex {
            loadLesson(for: nextAvailableModuleIndex)
        }

        selectedTab = .routes
        currentScreen = .routes
        selectedRouteTrack = trackForModuleIndex(loadedLessonModuleIndex) ?? selectedRouteTrack
        routesDestination = .lesson
    }

    mutating func openLesson(moduleID: String) {
        guard let moduleIndex = modules.firstIndex(where: { $0.id == moduleID }) else { return }
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
        completeLesson(awardXP: true)
    }

    mutating func completeLesson(awardXP: Bool) {
        guard lessonPages.indices.contains(currentLessonPageIndex) else { return }
        guard lessonPages[currentLessonPageIndex].callToAction == .completeLesson else { return }
        guard modules.indices.contains(loadedLessonModuleIndex) else { return }

        let completedModule = modules[loadedLessonModuleIndex]
        let wasAlreadyCompleted = completedLessonIDs.contains(completedModule.id)
        completedLessonIDs.insert(completedModule.id)

        if awardXP && !didAwardCompletionXP && !wasAlreadyCompleted {
            totalXP += completedModule.completionXP
            didAwardCompletionXP = true
        }

        activateReviewCards(for: completedModule)
        let upcomingIndex = modules.firstIndex { module in
            !completedLessonIDs.contains(module.id) &&
            Set(module.prerequisiteModuleIDs).isSubset(of: completedLessonIDs)
        }
        let nextModuleTitle = upcomingIndex.map { modules[$0].lessonTitle }

        completionSummary = LearnNowCompletionSummary(
            completedModuleTitle: completedModule.title,
            reviewTags: completedModule.reviewTags,
            reviewMessage: completedModule.reviewMessage,
            nextModuleTitle: nextModuleTitle
        )

        nextAvailableModuleIndex = upcomingIndex ?? modules.count
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
        guard modules.indices.contains(moduleIndex) else { return false }
        let module = modules[moduleIndex]
        return Set(module.prerequisiteModuleIDs).isSubset(of: completedLessonIDs) && !module.lessonPages.isEmpty
    }

    func trackForModuleIndex(_ moduleIndex: Int) -> LearnNowRouteTrack? {
        guard modules.indices.contains(moduleIndex) else { return nil }
        return modules[moduleIndex].track
    }
}

extension LearnNowFlowState {
    mutating func setReminderTime(_ date: Date) {
        reminderTime = date
        UserDefaults.standard.set(date, forKey: "learnnow.settings.reminderTime")
    }

    mutating func setRemindersEnabled(_ enabled: Bool) {
        remindersEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "learnnow.settings.remindersEnabled")
    }

    mutating func setNightModeEnabled(_ enabled: Bool) {
        isNightModeEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "learnnow.settings.nightMode")
    }
}

private extension LearnNowFlowState {
    mutating func loadLesson(for moduleIndex: Int) {
        guard modules.indices.contains(moduleIndex) else { return }

        loadedLessonModuleIndex = moduleIndex
        lessonPages = modules[moduleIndex].lessonPages
        currentLessonPageIndex = 0
        didAwardCompletionXP = completedLessonIDs.contains(modules[moduleIndex].id)
    }

    mutating func activateReviewCards(for module: LearnNowModuleDefinition) {
        let now = Date()
        for definition in catalog.reviewCards where module.reviewCardIDs.contains(definition.id) {
            guard !reviewCards.contains(where: { $0.id == definition.id }) else { continue }
            let memory = ReviewMemorySnapshot(
                cardID: definition.id,
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
            reviewMemoryByCardID[definition.id] = memory
            reviewCards.append(
                LearnNowReviewCard(
                    id: definition.id,
                    topic: definition.topic,
                    moduleID: definition.moduleID,
                    moduleTitle: module.title,
                    bucket: .new,
                    accent: definition.accent,
                    frontTitle: definition.frontTitle,
                    frontSubtitle: definition.frontSubtitle,
                    backTitle: definition.backTitle,
                    backBody: definition.backBody,
                    backHighlight: definition.backHighlight,
                    dueAt: now,
                    retrievability: 0,
                    isMastered: false,
                    isFavorited: false
                )
            )
        }
    }
}
