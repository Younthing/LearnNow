import Foundation
import LearnNowContentKit

public struct ContentDiffViolation: Codable, Equatable, Sendable {
    public let code: String
    public let message: String

    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

public struct ContentDiffReport: Codable, Equatable, Sendable {
    public let oldReleaseVersion: String
    public let newReleaseVersion: String
    public let contentPayloadChanged: Bool
    public let packagePayloadChanged: Bool?
    public let addedRoutes: [String]
    public let removedRoutes: [String]
    public let addedModules: [String]
    public let removedModules: [String]
    public let addedLessons: [String]
    public let removedLessons: [String]
    public let addedExercises: [String]
    public let removedExercises: [String]
    public let addedReviewCards: [String]
    public let removedReviewCards: [String]
    public let addedKnowledgeTips: [String]
    public let removedKnowledgeTips: [String]
    public let reorderedModules: [String]
    public let reorderedLessons: [String]
    public let changedCorrectAnswers: [String]
    public let changedLearningContent: [String]
    public let riskNotes: [String]
    public let strictViolations: [ContentDiffViolation]

    public var hasChanges: Bool {
        oldReleaseVersion != newReleaseVersion
            || contentPayloadChanged
            || packagePayloadChanged == true
    }

    public var passesStrictReleaseChecks: Bool {
        strictViolations.isEmpty
    }

