import CloudKit
import Foundation
import OSLog
import SwiftData

@MainActor
protocol LearningRepository: AnyObject {
    func loadSnapshot(catalog: CourseCatalog) async throws -> LearningSnapshot
    func recordPageVisit(lessonID: String, pageID: String, pageOrder: Int) throws
    func completeLesson(lessonID: String, xp: Int) throws -> Bool
    func setCardPreference(cardID: String, isFavorited: Bool, isMastered: Bool) throws
    func saveProfilePreference(_ preference: ProfilePreference) throws
    func recordReview(
        cardID: String,
        memory: ReviewMemorySnapshot?,
        rating: LearnNowReviewRating
    ) throws -> ReviewScheduleOutcome
}

@MainActor
final class SwiftDataLearningRepository: LearningRepository {
    private let context: ModelContext
    private let clock: any LearnNowClock
    private let scheduler: any ReviewScheduler
    private let syncAvailabilityOverride: LearnNowSyncAvailability?
    private let cloudSyncEnabled: Bool
    private let logger = Logger(subsystem: "fanxi.LearnNow", category: "LearningRepository")

    init(
        context: ModelContext,
        clock: (any LearnNowClock)? = nil,
        scheduler: (any ReviewScheduler)? = nil,
        syncAvailabilityOverride: LearnNowSyncAvailability? = nil,
        cloudSyncEnabled: Bool = true
    ) {
        self.context = context
        self.clock = clock ?? SystemLearnNowClock()
        self.scheduler = scheduler ?? FSRSReviewScheduler()
        self.syncAvailabilityOverride = syncAvailabilityOverride
        self.cloudSyncEnabled = cloudSyncEnabled
    }

