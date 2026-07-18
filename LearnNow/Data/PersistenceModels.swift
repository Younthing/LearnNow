import Foundation
import SwiftData

@Model
final class LessonProgressRecord {
    var id: UUID = UUID()
    var lessonID: String = ""
    var lastPageID: String?
    var highestPageOrder: Int = 0
    var completedAt: Date?
    var updatedAt: Date = Date.distantPast

    init(
        id: UUID = UUID(),
        lessonID: String,
        lastPageID: String?,
        highestPageOrder: Int,
        completedAt: Date? = nil,
        updatedAt: Date
    ) {
        self.id = id
        self.lessonID = lessonID
        self.lastPageID = lastPageID
        self.highestPageOrder = highestPageOrder
        self.completedAt = completedAt
        self.updatedAt = updatedAt
    }
}

@Model
final class LearningEventRecord {
    var id: UUID = UUID()
    var eventKey: String = ""
    var kindRawValue: String = ""
    var contentID: String = ""
    var occurredAt: Date = Date.distantPast
    var localDay: String = ""
    var timeZoneID: String = "UTC"
    var xpDelta: Int = 0

    init(
        id: UUID = UUID(),
        eventKey: String,
        kindRawValue: String,
        contentID: String,
        occurredAt: Date,
        localDay: String,
        timeZoneID: String,
        xpDelta: Int
    ) {
        self.id = id
        self.eventKey = eventKey
        self.kindRawValue = kindRawValue
        self.contentID = contentID
        self.occurredAt = occurredAt
        self.localDay = localDay
        self.timeZoneID = timeZoneID
        self.xpDelta = xpDelta
    }
}

@Model
final class ReviewLogRecord {
    var id: UUID = UUID()
    var cardID: String = ""
    var ratingRawValue: String = "good"
    var reviewedAt: Date = Date.distantPast
    var localDay: String = ""
    var timeZoneID: String = "UTC"
    var schedulerVersion: String = "FSRS-6"
    var parametersVersion: String = "default-v6"
    var elapsedDays: Double = 0
    var scheduledDays: Double = 0
    var dueAt: Date = Date.distantPast
    var stability: Double = 0
    var difficulty: Double = 0
    var stateRawValue: Int = 0
    var learningSteps: Int = 0
    var reps: Int = 0
    var lapses: Int = 0

    init(
        id: UUID = UUID(),
        cardID: String,
        ratingRawValue: String,
        reviewedAt: Date,
        localDay: String,
        timeZoneID: String,
        schedulerVersion: String,
        parametersVersion: String,
        elapsedDays: Double,
        scheduledDays: Double,
        dueAt: Date,
        stability: Double,
        difficulty: Double,
        stateRawValue: Int,
        learningSteps: Int,
        reps: Int,
        lapses: Int
    ) {
        self.id = id
        self.cardID = cardID
        self.ratingRawValue = ratingRawValue
        self.reviewedAt = reviewedAt
        self.localDay = localDay
        self.timeZoneID = timeZoneID
        self.schedulerVersion = schedulerVersion
        self.parametersVersion = parametersVersion
        self.elapsedDays = elapsedDays
        self.scheduledDays = scheduledDays
        self.dueAt = dueAt
        self.stability = stability
        self.difficulty = difficulty
        self.stateRawValue = stateRawValue
        self.learningSteps = learningSteps
        self.reps = reps
        self.lapses = lapses
    }
}

@Model
final class CardPreferenceRecord {
    var id: UUID = UUID()
    var cardID: String = ""
    var isFavorited: Bool = false
    var isMastered: Bool = false
    var updatedAt: Date = Date.distantPast

    init(
        id: UUID = UUID(),
        cardID: String,
        isFavorited: Bool,
        isMastered: Bool,
        updatedAt: Date
    ) {
        self.id = id
        self.cardID = cardID
        self.isFavorited = isFavorited
        self.isMastered = isMastered
        self.updatedAt = updatedAt
    }
}

@Model
final class ReviewScheduleCacheRecord {
    var id: UUID = UUID()
    var cardID: String = ""
    var dueAt: Date = Date.distantPast
    var lastReviewAt: Date?
    var stability: Double = 0
    var difficulty: Double = 0
    var elapsedDays: Double = 0
    var scheduledDays: Double = 0
    var stateRawValue: Int = 0
    var learningSteps: Int = 0
    var reps: Int = 0
    var lapses: Int = 0
    var lastAppliedLogID: UUID?
    var rebuiltAt: Date = Date.distantPast

