import Foundation
import FSRS

struct ReviewScheduleOutcome: Equatable, Sendable {
    let rating: LearnNowReviewRating
    let dueAt: Date
    let intervalText: String
    let memory: ReviewMemorySnapshot
}

protocol ReviewScheduler: Sendable {
    func preview(
        cardID: String,
        memory: ReviewMemorySnapshot?,
        now: Date
    ) throws -> [LearnNowReviewRating: ReviewScheduleOutcome]

    func schedule(
        cardID: String,
        memory: ReviewMemorySnapshot?,
        rating: LearnNowReviewRating,
        now: Date
    ) throws -> ReviewScheduleOutcome

    func retrievability(for memory: ReviewMemorySnapshot?, now: Date) -> Double
}

struct FSRSReviewScheduler: ReviewScheduler {
    static let schedulerVersion = "FSRS-6"
    static let parametersVersion = "default-v6"

    private let scheduler: FSRS

    init() {
        scheduler = FSRS(
            parameters: FSRSParameters(
                requestRetention: 0.90,
                maximumInterval: 36_500,
                w: FSRSDefaults.defaultWv6,
                enableFuzz: false,
                enableShortTerm: true,
                learningSteps: ["1m", "10m"],
                relearningSteps: ["10m"]
            )
        )
    }

    func preview(
        cardID: String,
        memory: ReviewMemorySnapshot?,
        now: Date
    ) throws -> [LearnNowReviewRating: ReviewScheduleOutcome] {
        let preview = try scheduler.repeat(card: makeCard(from: memory, now: now), now: now)
        return try Dictionary(uniqueKeysWithValues: LearnNowReviewRating.allCases.map { rating in
            guard let item = preview[fsrsRating(for: rating)] else {
                throw ReviewSchedulerError.missingPreview(rating)
            }
            return (rating, makeOutcome(cardID: cardID, rating: rating, item: item, now: now, memory: memory))
        })
    }

    func schedule(
        cardID: String,
        memory: ReviewMemorySnapshot?,
        rating: LearnNowReviewRating,
        now: Date
    ) throws -> ReviewScheduleOutcome {
        let item = try scheduler.next(
            card: makeCard(from: memory, now: now),
            now: now,
            grade: fsrsRating(for: rating)
        )
        return makeOutcome(cardID: cardID, rating: rating, item: item, now: now, memory: memory)
    }

    func retrievability(for memory: ReviewMemorySnapshot?, now: Date) -> Double {
        guard let memory else { return 0 }
        return scheduler.getRetrievability(card: makeCard(from: memory, now: now), now: now).number
    }

    private func makeCard(from memory: ReviewMemorySnapshot?, now: Date) -> Card {
        guard let memory else {
            return Card(due: now)
        }
        return Card(
            due: memory.dueAt,
            stability: memory.stability,
            difficulty: memory.difficulty,
            elapsedDays: memory.elapsedDays,
            scheduledDays: memory.scheduledDays,
            learningSteps: memory.learningSteps,
            reps: memory.reps,
            lapses: memory.lapses,
            state: CardState(rawValue: memory.stateRawValue) ?? .new,
            lastReview: memory.lastReviewAt
        )
    }

    private func makeOutcome(
        cardID: String,
        rating: LearnNowReviewRating,
        item: RecordLogItem,
        now: Date,
        memory: ReviewMemorySnapshot?
    ) -> ReviewScheduleOutcome {
        let card = item.card
        let retrievability = scheduler.getRetrievability(card: card, now: now).number
        return ReviewScheduleOutcome(
            rating: rating,
            dueAt: card.due,
            intervalText: Self.intervalText(from: now, to: card.due),
            memory: ReviewMemorySnapshot(
                cardID: cardID,
                dueAt: card.due,
                lastReviewAt: card.lastReview ?? now,
                stability: card.stability,
                difficulty: card.difficulty,
                elapsedDays: card.elapsedDays,
                scheduledDays: card.scheduledDays,
                stateRawValue: card.state.rawValue,
                learningSteps: card.learningSteps,
                reps: card.reps,
                lapses: card.lapses,
                retrievability: retrievability,
                isFavorited: memory?.isFavorited ?? false,
                isMastered: memory?.isMastered ?? false
            )
        )
    }

    private func fsrsRating(for rating: LearnNowReviewRating) -> Rating {
        switch rating {
        case .again: .again
        case .hard: .hard
        case .good: .good
        case .easy: .easy
        }
    }

    static func intervalText(from start: Date, to due: Date) -> String {
        let seconds = max(due.timeIntervalSince(start), 0)
        if seconds < 3_600 {
            return "\(max(Int((seconds / 60).rounded()), 1))分钟"
        }
        if seconds < 86_400 {
            return "\(max(Int((seconds / 3_600).rounded()), 1))小时"
        }
        return "\(max(Int((seconds / 86_400).rounded()), 1))天"
    }
}

enum ReviewSchedulerError: LocalizedError, Equatable {
    case missingPreview(LearnNowReviewRating)

    var errorDescription: String? {
        switch self {
        case let .missingPreview(rating):
            "FSRS 未返回 \(rating.title) 的调度结果。"
        }
    }
}