    func loadSnapshot(catalog: CourseCatalog) async throws -> LearningSnapshot {
        let progressRecords = try context.fetch(FetchDescriptor<LessonProgressRecord>())
        let eventRecords = try context.fetch(FetchDescriptor<LearningEventRecord>())
        let logRecords = try context.fetch(FetchDescriptor<ReviewLogRecord>())
        let preferenceRecords = try context.fetch(FetchDescriptor<CardPreferenceRecord>())
        let profilePreferenceRecords = try context.fetch(FetchDescriptor<ProfilePreferenceRecord>())
        let cacheRecords = try context.fetch(FetchDescriptor<ReviewScheduleCacheRecord>())

        let mergedProgress = mergeProgress(progressRecords)
        let uniqueEvents = mergeEvents(eventRecords)
        let completedLessonIDs = Set(
            mergedProgress.values.compactMap { $0.completedAt == nil ? nil : $0.lessonID }
        )
        let knownLessonIDs = Set(catalog.modules.map(\.id))
        let lessonIDByPageID = Dictionary(
            uniqueKeysWithValues: catalog.modules.flatMap { module in
                module.lessonPages.map { ($0.id, module.id) }
            }
        )
        let knownCardIDs = Set(catalog.reviewCards.map(\.id))
        let latestKnownProgress = mergedProgress.values
            .filter { knownLessonIDs.contains($0.lessonID) }
            .max { lhs, rhs in lhs.updatedAt < rhs.updatedAt }
        for lessonID in Set(progressRecords.map(\.lessonID)).subtracting(knownLessonIDs) {
            logger.notice("Ignoring progress for unknown lesson ID: \(lessonID, privacy: .public)")
        }
        for cardID in Set(logRecords.map(\.cardID)).subtracting(knownCardIDs) {
            logger.notice("Retaining hidden review history for unknown card ID: \(cardID, privacy: .public)")
        }
        let activeCardIDs = Set(
            catalog.modules
                .filter { completedLessonIDs.contains($0.id) }
                .flatMap(\.reviewCardIDs)
        )

        let pageVisitEvents = uniqueEvents.filter { $0.kindRawValue == "pageVisit" }
        let lessonIDsWithPageVisitEvents = Set(catalog.modules.compactMap { module in
            let eventKeyPrefix = "page-visit:\(module.id):"
            return pageVisitEvents.contains { $0.eventKey.hasPrefix(eventKeyPrefix) }
                ? module.id
                : nil
        })
        var visitedPageIDsByLessonID: [String: Set<String>] = [:]
        for event in pageVisitEvents {
            guard let lessonID = lessonIDByPageID[event.contentID] else { continue }
            visitedPageIDsByLessonID[lessonID, default: []].insert(event.contentID)
        }

        // V1 stored only an order and the last page. Convert that legacy prefix once
        // into stable page IDs. Once any pageVisit event exists, future insertions or
        // reordering never reinterpret the old numeric order.
        for module in catalog.modules {
            guard !lessonIDsWithPageVisitEvents.contains(module.id),
                  let progress = mergedProgress[module.id],
                  !module.lessonPages.isEmpty
            else {
                continue
            }

            let upperBound = min(max(progress.highestPageOrder, 0), module.lessonPages.count - 1)
            let migratedPageIDs = Set(module.lessonPages[0 ... upperBound].map(\.id))
                .union(progress.lastPageID.flatMap { lessonIDByPageID[$0] == module.id ? [$0] : nil } ?? [])
            visitedPageIDsByLessonID[module.id] = migratedPageIDs

            for pageID in migratedPageIDs {
                context.insert(
                    LearningEventRecord(
                        eventKey: pageVisitEventKey(lessonID: module.id, pageID: pageID),
                        kindRawValue: "pageVisit",
                        contentID: pageID,
                        occurredAt: progress.updatedAt,
                        localDay: "",
                        timeZoneID: clock.timeZone.identifier,
                        xpDelta: 0
                    )
                )
            }
        }

        let logsByCard = Dictionary(
            grouping: logRecords.filter { knownCardIDs.contains($0.cardID) },
            by: \.cardID
        )
        let preferencesByCard = mergePreferences(preferenceRecords)
        let profilePreferenceRecord = mergeProfilePreferences(profilePreferenceRecords)
        let cacheByCard = Dictionary(grouping: cacheRecords, by: \.cardID)

        var reviewMemoryByCardID: [String: ReviewMemorySnapshot] = [:]
        for cardID in activeCardIDs {
            let latestLog = logsByCard[cardID]?.max(by: reviewLogOrder)
            let preference = preferencesByCard[cardID]
            let baseMemory = latestLog.map {
                ReviewMemorySnapshot(
                    cardID: cardID,
                    dueAt: $0.dueAt,
                    lastReviewAt: $0.reviewedAt,
                    stability: $0.stability,
                    difficulty: $0.difficulty,
                    elapsedDays: $0.elapsedDays,
                    scheduledDays: $0.scheduledDays,
                    stateRawValue: $0.stateRawValue,
                    learningSteps: $0.learningSteps,
                    reps: $0.reps,
                    lapses: $0.lapses,
                    retrievability: 0,
                    isFavorited: preference?.isFavorited ?? false,
                    isMastered: preference?.isMastered ?? false
                )
            }

            let memory = ReviewMemorySnapshot(
                cardID: cardID,
                dueAt: baseMemory?.dueAt ?? clock.now,
                lastReviewAt: baseMemory?.lastReviewAt,
                stability: baseMemory?.stability ?? 0,
                difficulty: baseMemory?.difficulty ?? 0,
                elapsedDays: baseMemory?.elapsedDays ?? 0,
                scheduledDays: baseMemory?.scheduledDays ?? 0,
                stateRawValue: baseMemory?.stateRawValue ?? 0,
                learningSteps: baseMemory?.learningSteps ?? 0,
                reps: baseMemory?.reps ?? 0,
                lapses: baseMemory?.lapses ?? 0,
                retrievability: scheduler.retrievability(for: baseMemory, now: clock.now),
                isFavorited: preference?.isFavorited ?? false,
                isMastered: preference?.isMastered ?? false
            )
            reviewMemoryByCardID[cardID] = memory
            updateCache(
                existing: cacheByCard[cardID]?.max(by: { $0.rebuiltAt < $1.rebuiltAt }),
                memory: memory,
                lastLogID: latestLog?.id
            )
        }

        if context.hasChanges {
            try context.save()
        }

        let activityDays = uniqueEvents.map(\.localDay) + logRecords.map(\.localDay)
        let activityByDay = Dictionary(grouping: activityDays.filter { !$0.isEmpty }, by: { $0 })
            .mapValues(\.count)

        return LearningSnapshot(
            totalXP: uniqueEvents.reduce(0) { $0 + $1.xpDelta },
            streakDays: streakDays(from: Set(activityDays)),
            completedLessonIDs: completedLessonIDs.intersection(knownLessonIDs),
            lastVisitedLessonID: latestKnownProgress?.lessonID,
            lastVisitedPageID: latestKnownProgress?.lastPageID,
            highestPageOrderByLessonID: mergedProgress
                .filter { knownLessonIDs.contains($0.key) }
                .mapValues(\.highestPageOrder),
            visitedPageIDsByLessonID: visitedPageIDsByLessonID,
            activityByLocalDay: activityByDay,
            reviewMemoryByCardID: reviewMemoryByCardID,
            profilePreference: profilePreferenceRecord.map {
                ProfilePreference(displayName: $0.displayName, avatarID: $0.avatarID)
            } ?? ProfilePreference(),
            syncAvailability: await syncAvailability()
        )
    }