    public init(
        oldReleaseVersion: String,
        newReleaseVersion: String,
        contentPayloadChanged: Bool,
        addedRoutes: [String],
        removedRoutes: [String],
        addedModules: [String],
        removedModules: [String],
        addedLessons: [String],
        removedLessons: [String],
        addedExercises: [String],
        removedExercises: [String],
        addedReviewCards: [String],
        removedReviewCards: [String],
        addedKnowledgeTips: [String],
        removedKnowledgeTips: [String],
        reorderedModules: [String],
        reorderedLessons: [String],
        changedCorrectAnswers: [String],
        changedLearningContent: [String],
        riskNotes: [String],
        strictViolations: [ContentDiffViolation],
        packagePayloadChanged: Bool? = nil
    ) {
        self.oldReleaseVersion = oldReleaseVersion
        self.newReleaseVersion = newReleaseVersion
        self.contentPayloadChanged = contentPayloadChanged
        self.packagePayloadChanged = packagePayloadChanged
        self.addedRoutes = addedRoutes
        self.removedRoutes = removedRoutes
        self.addedModules = addedModules
        self.removedModules = removedModules
        self.addedLessons = addedLessons
        self.removedLessons = removedLessons
        self.addedExercises = addedExercises
        self.removedExercises = removedExercises
        self.addedReviewCards = addedReviewCards
        self.removedReviewCards = removedReviewCards
        self.addedKnowledgeTips = addedKnowledgeTips
        self.removedKnowledgeTips = removedKnowledgeTips
        self.reorderedModules = reorderedModules
        self.reorderedLessons = reorderedLessons
        self.changedCorrectAnswers = changedCorrectAnswers
        self.changedLearningContent = changedLearningContent
        self.riskNotes = riskNotes
        self.strictViolations = strictViolations
    }
}

public enum ContentDiffer {
    public static func diff(
        old: CatalogDocumentV2,
        new: CatalogDocumentV2,
        oldManifest: ContentManifestV1? = nil,
        newManifest: ContentManifestV1? = nil
    ) -> ContentDiffReport {
        let routeChanges = idChanges(old.routes, new.routes)
        let moduleChanges = idChanges(old.modules, new.modules)
        let lessonChanges = idChanges(old.lessons, new.lessons)
        let exerciseChanges = idChanges(old.exercises, new.exercises)
        let cardChanges = idChanges(old.reviewCards, new.reviewCards)
        let tipChanges = idChanges(old.knowledgeTips, new.knowledgeTips)

        let oldRouteByID = firstByID(old.routes)
        let newRouteByID = firstByID(new.routes)
        let reorderedModules = Set(oldRouteByID.keys).intersection(newRouteByID.keys)
            .filter { oldRouteByID[$0]?.moduleIDs != newRouteByID[$0]?.moduleIDs }
            .sorted()

        let sharedModuleIDs = Set(old.modules.map(\.id)).intersection(new.modules.map(\.id))
        let reorderedLessons = sharedModuleIDs.filter { moduleID in
            lessonOrder(in: old, moduleID: moduleID) != lessonOrder(in: new, moduleID: moduleID)
        }.sorted()

        let oldExerciseByID = firstByID(old.exercises)
        let newExerciseByID = firstByID(new.exercises)
        let sharedExerciseIDs = Set(oldExerciseByID.keys).intersection(newExerciseByID.keys)
        let changedCorrectAnswers = sharedExerciseIDs.filter {
            oldExerciseByID[$0]?.correctOptionID != newExerciseByID[$0]?.correctOptionID
        }.sorted()

        var changedLearningContent: Set<String> = []
        for id in sharedExerciseIDs
        where oldExerciseByID[id] != newExerciseByID[id] {
            changedLearningContent.insert("exercise:\(id)")
        }
        let oldCardByID = firstByID(old.reviewCards)
        let newCardByID = firstByID(new.reviewCards)
        for id in Set(oldCardByID.keys).intersection(newCardByID.keys)
        where oldCardByID[id] != newCardByID[id] {
            changedLearningContent.insert("reviewCard:\(id)")
        }
        let oldLessonByID = firstByID(old.lessons)
        let newLessonByID = firstByID(new.lessons)
        for id in Set(oldLessonByID.keys).intersection(newLessonByID.keys)
        where oldLessonByID[id]?.blocks != newLessonByID[id]?.blocks {
            changedLearningContent.insert("lesson:\(id)")
        }

        var riskNotes: [String] = []
        if !moduleChanges.removed.isEmpty {
            riskNotes.append("Removed modules remain in user history but disappear from the current catalog.")
        }
        if !lessonChanges.removed.isEmpty {
            riskNotes.append("Removed lessons may affect resume state; keep their IDs retired.")
        }
        if !cardChanges.removed.isEmpty {
            riskNotes.append("Removed review cards remain in historical FSRS records.")
        }
        let removedStableIDs = removedStableIDs(old: old, new: new)
        let missingRetiredIDs = removedStableIDs.subtracting(new.retiredIDs).sorted()
        if !missingRetiredIDs.isEmpty {
            riskNotes.append(
                "Removed persistent IDs are missing from retiredIDs: \(missingRetiredIDs.joined(separator: ", "))."
            )
        }
        if !changedCorrectAnswers.isEmpty {
            riskNotes.append("Correct-answer changes require explicit educational review.")
        }
        if !changedLearningContent.isEmpty {
            riskNotes.append("Material learning changes that should reset memory require new stable IDs.")
        }

        let contentPayloadChanged = contentPayload(old) != contentPayload(new)
        let packagePayloadChanged: Bool?
        if let oldManifest, let newManifest {
            packagePayloadChanged = oldManifest.unsigned() != newManifest.unsigned()
        } else {
            packagePayloadChanged = nil
        }
        if packagePayloadChanged == true, !contentPayloadChanged {
            riskNotes.append(
                "The release package changed outside CatalogV2.json; review manifest metadata and asset hashes."
            )
        }
        let releasePayloadChanged = contentPayloadChanged
            || packagePayloadChanged == true
            || old.releaseVersion != new.releaseVersion
        let strictViolations = strictViolations(
            old: old,
            new: new,
            oldManifest: oldManifest,
            newManifest: newManifest,
            releasePayloadChanged: releasePayloadChanged,
            missingRetiredIDs: missingRetiredIDs
        )

        return ContentDiffReport(
            oldReleaseVersion: old.releaseVersion,
            newReleaseVersion: new.releaseVersion,
            contentPayloadChanged: contentPayloadChanged,
            addedRoutes: routeChanges.added,
            removedRoutes: routeChanges.removed,
            addedModules: moduleChanges.added,
            removedModules: moduleChanges.removed,
            addedLessons: lessonChanges.added,
            removedLessons: lessonChanges.removed,
            addedExercises: exerciseChanges.added,
            removedExercises: exerciseChanges.removed,
            addedReviewCards: cardChanges.added,
            removedReviewCards: cardChanges.removed,
            addedKnowledgeTips: tipChanges.added,
            removedKnowledgeTips: tipChanges.removed,
            reorderedModules: reorderedModules,
            reorderedLessons: reorderedLessons,
            changedCorrectAnswers: changedCorrectAnswers,
            changedLearningContent: changedLearningContent.sorted(),
            riskNotes: riskNotes,
            strictViolations: strictViolations,
            packagePayloadChanged: packagePayloadChanged
        )
    }

