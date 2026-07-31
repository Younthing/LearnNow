import Foundation
import LearnNowContentKit

extension LearnNowFlowState {
    mutating func selectTab(_ tab: LearnNowTab, now: Date = Date()) {
        selectedTab = tab

        switch tab {
        case .home:
            currentScreen = .home
        case .routes:
            currentScreen = .routes
        case .anki:
            currentScreen = .anki
            refreshReviewBuckets(now: now)
            normalizeReviewState()
            if appliedReviewFilters.isDefault,
               activeReviewCards.isEmpty,
               !Self.defaultReviewQueue(from: reviewCards, now: now).isEmpty {
                rebuildReviewQueue(now: now)
            }
        case .profile:
            currentScreen = .profile
        }
    }

    mutating func showRoutes() {
        selectedTab = .routes
        currentScreen = .routes
        routesDestination = .overview
    }

    mutating func openPath(routeID: String? = nil) {
        if let routeID, catalog.route(id: routeID)?.interactive == true {
            selectedRouteID = routeID
        }
        selectedTab = .routes
        currentScreen = .routes
        let routeModuleIndex = selectedRouteModuleIDs.compactMap { moduleID in
            modules.firstIndex(where: { $0.id == moduleID })
        }
        .first(where: { isLessonAvailable(for: $0) })
        if let trackID = routeModuleIndex.flatMap(trackForModuleIndex) {
            selectedRouteTrackID = trackID
        } else if let firstTrackID = selectedRoute?.trackIDs.first {
            selectedRouteTrackID = firstTrackID
        }
        routesDestination = .path
    }

    mutating func openPathForLoadedLesson() {
        selectedTab = .routes
        currentScreen = .routes
        if modules.indices.contains(loadedLessonModuleIndex),
           let route = catalog.route(containingModuleID: modules[loadedLessonModuleIndex].id) {
            selectedRouteID = route.id
        }
        selectedRouteTrackID = trackForModuleIndex(loadedLessonModuleIndex) ?? selectedRouteTrackID
        routesDestination = .path
    }

    mutating func selectRouteTrack(_ trackID: String) {
        guard selectedRoute?.trackIDs.contains(trackID) == true else { return }
        selectedRouteTrackID = trackID
    }

    mutating func openLesson() {
        let targetModuleIndex: Int
        if isLessonAvailable(for: nextAvailableModuleIndex) {
            targetModuleIndex = nextAvailableModuleIndex
        } else if isLessonAvailable(for: loadedLessonModuleIndex) {
            targetModuleIndex = loadedLessonModuleIndex
        } else {
            return
        }

        if loadedLessonModuleIndex != targetModuleIndex {
            loadLesson(for: targetModuleIndex)
        }

        selectedTab = .routes
        currentScreen = .routes
        if let route = catalog.route(containingModuleID: modules[loadedLessonModuleIndex].id) {
            selectedRouteID = route.id
        }
        selectedRouteTrackID = trackForModuleIndex(loadedLessonModuleIndex) ?? selectedRouteTrackID
        routesDestination = .lesson
    }

    mutating func openLesson(moduleID: String) {
        guard let moduleIndex = modules.firstIndex(where: { $0.id == moduleID }) else { return }
        guard isLessonAvailable(for: moduleIndex) else { return }

        loadLesson(for: moduleIndex)
        selectedTab = .routes
        currentScreen = .routes
        if let route = catalog.route(containingModuleID: moduleID) {
            selectedRouteID = route.id
        }
        selectedRouteTrackID = trackForModuleIndex(moduleIndex) ?? selectedRouteTrackID
        routesDestination = .lesson
    }

    mutating func setCurrentLessonPageIndex(_ index: Int) {
        guard lessonPages.indices.contains(index) else { return }
        currentLessonPageIndex = index
    }

    mutating func answerCurrentLesson(with optionID: String) {
        guard lessonPages.indices.contains(currentLessonPageIndex) else { return }
        guard let exerciseID = lessonPages[currentLessonPageIndex].exerciseIDs.first else { return }
        answerCurrentLesson(exerciseID: exerciseID, optionID: optionID)
    }