    func recordPageVisit(lessonID: String, pageID: String, pageOrder: Int) throws {
        let records = try context.fetch(FetchDescriptor<LessonProgressRecord>())
            .filter { $0.lessonID == lessonID }
        let record = records.max(by: { $0.updatedAt < $1.updatedAt })
            ?? LessonProgressRecord(
                lessonID: lessonID,
                lastPageID: nil,
                highestPageOrder: 0,
                updatedAt: clock.now
            )
        if record.modelContext == nil {
            context.insert(record)
        }
        record.lastPageID = pageID
        record.highestPageOrder = max(record.highestPageOrder, pageOrder)
        record.updatedAt = clock.now

        let eventKey = pageVisitEventKey(lessonID: lessonID, pageID: pageID)
        let existingKeys = Set(
            try context.fetch(FetchDescriptor<LearningEventRecord>()).map(\.eventKey)
        )
        if !existingKeys.contains(eventKey) {
            context.insert(
                LearningEventRecord(
                    eventKey: eventKey,
                    kindRawValue: "pageVisit",
                    contentID: pageID,
                    occurredAt: clock.now,
                    localDay: localDay(for: clock.now),
                    timeZoneID: clock.timeZone.identifier,
                    xpDelta: 0
                )
            )
        }
        try context.save()
    }

    @discardableResult
    func completeLesson(lessonID: String, xp: Int) throws -> Bool {
        let progressRecords = try context.fetch(FetchDescriptor<LessonProgressRecord>())
            .filter { $0.lessonID == lessonID }
        let record = progressRecords.max(by: { $0.updatedAt < $1.updatedAt })
            ?? LessonProgressRecord(
                lessonID: lessonID,
                lastPageID: nil,
                highestPageOrder: 0,
                updatedAt: clock.now
            )
        if record.modelContext == nil {
            context.insert(record)
        }
        record.completedAt = record.completedAt ?? clock.now
        record.updatedAt = clock.now

        let eventKey = "lesson-completion:\(lessonID)"
        let existingKeys = Set(
            try context.fetch(FetchDescriptor<LearningEventRecord>()).map(\.eventKey)
        )
        let awarded = !existingKeys.contains(eventKey)
        if awarded {
            context.insert(
                LearningEventRecord(
                    eventKey: eventKey,
                    kindRawValue: "lessonCompletion",
                    contentID: lessonID,
                    occurredAt: clock.now,
                    localDay: localDay(for: clock.now),
                    timeZoneID: clock.timeZone.identifier,
                    xpDelta: xp
                )
            )
        }
        try context.save()
        return awarded
    }

