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
final class ProfilePreferenceRecord {
    var id: UUID = UUID()
    var profileID: String = ProfilePreference.stableID
    var displayName: String = ProfilePreference.defaultDisplayName
    var avatarID: String = ProfilePreference.defaultAvatarID
    var updatedAt: Date = Date.distantPast

    init(
        id: UUID = UUID(),
        profileID: String = ProfilePreference.stableID,
        displayName: String,
        avatarID: String,
        updatedAt: Date
    ) {
        self.id = id
        self.profileID = profileID
        self.displayName = displayName
        self.avatarID = avatarID
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

enum LearnNowSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [
            LessonProgressRecord.self,
            LearningEventRecord.self,
            ReviewLogRecord.self,
            CardPreferenceRecord.self,
            ProfilePreferenceRecord.self,
            ReviewScheduleCacheRecord.self,
        ]
    }
}

enum LearnNowMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [LearnNowSchemaV1.self, LearnNowSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(
                fromVersion: LearnNowSchemaV1.self,
                toVersion: LearnNowSchemaV2.self
            ),
        ]
    }
}

enum LearnNowModelContainerFactory {
    static let cloudKitContainerIdentifier = "iCloud.fanxi.LearnNow"

    static func make(cloudSyncEnabled: Bool = true, inMemory: Bool = false) throws -> ModelContainer {
        let fullSchema = Schema(versionedSchema: LearnNowSchemaV2.self)
        let cloudSchema = Schema([
            LessonProgressRecord.self,
            LearningEventRecord.self,
            ReviewLogRecord.self,
            CardPreferenceRecord.self,
            ProfilePreferenceRecord.self,
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
    case disabled
    case localOnly
    case restricted
    case unknown

    var displayText: String {
        switch self {
        case .available: "iCloud 同步"
        case .disabled: "同步已关闭"
        case .localOnly: "仅本机"
        case .restricted: "iCloud 受限"
        case .unknown: "正在检查 iCloud"
        }
    }
}

enum LearnNowCloudSyncPreference {
    static let userDefaultsKey = "learnnow.settings.cloudSyncEnabled"

    static func isEnabled(in defaults: UserDefaults = .standard) -> Bool {
        guard defaults.object(forKey: userDefaultsKey) != nil else { return false }
        return defaults.bool(forKey: userDefaultsKey)
    }

    static func setEnabled(_ enabled: Bool, in defaults: UserDefaults = .standard) {
        defaults.set(enabled, forKey: userDefaultsKey)
    }

    /// CloudKit container is only active when the user both prefers sync and holds entitlement.
    static func effectiveEnabled(preference: Bool, entitled: Bool) -> Bool {
        preference && entitled
    }
}

struct ProfilePreference: Equatable, Sendable {
    static let stableID = "primary-profile"
    static let defaultDisplayName = "HI"
    static let defaultAvatarID = "fox"

    var displayName: String
    var avatarID: String

    init(
        displayName: String = Self.defaultDisplayName,
        avatarID: String = Self.defaultAvatarID
    ) {
        self.displayName = displayName
        self.avatarID = avatarID
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
    var visitedPageIDsByLessonID: [String: Set<String>] = [:]
    var activityByLocalDay: [String: Int] = [:]
    var reviewMemoryByCardID: [String: ReviewMemorySnapshot] = [:]
    var profilePreference: ProfilePreference = ProfilePreference()
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
