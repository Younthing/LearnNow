import Foundation
import Testing
@testable import LearnNow

@MainActor
struct MemoryTrendCalculatorTests {
    @Test
    func emptyWhenThereAreNoReviewedMemories() {
        let calculator = makeCalculator()

        let trend = calculator.calculate(memories: [
            makeMemory(cardID: "new", reps: 0),
        ])

        #expect(trend == .empty)
        #expect(trend.isEmpty)
        #expect(trend.current == nil)
        #expect(trend.seventhDay == nil)
    }

    @Test
    func producesSevenCalendarDayPointsAndConvenienceValues() {
        let calculator = makeCalculator()

        let trend = calculator.calculate(memories: [
            makeMemory(cardID: "steady", reps: 1),
        ])

        #expect(trend.points.count == 8)
        #expect(trend.points.map(\.dayOffset) == Array(0...7))
        #expect(trend.points.first?.date == clock.now)
        #expect(
            trend.points.last?.date
                == clock.calendar.date(byAdding: .day, value: 7, to: clock.now)
        )
        #expect(trend.current == trend.points.first?.retrievability)
        #expect(trend.seventhDay == trend.points.last?.retrievability)
    }

    @Test
    func averagesValuesAndBoundsTheDecayingTrend() {
        let calculator = makeCalculator()

        let trend = calculator.calculate(memories: [
            makeMemory(cardID: "high", reps: 2),
            makeMemory(cardID: "low", reps: 3),
        ])

        #expect(trend.points.map(\.retrievability) == [
            1,
            0.75,
            0.25,
            0,
            0,
            0,
            0,
            0,
        ])
        #expect(trend.points.allSatisfy { (0...1).contains($0.retrievability) })
        #expect(
            zip(trend.points, trend.points.dropFirst())
                .allSatisfy { current, next in
                    current.retrievability >= next.retrievability
                }
        )
    }

    @Test
    func ignoresNewCardsWhenCalculatingTheAverage() {
        let calculator = makeCalculator()

        let trend = calculator.calculate(memories: [
            makeMemory(cardID: "steady", reps: 1),
            makeMemory(cardID: "new", reps: 0),
        ])

        #expect(trend.points.map(\.retrievability) == [
            0.75,
            0.625,
            0.5,
            0.375,
            0.25,
            0.125,
            0,
            0,
        ])
    }

    private var clock: FixedLearnNowClock {
        let timeZone = TimeZone(identifier: "Asia/Shanghai")!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return FixedLearnNowClock(
            now: Date(timeIntervalSince1970: 1_752_787_800),
            calendar: calendar,
            timeZone: timeZone
        )
    }

    private func makeCalculator() -> MemoryTrendCalculator {
        MemoryTrendCalculator(
            scheduler: TestReviewScheduler(
                origin: clock.now,
                calendar: clock.calendar
            ),
            clock: clock
        )
    }

    private func makeMemory(
        cardID: String,
        reps: Int
    ) -> ReviewMemorySnapshot {
        ReviewMemorySnapshot(
            cardID: cardID,
            dueAt: clock.now,
            lastReviewAt: reps > 0 ? clock.now : nil,
            stability: 1,
            difficulty: 5,
            elapsedDays: 0,
            scheduledDays: 1,
            stateRawValue: reps > 0 ? 2 : 0,
            learningSteps: 0,
            reps: reps,
            lapses: 0,
            retrievability: 0,
            isFavorited: false,
            isMastered: false
        )
    }
}

private struct TestReviewScheduler: ReviewScheduler {
    let origin: Date
    let calendar: Calendar

    func preview(
        cardID: String,
        memory: ReviewMemorySnapshot?,
        now: Date
    ) throws -> [LearnNowReviewRating: ReviewScheduleOutcome] {
        throw TestReviewSchedulerError.unexpectedSchedulingCall
    }

    func schedule(
        cardID: String,
        memory: ReviewMemorySnapshot?,
        rating: LearnNowReviewRating,
        now: Date
    ) throws -> ReviewScheduleOutcome {
        throw TestReviewSchedulerError.unexpectedSchedulingCall
    }

    func retrievability(
        for memory: ReviewMemorySnapshot?,
        now: Date
    ) -> Double {
        guard let memory else { return 0 }
        let dayOffset = calendar.dateComponents(
            [.day],
            from: origin,
            to: now
        ).day ?? 0

        switch memory.cardID {
        case "high":
            return 1.5 - (Double(dayOffset) * 0.5)
        case "low":
            return 1.0 - (Double(dayOffset) * 0.5)
        case "new":
            return 10
        default:
            return 0.75 - (Double(dayOffset) * 0.125)
        }
    }
}

private enum TestReviewSchedulerError: Error {
    case unexpectedSchedulingCall
}