    mutating func answerCurrentLesson(exerciseID: String, optionID: String) {
        guard lessonPages.indices.contains(currentLessonPageIndex),
              let exercise = lessonPages[currentLessonPageIndex].exercise(id: exerciseID),
              exercise.options.contains(where: { $0.id == optionID }),
              case .unanswered = lessonPages[currentLessonPageIndex].answerState(for: exerciseID)
        else { return }

        let correctOptionID = exercise.correctOptionID
        if optionID == correctOptionID {
            lessonPages[currentLessonPageIndex].answerStateByExerciseID[exerciseID] =
                .correct(optionID: optionID)
        } else {
            lessonPages[currentLessonPageIndex].answerStateByExerciseID[exerciseID] =
                .incorrect(optionID: optionID)
        }
    }

    mutating func retryCurrentLessonQuestion() {
        guard lessonPages.indices.contains(currentLessonPageIndex) else { return }
        guard let exerciseID = lessonPages[currentLessonPageIndex].exerciseIDs.first(where: {
            if case .incorrect = lessonPages[currentLessonPageIndex].answerState(for: $0) {
                return true
            }
            return false
        }) else { return }
        retryCurrentLessonExercise(id: exerciseID)
    }

    mutating func retryCurrentLessonExercise(id exerciseID: String) {
        guard lessonPages.indices.contains(currentLessonPageIndex),
              case .incorrect = lessonPages[currentLessonPageIndex].answerState(for: exerciseID)
        else { return }
        lessonPages[currentLessonPageIndex].answerStateByExerciseID[exerciseID] = .unanswered
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
        let routeCandidates = selectedRouteModuleIDs.compactMap { moduleID in
            modules.firstIndex(where: { $0.id == moduleID })
        }
        let upcomingIndex = routeCandidates.first(where: { index in
            let module = modules[index]
            return !completedLessonIDs.contains(module.id) &&
                Set(module.prerequisiteModuleIDs).isSubset(of: completedLessonIDs)
        }) ?? modules.firstIndex { module in
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
        status: LearnNowPathNode.Status,
        hasNewContent: Bool = false
    ) -> String {
        if hasNewContent {
            return "\(baseSubtitle) · 有新内容"
        }
        switch status {
        case .done:
            return "\(baseSubtitle) · 已掌握"
        case .current:
            return "\(baseSubtitle) · 进行中"
        case .locked:
            return "\(baseSubtitle) · 未解锁"
        }
    }

    /// Real in-lesson progress for the path card: visited pages / total pages.
    /// Only the current node shows a bar; locked/done use status chrome instead.
    func pathNodeProgress(for node: LearnNowPathNode) -> Double? {
        guard node.status == .current,
              let module = modules.first(where: { $0.id == node.id })
        else {
            return nil
        }

        let pageIDs = Set(module.lessonPages.map(\.id))
        guard !pageIDs.isEmpty else { return 0 }

        let visitedCount = visitedPageIDsByLessonID[node.id, default: []]
            .intersection(pageIDs)
            .count
        return Double(visitedCount) / Double(pageIDs.count)
    }

    func isLessonAvailable(for moduleIndex: Int) -> Bool {
        guard modules.indices.contains(moduleIndex) else { return false }
        let module = modules[moduleIndex]
        return Set(module.prerequisiteModuleIDs).isSubset(of: completedLessonIDs) && !module.lessonPages.isEmpty
    }

    func trackForModuleIndex(_ moduleIndex: Int) -> String? {
        guard modules.indices.contains(moduleIndex) else { return nil }
        return modules[moduleIndex].trackID
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

    mutating func setSelectedTheme(_ theme: LearnNowTheme) {
        selectedTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "learnnow.settings.theme")
        LearnNowThemeStore.current = theme
    }
}

private extension LearnNowFlowState {
    mutating func loadLesson(for moduleIndex: Int) {
        guard modules.indices.contains(moduleIndex) else { return }

        let module = modules[moduleIndex]
        loadedLessonModuleIndex = moduleIndex
        lessonPages = module.lessonPages
        if completedLessonIDs.contains(module.id),
           let firstUnvisitedIndex = lessonPages.firstIndex(where: {
               !visitedPageIDsByLessonID[module.id, default: []].contains($0.id)
           }) {
            currentLessonPageIndex = firstUnvisitedIndex
        } else {
            currentLessonPageIndex = 0
        }
        didAwardCompletionXP = completedLessonIDs.contains(module.id)
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
