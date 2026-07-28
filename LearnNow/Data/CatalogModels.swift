import Foundation
import LearnNowContentKit

struct CourseCatalog: Equatable, Sendable {
    struct Track: Identifiable, Equatable, Sendable {
        let id: String
        let title: String
    }

    struct KnowledgeTip: Identifiable, Equatable, Sendable {
        let id: String
        let moduleID: String?
        let sourceLessonID: String?
        let title: String
        let body: [InlineContent]
        let systemImage: String
        let accent: LearnNowAccent
    }

    let schemaVersion: Int
    let releaseVersion: String
    let locale: String
    let contentRootURL: URL?
    let primaryRouteID: String
    let tracks: [Track]
    let routes: [LearnNowRoute]
    let moduleIDsByRouteID: [String: [String]]
    let modules: [LearnNowModuleDefinition]
    let reviewCards: [CatalogReviewCardDefinition]
    let dailyTips: [KnowledgeTip]
    let retiredIDs: Set<String>

    static let empty = CourseCatalog(
        schemaVersion: CatalogDocumentV2.currentSchemaVersion,
        releaseVersion: "",
        locale: "",
        contentRootURL: nil,
        primaryRouteID: "",
        tracks: [],
        routes: [],
        moduleIDsByRouteID: [:],
        modules: [],
        reviewCards: [],
        dailyTips: [],
        retiredIDs: []
    )

    var primaryRoute: LearnNowRoute? {
        routes.first(where: { $0.id == primaryRouteID }) ?? routes.first
    }

    func route(id: String) -> LearnNowRoute? {
        routes.first(where: { $0.id == id })
    }

    func route(containingModuleID moduleID: String) -> LearnNowRoute? {
        routes.first { moduleIDsByRouteID[$0.id, default: []].contains(moduleID) }
    }

    func track(id: String) -> Track? {
        tracks.first(where: { $0.id == id })
    }

    func module(id: String) -> LearnNowModuleDefinition? {
        modules.first(where: { $0.id == id })
    }

    func reviewCard(id: String) -> CatalogReviewCardDefinition? {
        reviewCards.first(where: { $0.id == id })
    }
}

struct CatalogReviewCardDefinition: Identifiable, Equatable, Sendable {
    let id: String
    let topic: String
    let moduleID: String
    let sourceLessonID: String?
    let accent: LearnNowAccent
    let frontTitle: String
    let frontSubtitle: String?
    let backTitle: String
    let backBody: [InlineContent]
    let backHighlight: [InlineContent]
}

enum CatalogDecoder {
    static func decode(data: Data, contentRootURL: URL? = nil) throws -> CourseCatalog {
        let document = try DeterministicJSON.decode(CatalogDocumentV2.self, from: data)
        return try validateAndMap(document, contentRootURL: contentRootURL)
    }

    static func validateAndMap(
        _ document: CatalogDocumentV2,
        contentRootURL: URL? = nil
    ) throws -> CourseCatalog {
        let diagnostics = CatalogSemanticValidator.validate(document)
        let errors = diagnostics.filter { $0.severity == .error }
        guard errors.isEmpty else {
            throw ContentValidationError(diagnostics: errors)
        }

        let moduleByID = Dictionary(uniqueKeysWithValues: document.modules.map { ($0.id, $0) })
        let exerciseByID = Dictionary(uniqueKeysWithValues: document.exercises.map { ($0.id, $0) })
        let orderedModuleIDs = document.routes.flatMap(\.moduleIDs)
        let orderedModules = orderedModuleIDs.compactMap { moduleByID[$0] }
        let cardsByModuleID = Dictionary(grouping: document.reviewCards, by: \.moduleID)

        return CourseCatalog(
            schemaVersion: document.schemaVersion,
            releaseVersion: document.releaseVersion,
            locale: document.locale,
            contentRootURL: contentRootURL,
            primaryRouteID: document.primaryRouteID,
            tracks: document.tracks.map {
                CourseCatalog.Track(id: $0.id, title: $0.title)
            },
            routes: document.routes.map {
                LearnNowRoute(
                    id: $0.id,
                    title: $0.title,
                    subtitle: $0.subtitle,
                    systemImage: $0.systemImage,
                    progress: 0,
                    accent: LearnNowAccent($0.accent),
                    cta: $0.cta,
                    interactive: $0.interactive,
                    trackIDs: $0.trackIDs
                )
            },
            moduleIDsByRouteID: Dictionary(
                uniqueKeysWithValues: document.routes.map { ($0.id, $0.moduleIDs) }
            ),
            modules: orderedModules.map { module in
                let lessons = document.lessons
                    .filter { $0.moduleID == module.id }
                    .sorted {
                        if $0.order == $1.order { return $0.id < $1.id }
                        return $0.order < $1.order
                    }
                let cards = cardsByModuleID[module.id, default: []]

                return LearnNowModuleDefinition(
                    id: module.id,
                    trackID: module.trackID,
                    title: module.title,
                    subtitle: module.subtitle,
                    lessonTitle: module.lessonTitle,
                    lessonPages: lessons.enumerated().map { index, lesson in
                        let exerciseIDs = lesson.blocks.exerciseIDs
                        let exercises = exerciseIDs.compactMap { exerciseByID[$0] }

                        return LearnNowLessonPage(
                            id: lesson.id,
                            accent: LearnNowAccent(lesson.accent),
                            title: lesson.title,
                            blocks: lesson.blocks,
                            exercises: exercises,
                            successAction: index == lessons.count - 1 ? .completeLesson : .nextPage
                        )
                    },
                    reviewTags: cards.map(\.frontTitle),
                    reviewMessage: module.reviewMessage,
                    prerequisiteModuleIDs: module.prerequisiteModuleIDs,
                    completionXP: module.completionXP,
                    reviewCardIDs: cards.map(\.id)
                )
            },
            reviewCards: document.reviewCards.map {
                CatalogReviewCardDefinition(
                    id: $0.id,
                    topic: $0.topic,
                    moduleID: $0.moduleID,
                    sourceLessonID: $0.sourceLessonID,
                    accent: LearnNowAccent($0.accent),
                    frontTitle: $0.frontTitle,
                    frontSubtitle: $0.frontSubtitle,
                    backTitle: $0.backTitle,
                    backBody: $0.backBody,
                    backHighlight: $0.backHighlight
                )
            },
            dailyTips: document.knowledgeTips.map {
                CourseCatalog.KnowledgeTip(
                    id: $0.id,
                    moduleID: $0.moduleID,
                    sourceLessonID: $0.sourceLessonID,
                    title: $0.title,
                    body: $0.body,
                    systemImage: $0.systemImage,
                    accent: LearnNowAccent($0.accent)
                )
            },
            retiredIDs: Set(document.retiredIDs)
        )
    }
}

extension LearnNowAccent {
    init(_ accent: ContentAccent) {
        switch accent {
        case .blue: self = .blue
        case .pink: self = .pink
        case .mint: self = .mint
        case .purple: self = .purple
        case .amber: self = .amber
        }
    }
}

private extension Array where Element == LessonContentBlock {
    var exerciseIDs: [String] {
        flatMap(\.exerciseIDs)
    }
}

private extension LessonContentBlock {
    var exerciseIDs: [String] {
        switch self {
        case let .singleChoice(exerciseID):
            [exerciseID]
        case let .callout(_, _, _, body):
            body.exerciseIDs
        case .paragraph, .heading, .list, .code, .image:
            []
        }
    }
}
