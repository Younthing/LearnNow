import Foundation

struct MemoryTrendPoint: Identifiable, Equatable, Sendable {
    let dayOffset: Int
    let date: Date
    let retrievability: Double

    var id: Int { dayOffset }
}

struct MemoryTrend: Equatable, Sendable {
    let points: [MemoryTrendPoint]

    static let empty = Self(points: [])

    var isEmpty: Bool { points.isEmpty }
    var current: Double? { points.first?.retrievability }
    var seventhDay: Double? {
        guard points.indices.contains(7) else { return nil }
        return points[7].retrievability
    }
}

struct MemoryTrendCalculator: Sendable {
    private let scheduler: any ReviewScheduler
    private let clock: any LearnNowClock

    init(
        scheduler: any ReviewScheduler,
        clock: any LearnNowClock
    ) {
        self.scheduler = scheduler
        self.clock = clock
    }

    func calculate<Memories: Sequence>(
        memories: Memories
    ) -> MemoryTrend where Memories.Element == ReviewMemorySnapshot {
        let reviewedMemories = memories.filter { $0.reps > 0 }
        guard !reviewedMemories.isEmpty else { return .empty }

        let now = clock.now
        let calendar = clock.calendar
        let points = (0...7).map { dayOffset in
            let date = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: now
            ) ?? now
            let total = reviewedMemories.reduce(0.0) { result, memory in
                result + scheduler.retrievability(for: memory, now: date)
            }
            let average = total / Double(reviewedMemories.count)

            return MemoryTrendPoint(
                dayOffset: dayOffset,
                date: date,
                retrievability: bounded(average)
            )
        }

        return MemoryTrend(points: points)
    }

    private func bounded(_ value: Double) -> Double {
        guard !value.isNaN else { return 0 }
        return min(max(value, 0), 1)
    }
}
