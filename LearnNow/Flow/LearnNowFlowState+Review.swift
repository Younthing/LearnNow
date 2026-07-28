import Foundation

extension LearnNowFlowState {
    mutating func openReviewBoard(now: Date = Date()) {
        selectTab(.anki, now: now)
        rebuildReviewQueue(now: now)
    }

    mutating func openFavoritedReviewBoard(now: Date = Date()) {
        appliedReviewFilters = .empty
        appliedReviewFilters.favorite = .favoritedOnly
        draftReviewFilters = appliedReviewFilters
        activeReviewSheet = nil
        selectTab(.anki, now: now)
        rebuildReviewQueue(now: now, includesFutureCards: true)
    }

    mutating func openReviewCardPool() {
        draftReviewFilters = appliedReviewFilters
        activeReviewSheet = .cardPool
    }

    mutating func dismissReviewSheet() {
        draftReviewFilters = appliedReviewFilters
        activeReviewSheet = nil
    }

    mutating func resetDraftReviewFilters() {
        draftReviewFilters = .empty
    }

    mutating func toggleDraftTopic(_ topic: String) {
        if draftReviewFilters.topics.contains(topic) {
            draftReviewFilters.topics.remove(topic)
        } else {
            draftReviewFilters.topics.insert(topic)
        }
    }

    mutating func toggleDraftModule(_ moduleID: String) {
        if draftReviewFilters.moduleIDs.contains(moduleID) {
            draftReviewFilters.moduleIDs.remove(moduleID)
        } else {
            draftReviewFilters.moduleIDs.insert(moduleID)
        }
    }

    mutating func setDraftTimeFilter(_ filter: LearnNowReviewTimeFilter) {
        draftReviewFilters.time = filter
    }

    mutating func setDraftMasteryFilter(_ filter: LearnNowReviewMasteryFilter) {
        draftReviewFilters.mastery = filter
    }

    mutating func setDraftFavoriteFilter(_ filter: LearnNowReviewFavoriteFilter) {
        draftReviewFilters.favorite = filter
    }

    mutating func applyReviewCardPoolFilters(now: Date = Date()) {
        appliedReviewFilters = draftReviewFilters
        activeReviewSheet = nil
        rebuildReviewQueue(now: now, includesFutureCards: true)
    }

    mutating func handleReviewEmptyPrimaryAction(now: Date = Date()) {
        if isReviewQueueCompleted || reviewFilterBadgeCount == 0 {
            selectTab(.home, now: now)
        } else {
            appliedReviewFilters = .empty
            draftReviewFilters = .empty
            rebuildReviewQueue(now: now)
        }
    }

    mutating func flipCurrentReviewCard() {
        guard currentReviewCard != nil else { return }
        isCurrentReviewCardFlipped = true
    }

    mutating func showCurrentReviewQuestion() {
        guard currentReviewCard != nil else { return }
        isCurrentReviewCardFlipped = false
    }

    mutating func toggleCurrentReviewCardMastered() {
        guard let currentID = currentReviewCard?.id else { return }
        toggleMastered(for: currentID)
        normalizeReviewState()
    }

    mutating func toggleCurrentReviewCardFavorited() {
        guard let currentID = currentReviewCard?.id else { return }
        toggleFavorited(for: currentID)
        normalizeReviewState()
    }

    mutating func toggleReviewCardMastered(id: String) {
        toggleMastered(for: id)
        normalizeReviewState()
    }

    mutating func toggleReviewCardFavorited(id: String) {
        toggleFavorited(for: id)
        normalizeReviewState()
    }

    mutating func setReviewPreviews(_ previews: [LearnNowReviewRating: ReviewScheduleOutcome]) {
        reviewIntervalTextByRating = previews.mapValues(\.intervalText)
    }

    mutating func applyReviewOutcome(
        _ outcome: ReviewScheduleOutcome,
        now: Date = Date()
    ) {
        let currentID = outcome.memory.cardID
        guard currentReviewCard?.id == currentID else { return }
        reviewMemoryByCardID[currentID] = outcome.memory
        if let index = reviewCards.firstIndex(where: { $0.id == currentID }) {
            reviewCards[index].dueAt = outcome.dueAt
            reviewCards[index].retrievability = outcome.memory.retrievability
            reviewCards[index].bucket = Self.reviewBucket(for: outcome.memory, now: now)
        }
        isCurrentReviewCardFlipped = false
        moveToNextReviewCard()
    }

