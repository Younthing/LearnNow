import Foundation
import LearnNowContentKit
import SwiftData
import Testing
@testable import LearnNow

@MainActor
struct LearnNowDataTests {
    @Test
    func catalogDecodesValidDocument() throws {
        let catalog = try CatalogDecoder.decode(data: catalogData())

        #expect(catalog.schemaVersion == 2)
        #expect(catalog.modules.map(\.id) == ["first", "second"])
        #expect(catalog.modules[1].prerequisiteModuleIDs == ["first"])
        #expect(catalog.modules[0].lessonPages[0].exercises[0].correctOptionID == "yes")
    }

    @Test
    func bundledV2PreservesPublishedStableIDsAndOrderedLessonBlocks() throws {
        let v2URL = try #require(Bundle.main.url(forResource: "CatalogV2", withExtension: "json"))
        let v2Data = try Data(contentsOf: v2URL)
        let v2Document = try DeterministicJSON.decode(CatalogDocumentV2.self, from: v2Data)
        let catalog = try CatalogDecoder.decode(data: v2Data)

        #expect(Set(v2Document.routes.map(\.id)) == ["datascience", "design", "web"])
        #expect(Set(v2Document.modules.map(\.id)) == ["stats", "probability", "hypothesis", "regression"])
        #expect(
            Set(v2Document.lessons.map(\.id)) == [
                "stats-page-1",
                "stats-page-2",
                "probability-page-1",
                "hypothesis-page-1",
                "hypothesis-page-2",
                "regression-page-1",
                "regression-page-2",
            ]
        )
        #expect(
            Set(v2Document.reviewCards.map(\.id)) == [
                "mean",
                "variance",
                "bayes",
                "p-value",
                "type-one-error",
                "regression-coef",
                "r2",
            ]
        )
        #expect(Set(v2Document.knowledgeTips.map(\.id)) == ["mean-tip", "p-value-tip"])

        let firstPage = try #require(catalog.module(id: "stats")?.lessonPages.first)
        #expect(firstPage.id == "stats-page-1")
        #expect(firstPage.exerciseIDs == ["stats-page-1.quiz"])
        #expect(firstPage.blocks.count == 4)
        if case .paragraph = firstPage.blocks[0] {
            // Expected first block.
        } else {
            Issue.record("The first lesson block should remain a paragraph.")
        }
        if case .callout = firstPage.blocks[1] {
            // Expected second block.
        } else {
            Issue.record("The second lesson block should remain a callout.")
        }
        if case .code = firstPage.blocks[2] {
            // Expected third block.
        } else {
            Issue.record("The third lesson block should remain code.")
        }
        if case .singleChoice = firstPage.blocks[3] {
            // Expected final block.
        } else {
            Issue.record("The exercise should remain at its authored block position.")
        }
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
    func legacyHighestPageOrderMigratesToStablePageIDsOnlyOnce() async throws {
        let catalog = try bundledCatalog()
        let stats = try #require(catalog.module(id: "stats"))
        let expectedPageIDs = Set(stats.lessonPages.map(\.id))
        let container = try LearnNowModelContainerFactory.make(
            cloudSyncEnabled: false,
            inMemory: true
        )
        let context = ModelContext(container)
        context.insert(
            LessonProgressRecord(
                lessonID: stats.id,
                lastPageID: stats.lessonPages.last?.id,
                highestPageOrder: stats.lessonPages.count - 1,
                updatedAt: fixedClock().now
            )
        )
        try context.save()

        let repository = SwiftDataLearningRepository(
            context: context,
            clock: fixedClock(),
            syncAvailabilityOverride: .localOnly
        )
        let migrated = try await repository.loadSnapshot(catalog: catalog)
        let migratedEvents = try context.fetch(FetchDescriptor<LearningEventRecord>())
            .filter { $0.kindRawValue == "pageVisit" }

        #expect(migrated.visitedPageIDsByLessonID[stats.id] == expectedPageIDs)
        #expect(Set(migratedEvents.map(\.contentID)) == expectedPageIDs)

        let reloaded = try await repository.loadSnapshot(catalog: catalog)
        let reloadedEvents = try context.fetch(FetchDescriptor<LearningEventRecord>())
            .filter { $0.kindRawValue == "pageVisit" }
        #expect(reloaded.visitedPageIDsByLessonID[stats.id] == expectedPageIDs)
        #expect(reloadedEvents.count == migratedEvents.count)
    }

    @Test
    func removedStablePageVisitPreventsLegacyOrderFromBeingReinterpreted() async throws {
        let catalog = try bundledCatalog()
        let stats = try #require(catalog.module(id: "stats"))
        let retiredPageID = "stats-page-retired"
        let container = try LearnNowModelContainerFactory.make(
            cloudSyncEnabled: false,
            inMemory: true
        )
        let context = ModelContext(container)
        context.insert(
            LessonProgressRecord(
                lessonID: stats.id,
                lastPageID: retiredPageID,
                highestPageOrder: stats.lessonPages.count - 1,
                updatedAt: fixedClock().now
            )
        )
        context.insert(
            LearningEventRecord(
                eventKey: "page-visit:\(stats.id):\(retiredPageID)",
                kindRawValue: "pageVisit",
                contentID: retiredPageID,
                occurredAt: fixedClock().now,
                localDay: "2026-07-18",
                timeZoneID: "Asia/Shanghai",
                xpDelta: 0
            )
        )
        try context.save()

        let repository = SwiftDataLearningRepository(
            context: context,
            clock: fixedClock(),
            syncAvailabilityOverride: .localOnly
        )
        let snapshot = try await repository.loadSnapshot(catalog: catalog)
        let pageVisitEvents = try context.fetch(FetchDescriptor<LearningEventRecord>())
            .filter { $0.kindRawValue == "pageVisit" }

        #expect(snapshot.visitedPageIDsByLessonID[stats.id, default: []].isEmpty)
        #expect(pageVisitEvents.map(\.contentID) == [retiredPageID])
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
    func easyReviewSchedulesCardBeyondToday() throws {
        let clock = fixedClock()
        let outcome = try FSRSReviewScheduler().schedule(
            cardID: "card",
            memory: nil,
            rating: .easy,
            now: clock.now
        )
        let tomorrow = try #require(
            clock.calendar.date(
                byAdding: .day,
                value: 1,
                to: clock.calendar.startOfDay(for: clock.now)
            )
        )

        #expect(outcome.rating == .easy)
        #expect(outcome.dueAt >= tomorrow)
        #expect(outcome.memory.dueAt == outcome.dueAt)
        #expect(outcome.memory.reps == 1)
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
    func replacementCardIDStartsFreshWhileRetiredFSRSHistoryRemainsStored() async throws {
        let catalog = try CatalogDecoder.decode(
            data: catalogData(reviewCardID: "card-v2", retiredIDs: ["card"])
        )
        let container = try LearnNowModelContainerFactory.make(
            cloudSyncEnabled: false,
            inMemory: true
        )
        let context = ModelContext(container)
        let now = fixedClock().now
        context.insert(
            LessonProgressRecord(
                lessonID: "first",
                lastPageID: "first-page",
                highestPageOrder: 0,
                completedAt: now,
                updatedAt: now
            )
        )
        context.insert(
            ReviewLogRecord(
                cardID: "card",
                ratingRawValue: "easy",
                reviewedAt: now,
                localDay: "2026-07-18",
                timeZoneID: "Asia/Shanghai",
                schedulerVersion: "FSRS-6",
                parametersVersion: "default-v6",
                elapsedDays: 14,
                scheduledDays: 30,
                dueAt: now.addingTimeInterval(30 * 86_400),
                stability: 20,
                difficulty: 2,
                stateRawValue: 2,
                learningSteps: 0,
                reps: 8,
                lapses: 1
            )
        )
        try context.save()

        let repository = SwiftDataLearningRepository(
            context: context,
            clock: fixedClock(),
            syncAvailabilityOverride: .localOnly
        )
        let snapshot = try await repository.loadSnapshot(catalog: catalog)
        let retainedLogs = try context.fetch(FetchDescriptor<ReviewLogRecord>())

        #expect(snapshot.reviewMemoryByCardID["card"] == nil)
        #expect(snapshot.reviewMemoryByCardID["card-v2"]?.reps == 0)
        #expect(snapshot.reviewMemoryByCardID["card-v2"]?.stability == 0)
        #expect(retainedLogs.count == 1)
        #expect(retainedLogs.first?.cardID == "card")
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
        let themeKey = "learnnow.settings.theme"
        let oldReminder = defaults.object(forKey: reminderKey)
        let oldEnabled = defaults.object(forKey: enabledKey)
        let oldNight = defaults.object(forKey: nightKey)
        let oldTheme = defaults.object(forKey: themeKey)
        defer {
            restore(oldReminder, key: reminderKey, defaults: defaults)
            restore(oldEnabled, key: enabledKey, defaults: defaults)
            restore(oldNight, key: nightKey, defaults: defaults)
            restore(oldTheme, key: themeKey, defaults: defaults)
            LearnNowThemeStore.current = .emerald
        }

        let reminder = Date(timeIntervalSince1970: 1_752_800_400)
        var flow = LearnNowFlowState()
        flow.setReminderTime(reminder)
        flow.setRemindersEnabled(false)
        flow.setNightModeEnabled(true)
        flow.setSelectedTheme(.sand)

        let restored = LearnNowFlowState()
        #expect(restored.reminderTime == reminder)
        #expect(restored.remindersEnabled == false)
        #expect(restored.isNightModeEnabled == true)
        #expect(restored.selectedTheme == .sand)
        #expect(LearnNowThemeStore.current == .sand)
    }

    @Test
    func selectedThemeDefaultsToEmeraldAndFallsBackFromInvalidRawValue() {
        let defaults = UserDefaults.standard
        let themeKey = "learnnow.settings.theme"
        let oldTheme = defaults.object(forKey: themeKey)
        defer {
            restore(oldTheme, key: themeKey, defaults: defaults)
            LearnNowThemeStore.current = .emerald
        }

        defaults.removeObject(forKey: themeKey)
        let defaultFlow = LearnNowFlowState()
        #expect(defaultFlow.selectedTheme == .emerald)
        #expect(LearnNowThemeStore.current == .emerald)

        defaults.set("not-a-theme", forKey: themeKey)
        let fallbackFlow = LearnNowFlowState()
        #expect(fallbackFlow.selectedTheme == .emerald)
        #expect(LearnNowThemeStore.current == .emerald)
    }

    @Test
    func themeCatalogProvidesDistinctBrandForegroundsForAllThemes() {
        let brands = LearnNowTheme.allCases.map {
            LearnNowThemeCatalog.tokens(for: $0).brand.foreground.light
        }
        #expect(Set(brands).count == LearnNowTheme.allCases.count)
        #expect(LearnNowThemeCatalog.tokens(for: .emerald).brand.foreground.light == 0x0B7A5C)
    }

    @Test
    func themeDisplayNamesAreExactlyFourChineseCharacters() {
        let expected: [LearnNowTheme: String] = [
            .emerald: "清水翡翠",
            .sand: "暖沙米白",
            .ink: "墨青素笺",
            .graphite: "石墨素灰",
            .clay: "柔陶暖灰",
        ]
        for theme in LearnNowTheme.allCases {
            #expect(theme.displayName == expected[theme])
            #expect(theme.displayName.count == 4)
        }
    }

    @Test
    func cloudSyncPreferenceDefaultsOffAndPersistsExplicitChoice() throws {
        let suiteName = "LearnNowDataTests.cloudSync.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        #expect(!LearnNowCloudSyncPreference.isEnabled(in: defaults))

        LearnNowCloudSyncPreference.setEnabled(false, in: defaults)
        #expect(!LearnNowCloudSyncPreference.isEnabled(in: defaults))

        LearnNowCloudSyncPreference.setEnabled(true, in: defaults)
        #expect(LearnNowCloudSyncPreference.isEnabled(in: defaults))
    }

    @Test
    func cloudSyncEffectiveEnabledRequiresPreferenceAndEntitlement() {
        #expect(!LearnNowCloudSyncPreference.effectiveEnabled(preference: false, entitled: false))
        #expect(!LearnNowCloudSyncPreference.effectiveEnabled(preference: true, entitled: false))
        #expect(!LearnNowCloudSyncPreference.effectiveEnabled(preference: false, entitled: true))
        #expect(LearnNowCloudSyncPreference.effectiveEnabled(preference: true, entitled: true))
    }

    @Test
    func profilePreferenceDefaultsThenSurvivesRepositoryReload() async throws {
        let catalog = try CatalogDecoder.decode(data: catalogData())
        let container = try LearnNowModelContainerFactory.make(cloudSyncEnabled: false, inMemory: true)
        let context = ModelContext(container)
        let repository = SwiftDataLearningRepository(
            context: context,
            clock: fixedClock(),
            syncAvailabilityOverride: .localOnly
        )

        let initial = try await repository.loadSnapshot(catalog: catalog)
        #expect(initial.profilePreference == ProfilePreference())
        #expect(initial.profilePreference.displayName == "学习者")
        #expect(initial.profilePreference.avatarID == "fox")

        try repository.saveProfilePreference(
            ProfilePreference(displayName: "小林", avatarID: "otter")
        )

        let reloadedRepository = SwiftDataLearningRepository(
            context: context,
            clock: fixedClock(),
            syncAvailabilityOverride: .localOnly
        )
        let reloaded = try await reloadedRepository.loadSnapshot(catalog: catalog)
        #expect(reloaded.profilePreference.displayName == "小林")
        #expect(reloaded.profilePreference.avatarID == "otter")
    }

    @Test
    func duplicateProfilePreferencesUseTimestampThenStableIDAndAreCleanedUp() async throws {
        let catalog = try CatalogDecoder.decode(data: catalogData())
        let container = try LearnNowModelContainerFactory.make(cloudSyncEnabled: false, inMemory: true)
        let context = ModelContext(container)
        let now = fixedClock().now
        context.insert(
            ProfilePreferenceRecord(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                displayName: "旧资料",
                avatarID: "cat",
                updatedAt: now.addingTimeInterval(-60)
            )
        )
        context.insert(
            ProfilePreferenceRecord(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                displayName: "同时间较小 ID",
                avatarID: "rabbit",
                updatedAt: now
            )
        )
        context.insert(
            ProfilePreferenceRecord(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                displayName: "最终资料",
                avatarID: "panda",
                updatedAt: now
            )
        )
        try context.save()

        let repository = SwiftDataLearningRepository(
            context: context,
            clock: fixedClock(),
            syncAvailabilityOverride: .localOnly
        )
        let snapshot = try await repository.loadSnapshot(catalog: catalog)
        let remaining = try context.fetch(FetchDescriptor<ProfilePreferenceRecord>())
            .filter { $0.profileID == ProfilePreference.stableID }

        #expect(snapshot.profilePreference.displayName == "最终资料")
        #expect(snapshot.profilePreference.avatarID == "panda")
        #expect(remaining.count == 1)
        #expect(remaining.first?.id == UUID(uuidString: "00000000-0000-0000-0000-000000000003"))
    }

    @Test
    func disabledCloudSyncHasExplicitAvailability() async throws {
        let catalog = try CatalogDecoder.decode(data: catalogData())
        let container = try LearnNowModelContainerFactory.make(cloudSyncEnabled: false, inMemory: true)
        let repository = SwiftDataLearningRepository(
            context: ModelContext(container),
            clock: fixedClock(),
            syncAvailabilityOverride: .available,
            cloudSyncEnabled: false
        )

        let snapshot = try await repository.loadSnapshot(catalog: catalog)
        #expect(snapshot.syncAvailability == .disabled)
        #expect(snapshot.syncAvailability.displayText == "同步已关闭")
    }

    @Test
    func cloudSyncChoiceChangesKeepTheSameLocalCloudSyncStore() async throws {
        let suiteName = "LearnNowDataTests.cloudSyncContinuity.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("LearnNowCloudSync-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appendingPathComponent("CloudSync.store")
        let catalog = try CatalogDecoder.decode(data: catalogData())

        func makeLocalCloudSyncContainer() throws -> ModelContainer {
            let schema = Schema(versionedSchema: LearnNowSchemaV2.self)
            let configuration = ModelConfiguration(
                "CloudSync",
                schema: schema,
                url: storeURL,
                cloudKitDatabase: .none
            )
            return try ModelContainer(
                for: schema,
                migrationPlan: LearnNowMigrationPlan.self,
                configurations: [configuration]
            )
        }

        LearnNowCloudSyncPreference.setEnabled(true, in: defaults)
        do {
            let container = try makeLocalCloudSyncContainer()
            let repository = SwiftDataLearningRepository(
                context: ModelContext(container),
                clock: fixedClock(),
                cloudSyncEnabled: true
            )
            try repository.saveProfilePreference(
                ProfilePreference(displayName: "云朵", avatarID: "seal")
            )
        }

        LearnNowCloudSyncPreference.setEnabled(false, in: defaults)
        do {
            let container = try makeLocalCloudSyncContainer()
            let repository = SwiftDataLearningRepository(
                context: ModelContext(container),
                clock: fixedClock(),
                cloudSyncEnabled: LearnNowCloudSyncPreference.isEnabled(in: defaults)
            )
            let snapshot = try await repository.loadSnapshot(catalog: catalog)
            #expect(snapshot.profilePreference == ProfilePreference(displayName: "云朵", avatarID: "seal"))
            #expect(snapshot.syncAvailability == .disabled)
        }

        LearnNowCloudSyncPreference.setEnabled(true, in: defaults)
        do {
            let container = try makeLocalCloudSyncContainer()
            let repository = SwiftDataLearningRepository(
                context: ModelContext(container),
                clock: fixedClock(),
                syncAvailabilityOverride: .available,
                cloudSyncEnabled: LearnNowCloudSyncPreference.isEnabled(in: defaults)
            )
            let snapshot = try await repository.loadSnapshot(catalog: catalog)
            #expect(snapshot.profilePreference == ProfilePreference(displayName: "云朵", avatarID: "seal"))
            #expect(snapshot.syncAvailability == .available)
        }
    }

    @Test
    func v1StoreLightweightMigratesToV2AndAddsProfilePreferenceModel() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("LearnNowMigration-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appendingPathComponent("Migration.store")

        do {
            let schema = Schema(versionedSchema: LearnNowSchemaV1.self)
            let configuration = ModelConfiguration(
                "Migration",
                schema: schema,
                url: storeURL,
                cloudKitDatabase: .none
            )
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            let context = ModelContext(container)
            context.insert(
                LessonProgressRecord(
                    lessonID: "first",
                    lastPageID: "first-page",
                    highestPageOrder: 0,
                    completedAt: fixedClock().now,
                    updatedAt: fixedClock().now
                )
            )
            try context.save()
        }

        let schema = Schema(versionedSchema: LearnNowSchemaV2.self)
        let configuration = ModelConfiguration(
            "Migration",
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )
        let container = try ModelContainer(
            for: schema,
            migrationPlan: LearnNowMigrationPlan.self,
            configurations: [configuration]
        )
        let context = ModelContext(container)
        #expect(try context.fetch(FetchDescriptor<LessonProgressRecord>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<ProfilePreferenceRecord>()).isEmpty)

        let repository = SwiftDataLearningRepository(
            context: context,
            clock: fixedClock(),
            syncAvailabilityOverride: .localOnly
        )
        let catalog = try CatalogDecoder.decode(data: catalogData())
        let snapshot = try await repository.loadSnapshot(catalog: catalog)
        #expect(snapshot.completedLessonIDs == ["first"])
        #expect(snapshot.profilePreference == ProfilePreference())
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

    private func bundledCatalog() throws -> CourseCatalog {
        let url = try #require(Bundle.main.url(forResource: "CatalogV2", withExtension: "json"))
        return try CatalogDecoder.decode(data: Data(contentsOf: url))
    }

    private func catalogData(
        mutation: CatalogMutation? = nil,
        reviewCardID: String = "card",
        retiredIDs: [String] = []
    ) -> Data {
        var version = 2
        var firstID = "first"
        var secondPrerequisites = ["first"]
        var firstPrerequisites: [String] = []
        var correctOptionID = "yes"
        var firstLessons = lessonJSON(
            id: "first-page",
            moduleID: "first",
            correctOptionID: correctOptionID
        )

        switch mutation {
        case .duplicateModuleID:
            firstID = "second"
        case .missingPrerequisite:
            secondPrerequisites = ["missing"]
        case .prerequisiteCycle:
            firstPrerequisites = ["second"]
        case .missingCorrectOption:
            correctOptionID = "missing"
            firstLessons = lessonJSON(
                id: "first-page",
                moduleID: "first",
                correctOptionID: correctOptionID
            )
        case .emptyPages:
            firstLessons = ""
        case .unsupportedVersion:
            version = 1
        case nil:
            break
        }

        let json = """
        {
          "schemaVersion": \(version),
          "releaseVersion": "1.0.0",
          "locale": "zh-Hans",
          "primaryRouteID": "route",
          "tracks": [
            {"id": "statistics", "title": "Statistics"},
            {"id": "machineLearning", "title": "Machine Learning"}
          ],
          "routes": [{
            "id": "route", "title": "Route", "subtitle": "Subtitle", "systemImage": "cpu",
            "accent": "blue", "cta": "继续学习", "interactive": true,
            "trackIDs": ["statistics", "machineLearning"], "moduleIDs": ["first", "second"]
          }],
          "modules": [
            {
              "id": "\(firstID)", "trackID": "statistics", "title": "First", "subtitle": "1",
              "lessonTitle": "First", "prerequisiteModuleIDs": \(jsonArray(firstPrerequisites)),
              "completionXP": 15, "reviewMessage": "Review"
            },
            {
              "id": "second", "trackID": "machineLearning", "title": "Second", "subtitle": "1",
              "lessonTitle": "Second", "prerequisiteModuleIDs": \(jsonArray(secondPrerequisites)),
              "completionXP": 15, "reviewMessage": "Review"
            }
          ],
          "lessons": [
            \(firstLessons)
            \(firstLessons.isEmpty ? "" : ",")
            \(lessonJSON(id: "second-page", moduleID: "second", correctOptionID: "yes"))
          ],
          "exercises": [
            \(exerciseJSON(id: "first-page.quiz", lessonID: "first-page", correctOptionID: correctOptionID)),
            \(exerciseJSON(
                id: "second-page.quiz",
                lessonID: "second-page",
                correctOptionID: "second-page.yes",
                optionNamespace: "second-page"
            ))
          ],
          "reviewCards": [{
            "id": "\(reviewCardID)", "moduleID": "first", "sourceLessonID": "first-page",
            "revision": 1, "locale": "zh-Hans", "topic": "Topic", "accent": "mint",
            "frontTitle": "Front", "frontSubtitle": null, "backTitle": "Back",
            "backBody": [\(inlineJSON("Body"))], "backHighlight": [\(inlineJSON("Highlight"))]
          }],
          "knowledgeTips": [{
            "id": "tip", "moduleID": null, "sourceLessonID": null, "revision": 1,
            "locale": "zh-Hans", "title": "Tip", "body": [\(inlineJSON("Body"))],
            "systemImage": "lightbulb", "accent": "amber"
          }],
          "retiredIDs": \(jsonArray(retiredIDs))
        }
        """
        return Data(json.utf8)
    }

    private func lessonJSON(id: String, moduleID: String, correctOptionID: String) -> String {
        """
        {
          "id": "\(id)", "moduleID": "\(moduleID)", "order": 1, "title": "Page",
          "accent": "blue", "revision": 1, "locale": "zh-Hans", "objectives": ["objective"],
          "blocks": [
            {"type": "paragraph", "content": [\(inlineJSON("Summary"))]},
            {"type": "singleChoice", "exerciseID": "\(id).quiz"}
          ]
        }
        """
    }

    private func exerciseJSON(
        id: String,
        lessonID: String,
        correctOptionID: String,
        optionNamespace: String? = nil
    ) -> String {
        let correctFeedback = feedbackJSON(title: "Correct", body: "Correct body", accent: "mint")
        let incorrectFeedback = feedbackJSON(title: "Retry", body: "Retry body", accent: "pink")
        let yesID = optionNamespace.map { "\($0).yes" } ?? "yes"
        let noID = optionNamespace.map { "\($0).no" } ?? "no"
        return """
        {
          "id": "\(id)", "lessonID": "\(lessonID)", "kind": "singleChoice",
          "prompt": [\(inlineJSON("Question"))],
          "options": [
            {"id": "\(yesID)", "content": [\(inlineJSON("Yes"))], "feedback": null},
            {"id": "\(noID)", "content": [\(inlineJSON("No"))], "feedback": null}
          ],
          "correctOptionID": "\(correctOptionID)",
          "correctFeedback": \(correctFeedback),
          "incorrectFeedback": \(incorrectFeedback)
        }
        """
    }

    private func feedbackJSON(title: String, body: String, accent: String) -> String {
        """
        {
          "title": "\(title)", "body": [\(inlineJSON(body))],
          "tone": "information", "accent": "\(accent)"
        }
        """
    }

    private func inlineJSON(_ text: String) -> String {
        #"{"type":"text","text":"\#(text)"}"#
    }

    private func jsonArray(_ values: [String]) -> String {
        "[" + values.map { "\"\($0)\"" }.joined(separator: ",") + "]"
    }

}
