import Foundation
import SwiftData

enum LearnNowCloudKitSchemaInitializer {
    static let launchArgument = "-InitializeCloudKitSchema"

    @MainActor
    static func runIfRequested(context: ModelContext, now: Date = Date()) throws {
#if DEBUG
        guard ProcessInfo.processInfo.arguments.contains(launchArgument) else { return }

        let marker = "schema-initialization:v1"
        if try context.fetch(FetchDescriptor<LessonProgressRecord>())
            .contains(where: { $0.lessonID == marker }) {
            return
        }

        context.insert(
            LessonProgressRecord(
                lessonID: marker,
                lastPageID: nil,
                highestPageOrder: 0,
                completedAt: nil,
                updatedAt: now
            )
        )
        context.insert(
            LearningEventRecord(
                eventKey: marker,
                kindRawValue: "schemaInitialization",
                contentID: marker,
                occurredAt: now,
                localDay: "",
                timeZoneID: TimeZone.current.identifier,
                xpDelta: 0
            )
        )
        context.insert(
            ReviewLogRecord(
                cardID: marker,
                ratingRawValue: LearnNowReviewRating.good.rawValue,
                reviewedAt: now,
                localDay: "",
                timeZoneID: TimeZone.current.identifier,
                schedulerVersion: FSRSReviewScheduler.schedulerVersion,
                parametersVersion: FSRSReviewScheduler.parametersVersion,
                elapsedDays: 0,
                scheduledDays: 0,
                dueAt: now,
                stability: 0,
                difficulty: 0,
                stateRawValue: 0,
                learningSteps: 0,
                reps: 0,
                lapses: 0
            )
        )
        context.insert(
            CardPreferenceRecord(
                cardID: marker,
                isFavorited: false,
                isMastered: false,
                updatedAt: now
            )
        )
        context.insert(
            ReviewScheduleCacheRecord(
                cardID: marker,
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
                lastAppliedLogID: nil,
                rebuiltAt: now
            )
        )
        try context.save()
#endif
    }
}