    private static func strictViolations(
        old: CatalogDocumentV2,
        new: CatalogDocumentV2,
        oldManifest: ContentManifestV1?,
        newManifest: ContentManifestV1?,
        releasePayloadChanged: Bool,
        missingRetiredIDs: [String]
    ) -> [ContentDiffViolation] {
        var result: [ContentDiffViolation] = []
        let oldVersion = ContentReleaseVersion(old.releaseVersion)
        let newVersion = ContentReleaseVersion(new.releaseVersion)

        if oldVersion == nil {
            result.append(
                ContentDiffViolation(
                    code: "release.oldInvalid",
                    message: "Baseline releaseVersion '\(old.releaseVersion)' is invalid."
                )
            )
        }
        if newVersion == nil {
            result.append(
                ContentDiffViolation(
                    code: "release.newInvalid",
                    message: "New releaseVersion '\(new.releaseVersion)' is invalid."
                )
            )
        }
        if let oldManifest, oldManifest.releaseVersion != old.releaseVersion {
            result.append(
                ContentDiffViolation(
                    code: "manifest.oldReleaseMismatch",
                    message: "Baseline manifest releaseVersion '\(oldManifest.releaseVersion)' does not match baseline catalog '\(old.releaseVersion)'."
                )
            )
        }
        if let newManifest, newManifest.releaseVersion != new.releaseVersion {
            result.append(
                ContentDiffViolation(
                    code: "manifest.newReleaseMismatch",
                    message: "New manifest releaseVersion '\(newManifest.releaseVersion)' does not match new catalog '\(new.releaseVersion)'."
                )
            )
        }
        if let oldVersion, let newVersion {
            if newVersion < oldVersion {
                result.append(
                    ContentDiffViolation(
                        code: "release.downgrade",
                        message: "releaseVersion must not decrease from \(old.releaseVersion) to \(new.releaseVersion)."
                    )
                )
            } else if releasePayloadChanged, !(oldVersion < newVersion) {
                result.append(
                    ContentDiffViolation(
                        code: "release.notIncremented",
                        message: "Catalog or release package changed, so releaseVersion must increase from \(old.releaseVersion) to a higher version."
                    )
                )
            }
        }
        if !missingRetiredIDs.isEmpty {
            result.append(
                ContentDiffViolation(
                    code: "retired.missing",
                    message: "Removed stable IDs must be added to retiredIDs: \(missingRetiredIDs.joined(separator: ", "))."
                )
            )
        }

        let removedRetiredIDs = Set(old.retiredIDs).subtracting(new.retiredIDs).sorted()
        if !removedRetiredIDs.isEmpty {
            result.append(
                ContentDiffViolation(
                    code: "retired.notAppendOnly",
                    message: "retiredIDs is append-only; restore: \(removedRetiredIDs.joined(separator: ", "))."
                )
            )
        }

        let reusedRetiredIDs = Set(old.retiredIDs)
            .intersection(stableLiveIDs(in: new))
            .sorted()
        if !reusedRetiredIDs.isEmpty {
            result.append(
                ContentDiffViolation(
                    code: "retired.reused",
                    message: "Previously retired IDs cannot become live again: \(reusedRetiredIDs.joined(separator: ", "))."
                )
            )
        }
        return result
    }

