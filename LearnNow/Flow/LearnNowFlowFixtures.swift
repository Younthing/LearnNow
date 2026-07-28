import Foundation

/// Preview-only learning state. Course copy always comes from the same generated
/// CatalogV2 bundle consumed by the production app.
enum LearnNowFlowFixtures {
    static let catalog: CourseCatalog = {
        guard let url = Bundle.main.url(forResource: "CatalogV2", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? CatalogDecoder.decode(data: data)
        else {
            return .empty
        }
        return catalog
    }()

    static let learningSnapshot: LearningSnapshot = {
        let now = Date()
        let memories = [
            memory(id: "mean", dueAt: now.addingTimeInterval(-3_600)),
            memory(id: "variance", dueAt: now.addingTimeInterval(7_200), isFavorited: true),
            memory(id: "bayes", dueAt: now.addingTimeInterval(64_800)),
            memory(id: "p-value", dueAt: now.addingTimeInterval(-36_000), isFavorited: true),
            memory(id: "type-one-error", dueAt: now.addingTimeInterval(21_600), isMastered: true),
            memory(id: "regression-coef", dueAt: now.addingTimeInterval(86_400)),
            memory(
                id: "r2",
                dueAt: now.addingTimeInterval(259_200),
                isFavorited: true,
                isMastered: true
            ),
        ]

        return LearningSnapshot(
            totalXP: 1_240,
            streakDays: 12,
            completedLessonIDs: ["stats", "probability"],
            lastVisitedLessonID: "hypothesis",
            lastVisitedPageID: "hypothesis-page-1",
            visitedPageIDsByLessonID: [
                "stats": ["stats-page-1", "stats-page-2"],
                "probability": ["probability-page-1"],
                "hypothesis": ["hypothesis-page-1"],
            ],
            reviewMemoryByCardID: Dictionary(uniqueKeysWithValues: memories.map { ($0.cardID, $0) }),
            syncAvailability: .available
        )
    }()

    private static func memory(
        id: String,
        dueAt: Date,
        isFavorited: Bool = false,
        isMastered: Bool = false
    ) -> ReviewMemorySnapshot {
        ReviewMemorySnapshot(
            cardID: id,
            dueAt: dueAt,
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
            isFavorited: isFavorited,
            isMastered: isMastered
        )
    }
}