    init(
        id: UUID = UUID(),
        cardID: String,
        dueAt: Date,
        lastReviewAt: Date?,
        stability: Double,
        difficulty: Double,
        elapsedDays: Double,
        scheduledDays: Double,
        stateRawValue: Int,
        learningSteps: Int,
        reps: Int,
        lapses: Int,
        lastAppliedLogID: UUID?,
        rebuiltAt: Date
    ) {
        self.id = id
        self.cardID = cardID
        self.dueAt = dueAt
        self.lastReviewAt = lastReviewAt
        self.stability = stability
        self.difficulty = difficulty
        self.elapsedDays = elapsedDays
        self.scheduledDays = scheduledDays
        self.stateRawValue = stateRawValue
        self.learningSteps = learningSteps
        self.reps = reps
        self.lapses = lapses
        self.lastAppliedLogID = lastAppliedLogID
        self.rebuiltAt = rebuiltAt
    }
}

enum LearnNowSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [
            LessonProgressRecord.self,
            LearningEventRecord.self,
            ReviewLogRecord.self,
            CardPreferenceRecord.self,
            ReviewScheduleCacheRecord.self,
        ]
    }
}

enum LearnNowMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [LearnNowSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}

enum LearnNowModelContainerFactory {
    static let cloudKitContainerIdentifier = "iCloud.fanxi.LearnNow"

    static func make(cloudSyncEnabled: Bool = true, inMemory: Bool = false) throws -> ModelContainer {
        let fullSchema = Schema(versionedSchema: LearnNowSchemaV1.self)
        let cloudSchema = Schema([
            LessonProgressRecord.self,
            LearningEventRecord.self,
            ReviewLogRecord.self,
            CardPreferenceRecord.self,
        ])
        let cacheSchema = Schema([ReviewScheduleCacheRecord.self])

        let cloudConfiguration = ModelConfiguration(
            "CloudSync",
            schema: cloudSchema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: cloudSyncEnabled && !inMemory
                ? .private(cloudKitContainerIdentifier)
                : .none
        )
        let cacheConfiguration = ModelConfiguration(
            "LocalCache",
            schema: cacheSchema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        )

        return try ModelContainer(
            for: fullSchema,
            migrationPlan: LearnNowMigrationPlan.self,
            configurations: [cloudConfiguration, cacheConfiguration]
        )
    }
}

enum LearnNowSyncAvailability: String, Equatable, Sendable {
    case available
    case localOnly
    case restricted
    case unknown

    var displayText: String {
        switch self {
        case .available: "iCloud 同步"
        case .localOnly: "仅本机"
        case .restricted: "iCloud 受限"
        case .unknown: "正在检查 iCloud"
        }
    }
}

struct ReviewMemorySnapshot: Equatable, Sendable {
    let cardID: String
    let dueAt: Date
    let lastReviewAt: Date?
    let stability: Double
    let difficulty: Double
    let elapsedDays: Double
    let scheduledDays: Double
    let stateRawValue: Int
    let learningSteps: Int
    let reps: Int
    let lapses: Int
    let retrievability: Double
    let isFavorited: Bool
    let isMastered: Bool
}

struct LearningSnapshot: Equatable, Sendable {
    var totalXP: Int = 0
    var streakDays: Int = 0
    var completedLessonIDs: Set<String> = []
    var lastVisitedLessonID: String?
    var lastVisitedPageID: String?
    var highestPageOrderByLessonID: [String: Int] = [:]
    var activityByLocalDay: [String: Int] = [:]
    var reviewMemoryByCardID: [String: ReviewMemorySnapshot] = [:]
    var syncAvailability: LearnNowSyncAvailability = .unknown

    static let empty = Self()
}

protocol LearnNowClock: Sendable {
    var now: Date { get }
    var calendar: Calendar { get }
    var timeZone: TimeZone { get }
}

struct SystemLearnNowClock: LearnNowClock {
    var now: Date { Date() }
    var calendar: Calendar { Calendar.current }
    var timeZone: TimeZone { TimeZone.current }
}

struct FixedLearnNowClock: LearnNowClock {
    let now: Date
    let calendar: Calendar
    let timeZone: TimeZone
}