    func setCardPreference(cardID: String, isFavorited: Bool, isMastered: Bool) throws {
        let records = try context.fetch(FetchDescriptor<CardPreferenceRecord>())
            .filter { $0.cardID == cardID }
        let record = records.max(by: { $0.updatedAt < $1.updatedAt })
            ?? CardPreferenceRecord(
                cardID: cardID,
                isFavorited: false,
                isMastered: false,
                updatedAt: clock.now
            )
        if record.modelContext == nil {
            context.insert(record)
        }
        record.isFavorited = isFavorited
        record.isMastered = isMastered
        record.updatedAt = clock.now
        try context.save()
    }

    func saveProfilePreference(_ preference: ProfilePreference) throws {
        let records = try context.fetch(FetchDescriptor<ProfilePreferenceRecord>())
        let existing = mergeProfilePreferences(records)
        let record = existing ?? ProfilePreferenceRecord(
            displayName: ProfilePreference.defaultDisplayName,
            avatarID: ProfilePreference.defaultAvatarID,
            updatedAt: clock.now
        )
        if existing == nil {
            context.insert(record)
        }
        record.displayName = preference.displayName
        record.avatarID = preference.avatarID
        record.updatedAt = clock.now
        try context.save()
    }

    func recordReview(
        cardID: String,
        memory: ReviewMemorySnapshot?,
        rating: LearnNowReviewRating
    ) throws -> ReviewScheduleOutcome {
        let outcome = try scheduler.schedule(
            cardID: cardID,
            memory: memory,
            rating: rating,
            now: clock.now
        )
        let state = outcome.memory
        let log = ReviewLogRecord(
            cardID: cardID,
            ratingRawValue: rating.rawValue,
            reviewedAt: clock.now,
            localDay: localDay(for: clock.now),
            timeZoneID: clock.timeZone.identifier,
            schedulerVersion: FSRSReviewScheduler.schedulerVersion,
            parametersVersion: FSRSReviewScheduler.parametersVersion,
            elapsedDays: state.elapsedDays,
            scheduledDays: state.scheduledDays,
            dueAt: state.dueAt,
            stability: state.stability,
            difficulty: state.difficulty,
            stateRawValue: state.stateRawValue,
            learningSteps: state.learningSteps,
            reps: state.reps,
            lapses: state.lapses
        )
        context.insert(log)
        let caches = try context.fetch(FetchDescriptor<ReviewScheduleCacheRecord>())
            .filter { $0.cardID == cardID }
        updateCache(
            existing: caches.max(by: { $0.rebuiltAt < $1.rebuiltAt }),
            memory: state,
            lastLogID: log.id
        )
        try context.save()
        return outcome
    }

    private func mergeProgress(_ records: [LessonProgressRecord]) -> [String: LessonProgressRecord] {
        Dictionary(grouping: records, by: \.lessonID).compactMapValues { candidates in
            guard let latest = candidates.max(by: { $0.updatedAt < $1.updatedAt }) else { return nil }
            let furthest = candidates.max {
                if $0.highestPageOrder == $1.highestPageOrder {
                    return $0.updatedAt < $1.updatedAt
                }
                return $0.highestPageOrder < $1.highestPageOrder
            }
            latest.highestPageOrder = furthest?.highestPageOrder ?? latest.highestPageOrder
            latest.completedAt = candidates.compactMap(\.completedAt).min()
            return latest
        }
    }

    private func pageVisitEventKey(lessonID: String, pageID: String) -> String {
        "page-visit:\(lessonID):\(pageID)"
    }

    private func mergeEvents(_ records: [LearningEventRecord]) -> [LearningEventRecord] {
        Dictionary(grouping: records, by: \.eventKey).compactMap { _, candidates in
            candidates.min {
                if $0.occurredAt == $1.occurredAt { return $0.id.uuidString < $1.id.uuidString }
                return $0.occurredAt < $1.occurredAt
            }
        }
    }

