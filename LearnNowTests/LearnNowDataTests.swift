import Foundation
import SwiftData
import Testing
@testable import LearnNow

@MainActor
struct LearnNowDataTests {
    @Test
    func catalogDecodesValidDocument() throws {
        let catalog = try CatalogDecoder.decode(data: catalogData())

        #expect(catalog.schemaVersion == 1)
        #expect(catalog.modules.map(\.id) == ["first", "second"])
        #expect(catalog.modules[1].prerequisiteModuleIDs == ["first"])
        #expect(catalog.modules[0].lessonPages[0].question.correctOptionID == "yes")
    }

    @Test(arguments: [
        CatalogMutation.duplicateModuleID,
        .missingPrerequisite,
        .prerequisiteCycle,
        .missingCorrectOption,
        .emptyPages,
        .unsupportedVersion,
    ])
    func catalogRejectsInvalidDocuments(_ mutation: CatalogMutation) {
        #expect(throws: (any Error).self) {
            try CatalogDecoder.decode(data: catalogData(mutation: mutation))
        }
    }

    @Test
    func progressAndIdempotentCompletionSurviveRepositoryReload() async throws {
        let catalog = try CatalogDecoder.decode(data: catalogData())
        let container = try LearnNowModelContainerFactory.make(cloudSyncEnabled: false, inMemory: true)
        let context = ModelContext(container)
        let clock = fixedClock()
        let repository = SwiftDataLearningRepository(
            context: context,
            clock: clock,
            scheduler: FSRSReviewScheduler(),
            syncAvailabilityOverride: .localOnly
        )

        try repository.recordPageVisit(lessonID: "first", pageID: "first-page", pageOrder: 0)
        #expect(try repository.completeLesson(lessonID: "first", xp: 15))
        #expect(try !repository.completeLesson(lessonID: "first", xp: 15))
        try repository.setCardPreference(cardID: "card", isFavorited: true, isMastered: true)

        let snapshot = try await repository.loadSnapshot(catalog: catalog)
        #expect(snapshot.totalXP == 15)
        #expect(snapshot.completedLessonIDs == ["first"])
        #expect(snapshot.lastVisitedLessonID == "first")
        #expect(snapshot.lastVisitedPageID == "first-page")
        #expect(snapshot.syncAvailability == .localOnly)
        #expect(snapshot.reviewMemoryByCardID["card"] != nil)
        #expect(snapshot.reviewMemoryByCardID["card"]?.isFavorited == true)
        #expect(snapshot.reviewMemoryByCardID["card"]?.isMastered == true)
    }

    @Test
    func mergeRulesPreventDuplicateXPAndChooseFurthestProgress() async throws {
        let catalog = try CatalogDecoder.decode(data: catalogData())
        let container = try LearnNowModelContainerFactory.make(cloudSyncEnabled: false, inMemory: true)
        let context = ModelContext(container)
        let now = fixedClock().now
        context.insert(
            LessonProgressRecord(
                lessonID: "first",
                lastPageID: "first-page",
                highestPageOrder: 0,
                completedAt: nil,
                updatedAt: now
            )
        )
        context.insert(
            LessonProgressRecord(
                lessonID: "first",
                lastPageID: "first-page",
                highestPageOrder: 3,
                completedAt: now,
                updatedAt: now.addingTimeInterval(-60)
            )
        )
        for offset in [0.0, 1.0] {
            context.insert(
                LearningEventRecord(
                    eventKey: "lesson-completion:first",
                    kindRawValue: "lessonCompletion",
                    contentID: "first",
                    occurredAt: now.addingTimeInterval(offset),
                    localDay: "2026-07-18",
                    timeZoneID: "Asia/Shanghai",
                    xpDelta: 15
                )
            )
        }
        try context.save()

        let repository = SwiftDataLearningRepository(
            context: context,
            clock: fixedClock(),
            syncAvailabilityOverride: .localOnly
        )
        let snapshot = try await repository.loadSnapshot(catalog: catalog)

        #expect(snapshot.completedLessonIDs == ["first"])
        #expect(snapshot.highestPageOrderByLessonID["first"] == 3)
        #expect(snapshot.totalXP == 15)
    }

    @Test
    func fsrsPreviewAndCommitUseCalculatedIntervals() throws {
        let scheduler = FSRSReviewScheduler()
        let now = fixedClock().now
        let previews = try scheduler.preview(cardID: "card", memory: nil, now: now)
        #expect(previews[.again]?.intervalText == "1分钟")
        #expect(previews[.hard]?.intervalText == "6分钟")
        #expect(previews[.good]?.intervalText == "10分钟")
        #expect(previews[.easy]?.intervalText == "8天")

        #expect(Set(previews.keys) == Set(LearnNowReviewRating.allCases))
        #expect(previews[.again]?.dueAt != previews[.easy]?.dueAt)
        #expect(previews.values.allSatisfy { !$0.intervalText.isEmpty })

        let committed = try scheduler.schedule(cardID: "card", memory: nil, rating: .good, now: now)
        #expect(committed.memory.reps == 1)
        #expect(committed.dueAt > now)
        #expect(committed.memory.isMastered == false)
    }

    @Test
    func reviewLogWritesAndLocalCacheCanBeRebuilt() async throws {
        let catalog = try CatalogDecoder.decode(data: catalogData())
        let container = try LearnNowModelContainerFactory.make(cloudSyncEnabled: false, inMemory: true)
        let context = ModelContext(container)
        let repository = SwiftDataLearningRepository(
            context: context,
            clock: fixedClock(),
            syncAvailabilityOverride: .localOnly
        )
        _ = try repository.completeLesson(lessonID: "first", xp: 15)
        let initial = try await repository.loadSnapshot(catalog: catalog)
        _ = try repository.recordReview(
            cardID: "card",
            memory: initial.reviewMemoryByCardID["card"],
            rating: .good
        )

        let logs = try context.fetch(FetchDescriptor<ReviewLogRecord>())
        let caches = try context.fetch(FetchDescriptor<ReviewScheduleCacheRecord>())
        #expect(logs.count == 1)
        #expect(caches.count == 1)

        context.delete(caches[0])
        try context.save()
        let rebuilt = try await repository.loadSnapshot(catalog: catalog)
        #expect(rebuilt.reviewMemoryByCardID["card"]?.reps == 1)
        #expect(try context.fetch(FetchDescriptor<ReviewScheduleCacheRecord>()).count == 1)
    }

    @Test
    func unknownContentProgressIsIgnoredWithoutDiscardingHistory() async throws {
        let catalog = try CatalogDecoder.decode(data: catalogData())
        let container = try LearnNowModelContainerFactory.make(cloudSyncEnabled: false, inMemory: true)
        let context = ModelContext(container)
        context.insert(
            LessonProgressRecord(
                lessonID: "removed-lesson",
                lastPageID: "removed-page",
                highestPageOrder: 9,
                completedAt: fixedClock().now,
                updatedAt: fixedClock().now
            )
        )
        context.insert(
            ReviewLogRecord(
                cardID: "removed-card",
                ratingRawValue: "good",
                reviewedAt: fixedClock().now,
                localDay: "2026-07-18",
                timeZoneID: "Asia/Shanghai",
                schedulerVersion: "FSRS-6",
                parametersVersion: "default-v6",
                elapsedDays: 0,
                scheduledDays: 1,
                dueAt: fixedClock().now.addingTimeInterval(86_400),
                stability: 1,
                difficulty: 5,
                stateRawValue: 2,
                learningSteps: 0,
                reps: 1,
                lapses: 0
            )
        )
        try context.save()
        let repository = SwiftDataLearningRepository(
            context: context,
            clock: fixedClock(),
            syncAvailabilityOverride: .localOnly
        )

        let snapshot = try await repository.loadSnapshot(catalog: catalog)
        #expect(snapshot.completedLessonIDs.isEmpty)
        #expect(snapshot.lastVisitedLessonID == nil)
        #expect(snapshot.highestPageOrderByLessonID["removed-lesson"] == nil)
        #expect(snapshot.reviewMemoryByCardID["removed-card"] == nil)
        #expect(try context.fetch(FetchDescriptor<LessonProgressRecord>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<ReviewLogRecord>()).count == 1)
    }

    @Test
    func eventDayKeyUsesInjectedTimeZoneAcrossDateBoundary() throws {
        let instant = ISO8601DateFormatter().date(from: "2026-07-18T16:30:00Z")!

        let shanghaiContainer = try LearnNowModelContainerFactory.make(cloudSyncEnabled: false, inMemory: true)
        let shanghaiContext = ModelContext(shanghaiContainer)
        let shanghaiRepository = SwiftDataLearningRepository(
            context: shanghaiContext,
            clock: fixedClock(now: instant, timeZoneID: "Asia/Shanghai"),
            syncAvailabilityOverride: .localOnly
        )
        _ = try shanghaiRepository.completeLesson(lessonID: "first", xp: 15)

        let losAngelesContainer = try LearnNowModelContainerFactory.make(cloudSyncEnabled: false, inMemory: true)
        let losAngelesContext = ModelContext(losAngelesContainer)
        let losAngelesRepository = SwiftDataLearningRepository(
            context: losAngelesContext,
            clock: fixedClock(now: instant, timeZoneID: "America/Los_Angeles"),
            syncAvailabilityOverride: .localOnly
        )
        _ = try losAngelesRepository.completeLesson(lessonID: "first", xp: 15)

        #expect(try shanghaiContext.fetch(FetchDescriptor<LearningEventRecord>()).first?.localDay == "2026-07-19")
        #expect(try losAngelesContext.fetch(FetchDescriptor<LearningEventRecord>()).first?.localDay == "2026-07-18")
    }

    @Test
    func deviceOnlySettingsRestoreWithoutEnteringCloudModels() {
        let defaults = UserDefaults.standard
        let reminderKey = "learnnow.settings.reminderTime"
        let enabledKey = "learnnow.settings.remindersEnabled"
        let nightKey = "learnnow.settings.nightMode"
        let oldReminder = defaults.object(forKey: reminderKey)
        let oldEnabled = defaults.object(forKey: enabledKey)
        let oldNight = defaults.object(forKey: nightKey)
        defer {
            restore(oldReminder, key: reminderKey, defaults: defaults)
            restore(oldEnabled, key: enabledKey, defaults: defaults)
            restore(oldNight, key: nightKey, defaults: defaults)
        }

        let reminder = Date(timeIntervalSince1970: 1_752_800_400)
        var flow = LearnNowFlowState()
        flow.setReminderTime(reminder)
        flow.setRemindersEnabled(false)
        flow.setNightModeEnabled(true)

        let restored = LearnNowFlowState()
        #expect(restored.reminderTime == reminder)
        #expect(restored.remindersEnabled == false)
        #expect(restored.isNightModeEnabled == true)
    }

    enum CatalogMutation: CaseIterable, CustomTestStringConvertible {
        case duplicateModuleID
        case missingPrerequisite
        case prerequisiteCycle
        case missingCorrectOption
        case emptyPages
        case unsupportedVersion

        var testDescription: String { String(describing: self) }
    }

    private func fixedClock() -> FixedLearnNowClock {
        fixedClock(
            now: Date(timeIntervalSince1970: 1_752_787_800),
            timeZoneID: "Asia/Shanghai"
        )
    }

    private func fixedClock(now: Date, timeZoneID: String) -> FixedLearnNowClock {
        let timeZone = TimeZone(identifier: timeZoneID)!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return FixedLearnNowClock(
            now: now,
            calendar: calendar,
            timeZone: timeZone
        )
    }

    private func restore(_ value: Any?, key: String, defaults: UserDefaults) {
        if let value {
            defaults.set(value, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }

    private func catalogData(mutation: CatalogMutation? = nil) -> Data {
        var version = 1
        var firstID = "first"
        var secondPrerequisites = ["first"]
        var firstPrerequisites: [String] = []
        var correctOptionID = "yes"
        var firstPages = pageJSON(id: "first-page", correctOptionID: correctOptionID)

        switch mutation {
        case .duplicateModuleID:
            firstID = "second"
        case .missingPrerequisite:
            secondPrerequisites = ["missing"]
        case .prerequisiteCycle:
            firstPrerequisites = ["second"]
        case .missingCorrectOption:
            correctOptionID = "missing"
            firstPages = pageJSON(id: "first-page", correctOptionID: correctOptionID)
        case .emptyPages:
            firstPages = ""
        case .unsupportedVersion:
            version = 2
        case nil:
            break
        }

        let json = """
        {
          "schemaVersion": \(version),
          "primaryRouteID": "route",
          "routes": [{
            "id": "route", "title": "Route", "subtitle": "Subtitle", "accent": "blue",
            "cta": "继续学习", "interactive": true, "moduleIDs": ["first", "second"]
          }],
          "modules": [
            {
              "id": "\(firstID)", "track": "statistics", "title": "First", "subtitle": "1",
              "lessonTitle": "First", "prerequisiteModuleIDs": \(jsonArray(firstPrerequisites)),
              "completionXP": 15, "reviewCardIDs": ["card"], "reviewMessage": "Review",
              "pages": [\(firstPages)]
            },
            {
              "id": "second", "track": "machineLearning", "title": "Second", "subtitle": "1",
              "lessonTitle": "Second", "prerequisiteModuleIDs": \(jsonArray(secondPrerequisites)),
              "completionXP": 15, "reviewCardIDs": [], "reviewMessage": "Review",
              "pages": [\(pageJSON(id: "second-page", correctOptionID: "yes"))]
            }
          ],
          "reviewCards": [{
            "id": "card", "topic": "Topic", "moduleID": "first", "accent": "mint",
            "frontTitle": "Front", "frontSubtitle": null, "backTitle": "Back",
            "backBody": "Body", "backHighlight": "Highlight"
          }],
          "dailyTips": [{
            "id": "tip", "title": "Tip", "body": "Body", "systemImage": "lightbulb", "accent": "amber"
          }]
        }
        """
        return Data(json.utf8)
    }

    private func pageJSON(id: String, correctOptionID: String) -> String {
        """
        {
          "id": "\(id)", "badge": "1 / 1", "accent": "blue", "title": "Page",
          "summary": "Summary", "calloutTitle": "Callout", "calloutBody": "Body",
          "calloutAccent": "mint", "codeSample": null,
          "quiz": {
            "prompt": "Question", "options": [{"id": "yes", "badge": "A", "title": "Yes"}],
            "correctOptionID": "\(correctOptionID)"
          }
        }
        """
    }

    private func jsonArray(_ values: [String]) -> String {
        "[" + values.map { "\"\($0)\"" }.joined(separator: ",") + "]"
    }
}
