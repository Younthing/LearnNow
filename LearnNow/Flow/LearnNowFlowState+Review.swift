import Foundation

extension LearnNowFlowState {
    mutating func openReviewBoard() {
        selectTab(.anki)
        normalizeReviewState()
    }

    mutating func openFavoritedReviewBoard() {
        appliedReviewFilters = .empty
        appliedReviewFilters.favorite = .favoritedOnly
        draftReviewFilters = appliedReviewFilters
        activeReviewSheet = nil
        currentReviewCardIndex = 0
        isCurrentReviewCardFlipped = false
        selectTab(.anki)
        normalizeReviewState()
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

    mutating func applyReviewCardPoolFilters() {
        appliedReviewFilters = draftReviewFilters
        activeReviewSheet = nil
        isCurrentReviewCardFlipped = false
        currentReviewCardIndex = 0
        normalizeReviewState()
    }

    mutating func handleReviewEmptyPrimaryAction() {
        if reviewFilterBadgeCount > 0 {
            appliedReviewFilters = .empty
            draftReviewFilters = .empty
            currentReviewCardIndex = 0
            isCurrentReviewCardFlipped = false
            normalizeReviewState()
        } else {
            selectTab(.home)
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

    mutating func rateCurrentReviewCard(_ rating: LearnNowReviewRating) {
        guard let currentID = currentReviewCard?.id else { return }
        let previousVisibleCards = activeReviewCards
        let previousPosition = min(currentReviewCardIndex, max(previousVisibleCards.count - 1, 0))

        updateScheduling(for: currentID, rating: rating)
        isCurrentReviewCardFlipped = false
        moveToNextReviewCard(after: currentID, previousPosition: previousPosition)
    }

    func filteredReviewCards(using filters: LearnNowReviewFilters) -> [LearnNowReviewCard] {
        reviewCards
            .filter { card in
                matchesTopic(card, filters: filters) &&
                matchesModule(card, filters: filters) &&
                matchesTime(card, filter: filters.time) &&
                matchesMastery(card, filter: filters.mastery) &&
                matchesFavorite(card, filter: filters.favorite)
            }
            .sorted(by: Self.reviewSort)
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

    static func feedback(for page: LearnNowLessonPage) -> LearnNowLessonFeedback? {
        switch page.answerState {
        case .unanswered:
            nil
        case .correct:
            LearnNowLessonFeedback(
                title: "漂亮，概念抓得很准。",
                body: "继续保持这个判断标准，下一页会把 P 值的真实含义彻底钉牢。",
                accent: .mint
            )
        case .incorrect:
            LearnNowLessonFeedback(
                title: "思路有点绕进去了。",
                body: "这是初学者最常见的坑，回看上方提示后再做一次会更稳。",
                accent: .pink
            )
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
    }

    mutating func toggleFavorited(for id: String) {
        guard let index = reviewCards.firstIndex(where: { $0.id == id }) else { return }
        reviewCards[index].isFavorited.toggle()
    }

    mutating func updateScheduling(for id: String, rating: LearnNowReviewRating) {
        guard let index = reviewCards.firstIndex(where: { $0.id == id }) else { return }
        let now = Date()
        let calendar = Calendar.current

        switch rating {
        case .again:
            reviewCards[index].dueAt = now.addingTimeInterval(60)
            reviewCards[index].isMastered = false
        case .hard:
            reviewCards[index].dueAt = now.addingTimeInterval(6 * 60)
        case .good:
            reviewCards[index].dueAt = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        case .easy:
            reviewCards[index].dueAt = calendar.date(byAdding: .day, value: 4, to: now) ?? now
            reviewCards[index].isMastered = true
        }
    }

    mutating func moveToNextReviewCard(after currentID: String, previousPosition: Int) {
        let cards = activeReviewCards
        guard !cards.isEmpty else {
            currentReviewCardIndex = 0
            return
        }

        if let currentPosition = cards.firstIndex(where: { $0.id == currentID }) {
            if cards.count == 1 {
                currentReviewCardIndex = currentPosition
                return
            }

            for offset in 1..<cards.count {
                let candidateIndex = (currentPosition + offset) % cards.count
                if cards[candidateIndex].id != currentID {
                    currentReviewCardIndex = candidateIndex
                    return
                }
            }

            currentReviewCardIndex = currentPosition
            return
        }

        currentReviewCardIndex = min(previousPosition, cards.count - 1)
    }

    mutating func normalizeReviewState() {
        let cards = activeReviewCards
        if cards.isEmpty {
            currentReviewCardIndex = 0
            isCurrentReviewCardFlipped = false
            return
        }

        currentReviewCardIndex = min(currentReviewCardIndex, cards.count - 1)
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

    func matchesTime(_ card: LearnNowReviewCard, filter: LearnNowReviewTimeFilter) -> Bool {
        let calendar = Calendar.current
        let now = Date()
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