    private static func removedStableIDs(
        old: CatalogDocumentV2,
        new: CatalogDocumentV2
    ) -> Set<String> {
        var removed: Set<String> = []
        removed.formUnion(removedIDs(old.tracks, new.tracks))
        removed.formUnion(removedIDs(old.routes, new.routes))
        removed.formUnion(removedIDs(old.modules, new.modules))
        removed.formUnion(removedIDs(old.lessons, new.lessons))
        removed.formUnion(removedIDs(old.exercises, new.exercises))
        removed.formUnion(removedIDs(old.reviewCards, new.reviewCards))
        removed.formUnion(removedIDs(old.knowledgeTips, new.knowledgeTips))

        let oldOptionIDs = Set(old.exercises.flatMap { $0.options.map(\.id) })
        let newOptionIDs = Set(new.exercises.flatMap { $0.options.map(\.id) })
        removed.formUnion(oldOptionIDs.subtracting(newOptionIDs))
        return removed
    }

    private static func stableLiveIDs(in catalog: CatalogDocumentV2) -> Set<String> {
        var result = Set(catalog.tracks.map(\.id))
        result.formUnion(catalog.routes.map(\.id))
        result.formUnion(catalog.modules.map(\.id))
        result.formUnion(catalog.lessons.map(\.id))
        result.formUnion(catalog.exercises.map(\.id))
        result.formUnion(catalog.exercises.flatMap { $0.options.map(\.id) })
        result.formUnion(catalog.reviewCards.map(\.id))
        result.formUnion(catalog.knowledgeTips.map(\.id))
        return result
    }

    private static func removedIDs<Element: Identifiable>(
        _ old: [Element],
        _ new: [Element]
    ) -> Set<String> where Element.ID == String {
        Set(old.map(\.id)).subtracting(new.map(\.id))
    }

    private static func contentPayload(_ catalog: CatalogDocumentV2) -> ContentPayload {
        ContentPayload(
            schemaVersion: catalog.schemaVersion,
            locale: catalog.locale,
            primaryRouteID: catalog.primaryRouteID,
            tracks: catalog.tracks,
            routes: catalog.routes,
            modules: catalog.modules,
            lessons: catalog.lessons,
            exercises: catalog.exercises,
            reviewCards: catalog.reviewCards,
            knowledgeTips: catalog.knowledgeTips,
            retiredIDs: catalog.retiredIDs
        )
    }

    private static func firstByID<Element: Identifiable>(
        _ elements: [Element]
    ) -> [String: Element] where Element.ID == String {
        var result: [String: Element] = [:]
        for element in elements where result[element.id] == nil {
            result[element.id] = element
        }
        return result
    }

    private static func idChanges<Element: Identifiable>(
        _ old: [Element],
        _ new: [Element]
    ) -> (added: [String], removed: [String]) where Element.ID == String {
        let oldIDs = Set(old.map(\.id))
        let newIDs = Set(new.map(\.id))
        return (
            newIDs.subtracting(oldIDs).sorted(),
            oldIDs.subtracting(newIDs).sorted()
        )
    }

    private static func lessonOrder(
        in catalog: CatalogDocumentV2,
        moduleID: String
    ) -> [String] {
        catalog.lessons
            .filter { $0.moduleID == moduleID }
            .sorted {
                if $0.order != $1.order { return $0.order < $1.order }
                return $0.id < $1.id
            }
            .map(\.id)
    }
}

private struct ContentPayload: Equatable {
    let schemaVersion: Int
    let locale: String
    let primaryRouteID: String
    let tracks: [TrackDefinition]
    let routes: [RouteDefinition]
    let modules: [ModuleDefinition]
    let lessons: [LessonDefinition]
    let exercises: [ExerciseDefinition]
    let reviewCards: [ReviewCardDefinition]
    let knowledgeTips: [KnowledgeTipDefinition]
    let retiredIDs: [String]
}