    private func mergePreferences(_ records: [CardPreferenceRecord]) -> [String: CardPreferenceRecord] {
        Dictionary(grouping: records, by: \.cardID).compactMapValues { candidates in
            candidates.max {
                if $0.updatedAt == $1.updatedAt { return $0.id.uuidString < $1.id.uuidString }
                return $0.updatedAt < $1.updatedAt
            }
        }
    }

    private func mergeProfilePreferences(
        _ records: [ProfilePreferenceRecord]
    ) -> ProfilePreferenceRecord? {
        let candidates = records.filter { $0.profileID == ProfilePreference.stableID }
        guard let winner = candidates.max(by: profilePreferenceOrder) else { return nil }
        for candidate in candidates where candidate !== winner {
            context.delete(candidate)
        }
        return winner
    }

    private func updateCache(
        existing: ReviewScheduleCacheRecord?,
        memory: ReviewMemorySnapshot,
        lastLogID: UUID?
    ) {
        let cache = existing ?? ReviewScheduleCacheRecord(
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
            lastAppliedLogID: lastLogID,
            rebuiltAt: clock.now
        )
        if existing == nil { context.insert(cache) }
        cache.dueAt = memory.dueAt
        cache.lastReviewAt = memory.lastReviewAt
        cache.stability = memory.stability
        cache.difficulty = memory.difficulty
        cache.elapsedDays = memory.elapsedDays
        cache.scheduledDays = memory.scheduledDays
        cache.stateRawValue = memory.stateRawValue
        cache.learningSteps = memory.learningSteps
        cache.reps = memory.reps
        cache.lapses = memory.lapses
        cache.lastAppliedLogID = lastLogID
        cache.rebuiltAt = clock.now
    }

    private func streakDays(from activeDays: Set<String>) -> Int {
        let today = clock.calendar.startOfDay(for: clock.now)
        let todayKey = localDay(for: today)
        let yesterday = clock.calendar.date(byAdding: .day, value: -1, to: today) ?? today
        var cursor = activeDays.contains(todayKey) ? today : yesterday
        var streak = 0

        while activeDays.contains(localDay(for: cursor)) {
            streak += 1
            guard let previous = clock.calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    private func localDay(for date: Date) -> String {
        var calendar = clock.calendar
        calendar.timeZone = clock.timeZone
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }

    private func syncAvailability() async -> LearnNowSyncAvailability {
        guard cloudSyncEnabled else { return .disabled }
        if let syncAvailabilityOverride { return syncAvailabilityOverride }
        let processInfo = ProcessInfo.processInfo
        if processInfo.environment["LEARNNOW_TESTING"] == "YES" ||
            processInfo.arguments.contains("-UITestingResetData") {
            return .localOnly
        }
        do {
            switch try await CKContainer(
                identifier: LearnNowModelContainerFactory.cloudKitContainerIdentifier
            ).accountStatus() {
            case .available: return .available
            case .restricted: return .restricted
            case .noAccount, .temporarilyUnavailable, .couldNotDetermine: return .localOnly
            @unknown default: return .unknown
            }
        } catch {
            return .localOnly
        }
    }

    private var reviewLogOrder: (ReviewLogRecord, ReviewLogRecord) -> Bool {
        { lhs, rhs in
            if lhs.reviewedAt == rhs.reviewedAt {
                return lhs.id.uuidString < rhs.id.uuidString
            }
            return lhs.reviewedAt < rhs.reviewedAt
        }
    }

    private var profilePreferenceOrder: (ProfilePreferenceRecord, ProfilePreferenceRecord) -> Bool {
        { lhs, rhs in
            if lhs.updatedAt == rhs.updatedAt {
                return lhs.id.uuidString < rhs.id.uuidString
            }
            return lhs.updatedAt < rhs.updatedAt
        }
    }
}