    func filteredReviewCards(
        using filters: LearnNowReviewFilters,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [LearnNowReviewCard] {
        reviewCards
            .filter { card in
                matchesTopic(card, filters: filters) &&
                matchesModule(card, filters: filters) &&
                matchesTime(card, filter: filters.time, now: now, calendar: calendar) &&
                matchesMastery(card, filter: filters.mastery) &&
                matchesFavorite(card, filter: filters.favorite)
            }
            .sorted(by: Self.reviewSort)
    }

    mutating func rebuildReviewQueue(
        now: Date,
        calendar: Calendar = .current,
        includesFutureCards: Bool = false
    ) {
        refreshReviewBuckets(now: now)
        let scopedCards = filteredReviewCards(
            using: appliedReviewFilters,
            now: now,
            calendar: calendar
        )
        let queuedCards = includesFutureCards || !appliedReviewFilters.isDefault
            ? scopedCards
            : Self.defaultReviewQueue(from: scopedCards, now: now)
        reviewQueueCardIDs = queuedCards.map(\.id)
        currentReviewCardIndex = 0
        isCurrentReviewCardFlipped = false
    }

    func facets(
        groupedBy keyPath: KeyPath<LearnNowReviewCard, String>,
        title titleKeyPath: KeyPath<LearnNowReviewCard, String>
    ) -> [LearnNowReviewFacet] {
        Dictionary(grouping: reviewCards, by: { $0[keyPath: keyPath] })
            .values
            .compactMap { cards in
                guard let first = cards.first else { return nil }
                return LearnNowReviewFacet(
                    id: first[keyPath: keyPath],
                    title: first[keyPath: titleKeyPath],
                    accent: first.accent,
                    count: cards.count
                )
            }
            .sorted { lhs, rhs in
                if lhs.count == rhs.count {
                    return lhs.title < rhs.title
                }
                return lhs.count > rhs.count
            }
    }

    static func dueLabel(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if date < calendar.startOfDay(for: now) {
            return "已到期"
        }

        if calendar.isDateInToday(date) {
            return "今天复习"
        }

        if calendar.isDateInTomorrow(date) {
            return "明天复习"
        }

        let dayDistance = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)).day ?? 0
        if dayDistance > 1 && dayDistance < 7 {
            return "\(dayDistance) 天后"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}

extension LearnNowFlowState {
    mutating func toggleMastered(for id: String) {
        guard let index = reviewCards.firstIndex(where: { $0.id == id }) else { return }
        reviewCards[index].isMastered.toggle()
        updateMemoryPreference(for: id, cardIndex: index)
    }

    mutating func toggleFavorited(for id: String) {
        guard let index = reviewCards.firstIndex(where: { $0.id == id }) else { return }
        reviewCards[index].isFavorited.toggle()
        updateMemoryPreference(for: id, cardIndex: index)
    }

    mutating func refreshReviewBuckets(now: Date) {
        for index in reviewCards.indices {
            guard let memory = reviewMemoryByCardID[reviewCards[index].id] else { continue }
            reviewCards[index].bucket = Self.reviewBucket(for: memory, now: now)
        }
    }

    mutating func moveToNextReviewCard() {
        currentReviewCardIndex = min(currentReviewCardIndex + 1, reviewQueueCardIDs.count)
    }

    mutating func normalizeReviewState() {
        let knownCardIDs = Set(reviewCards.map(\.id))
        reviewQueueCardIDs.removeAll { !knownCardIDs.contains($0) }
        currentReviewCardIndex = min(currentReviewCardIndex, reviewQueueCardIDs.count)
        if currentReviewCard == nil {
            isCurrentReviewCardFlipped = false
        }
    }

    mutating func updateMemoryPreference(for id: String, cardIndex: Int) {
        guard let memory = reviewMemoryByCardID[id] else { return }
        reviewMemoryByCardID[id] = ReviewMemorySnapshot(
            cardID: memory.cardID,
            dueAt: memory.dueAt,
            lastReviewAt: memory.lastReviewAt,
            stability: memory.stability,
            difficulty: memory.difficulty,
            elapsedDays: memory.elapsedDays,
            scheduledDays: memory.scheduledDays,
            stateRawValue: memory.stateRawValue,
            learningSteps: memory.learningSteps,
            reps: memory.reps,
            lapses: memory.lapses,
            retrievability: memory.retrievability,
            isFavorited: reviewCards[cardIndex].isFavorited,
            isMastered: reviewCards[cardIndex].isMastered
        )
    }

    func matchesTopic(_ card: LearnNowReviewCard, filters: LearnNowReviewFilters) -> Bool {
        filters.topics.isEmpty || filters.topics.contains(card.topic)
    }

    func matchesModule(_ card: LearnNowReviewCard, filters: LearnNowReviewFilters) -> Bool {
        filters.moduleIDs.isEmpty || filters.moduleIDs.contains(card.moduleID)
    }

    func matchesMastery(_ card: LearnNowReviewCard, filter: LearnNowReviewMasteryFilter) -> Bool {
        switch filter {
        case .all:
            true
        case .masteredOnly:
            card.isMastered
        case .unmasteredOnly:
            !card.isMastered
        }
    }

    func matchesFavorite(_ card: LearnNowReviewCard, filter: LearnNowReviewFavoriteFilter) -> Bool {
        switch filter {
        case .all:
            true
        case .favoritedOnly:
            card.isFavorited
        }
    }

    func matchesTime(
        _ card: LearnNowReviewCard,
        filter: LearnNowReviewTimeFilter,
        now: Date,
        calendar: Calendar
    ) -> Bool {
        let startOfToday = calendar.startOfDay(for: now)

        switch filter {
        case .all:
            return true
        case .overdue:
            return card.dueAt < startOfToday
        case .today:
            return calendar.isDate(card.dueAt, inSameDayAs: now)
        case .nextThreeDays:
            guard let end = calendar.date(byAdding: .day, value: 3, to: startOfToday) else { return true }
            return card.dueAt >= startOfToday && card.dueAt < end
        case .thisWeek:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return true }
            return weekInterval.contains(card.dueAt)
        }
    }

    static let reviewSort: (LearnNowReviewCard, LearnNowReviewCard) -> Bool = { lhs, rhs in
        if lhs.dueAt == rhs.dueAt {
            if lhs.moduleTitle == rhs.moduleTitle {
                return lhs.frontTitle < rhs.frontTitle
            }
            return lhs.moduleTitle < rhs.moduleTitle
        }
        return lhs.dueAt < rhs.dueAt
    }
}
