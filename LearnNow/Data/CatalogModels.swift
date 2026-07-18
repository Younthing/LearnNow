import Foundation

struct CourseCatalog: Equatable, Sendable {
    struct KnowledgeTip: Identifiable, Equatable, Sendable {
        let id: String
        let title: String
        let body: String
        let systemImage: String
        let accent: LearnNowAccent
    }

    let schemaVersion: Int
    let primaryRouteID: String
    let routes: [LearnNowRoute]
    let moduleIDsByRouteID: [String: [String]]
    let modules: [LearnNowModuleDefinition]
    let reviewCards: [CatalogReviewCardDefinition]
    let dailyTips: [KnowledgeTip]

    static let empty = CourseCatalog(
        schemaVersion: 1,
        primaryRouteID: "",
        routes: [],
        moduleIDsByRouteID: [:],
        modules: [],
        reviewCards: [],
        dailyTips: []
    )

    var primaryRoute: LearnNowRoute? {
        routes.first(where: { $0.id == primaryRouteID }) ?? routes.first
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
    let accent: LearnNowAccent
    let frontTitle: String
    let frontSubtitle: String?
    let backTitle: String
    let backBody: String
    let backHighlight: String
}

struct CatalogDocumentV1: Codable, Sendable {
    struct Route: Codable, Sendable {
        let id: String
        let title: String
        let subtitle: String
        let accent: LearnNowAccent
        let cta: String
        let interactive: Bool
        let moduleIDs: [String]
    }

    struct Module: Codable, Sendable {
        let id: String
        let track: LearnNowRouteTrack
        let title: String
        let subtitle: String
        let lessonTitle: String
        let prerequisiteModuleIDs: [String]
        let completionXP: Int
        let reviewCardIDs: [String]
        let reviewMessage: String
        let pages: [Page]
    }

    struct Page: Codable, Sendable {
        let id: String
        let badge: String
        let accent: LearnNowAccent
        let title: String
        let summary: String
        let calloutTitle: String
        let calloutBody: String
        let calloutAccent: LearnNowAccent
        let codeSample: String?
        let quiz: Quiz
    }

    struct Quiz: Codable, Sendable {
        let prompt: String
        let options: [Option]
        let correctOptionID: String
    }

    struct Option: Codable, Sendable {
        let id: String
        let badge: String
        let title: String
    }

    struct ReviewCard: Codable, Sendable {
        let id: String
        let topic: String
        let moduleID: String
        let accent: LearnNowAccent
        let frontTitle: String
        let frontSubtitle: String?
        let backTitle: String
        let backBody: String
        let backHighlight: String
    }

    struct KnowledgeTip: Codable, Sendable {
        let id: String
        let title: String
        let body: String
        let systemImage: String
        let accent: LearnNowAccent
    }

    let schemaVersion: Int
    let primaryRouteID: String
    let routes: [Route]
    let modules: [Module]
    let reviewCards: [ReviewCard]
    let dailyTips: [KnowledgeTip]
}

enum CatalogValidationError: LocalizedError, Equatable {
    case unsupportedSchemaVersion(Int)
    case emptyCollection(String)
    case emptyID(String)
    case duplicateID(kind: String, id: String)
    case missingReference(kind: String, id: String, ownerID: String)
    case invalidCorrectOption(pageID: String, optionID: String)
    case cyclicPrerequisites([String])

    var errorDescription: String? {
        switch self {
        case let .unsupportedSchemaVersion(version):
            "不支持课程目录版本 \(version)。"
        case let .emptyCollection(name):
            "课程目录中的 \(name) 不能为空。"
        case let .emptyID(kind):
            "课程目录中的 \(kind) ID 不能为空。"
        case let .duplicateID(kind, id):
            "\(kind) ID 重复：\(id)。"
        case let .missingReference(kind, id, ownerID):
            "\(ownerID) 引用了不存在的 \(kind)：\(id)。"
        case let .invalidCorrectOption(pageID, optionID):
            "页面 \(pageID) 的正确答案不存在：\(optionID)。"
        case let .cyclicPrerequisites(ids):
            "课程先修关系形成循环：\(ids.joined(separator: " → "))。"
        }
    }
}

enum CatalogDecoder {
    static func decode(data: Data) throws -> CourseCatalog {
        let document = try JSONDecoder().decode(CatalogDocumentV1.self, from: data)
        return try validateAndMap(document)
    }

    static func validateAndMap(_ document: CatalogDocumentV1) throws -> CourseCatalog {
        guard document.schemaVersion == 1 else {
            throw CatalogValidationError.unsupportedSchemaVersion(document.schemaVersion)
        }
        guard !document.routes.isEmpty else {
            throw CatalogValidationError.emptyCollection("routes")
        }
        guard !document.modules.isEmpty else {
            throw CatalogValidationError.emptyCollection("modules")
        }

        try requireUnique(document.routes.map(\.id), kind: "route")
        try requireUnique(document.modules.map(\.id), kind: "module")
        try requireUnique(document.modules.flatMap { $0.pages.map(\.id) }, kind: "page")
        try requireUnique(document.reviewCards.map(\.id), kind: "reviewCard")
        try requireUnique(document.dailyTips.map(\.id), kind: "dailyTip")
        try requireNonempty(document.routes.map(\.id), kind: "route")
        try requireNonempty(document.modules.map(\.id), kind: "module")
        try requireNonempty(document.modules.flatMap { $0.pages.map(\.id) }, kind: "page")
        try requireNonempty(document.reviewCards.map(\.id), kind: "reviewCard")
        try requireNonempty(document.dailyTips.map(\.id), kind: "dailyTip")

        let moduleIDs = Set(document.modules.map(\.id))
        let cardIDs = Set(document.reviewCards.map(\.id))

        guard document.routes.contains(where: { $0.id == document.primaryRouteID }) else {
            throw CatalogValidationError.missingReference(
                kind: "primaryRoute",
                id: document.primaryRouteID,
                ownerID: "catalog"
            )
        }

        for route in document.routes {
            for moduleID in route.moduleIDs where !moduleIDs.contains(moduleID) {
                throw CatalogValidationError.missingReference(
                    kind: "module",
                    id: moduleID,
                    ownerID: route.id
                )
            }
        }

        for module in document.modules {
            guard !module.pages.isEmpty else {
                throw CatalogValidationError.emptyCollection("pages[\(module.id)]")
            }
            try requireUnique(module.pages.map(\.id), kind: "page")

            for prerequisiteID in module.prerequisiteModuleIDs where !moduleIDs.contains(prerequisiteID) {
                throw CatalogValidationError.missingReference(
                    kind: "prerequisiteModule",
                    id: prerequisiteID,
                    ownerID: module.id
                )
            }
            for cardID in module.reviewCardIDs where !cardIDs.contains(cardID) {
                throw CatalogValidationError.missingReference(
                    kind: "reviewCard",
                    id: cardID,
                    ownerID: module.id
                )
            }

            for page in module.pages {
                guard !page.quiz.options.isEmpty else {
                    throw CatalogValidationError.emptyCollection("quiz.options[\(page.id)]")
                }
                try requireUnique(page.quiz.options.map(\.id), kind: "quizOption")
                guard page.quiz.options.contains(where: { $0.id == page.quiz.correctOptionID }) else {
                    throw CatalogValidationError.invalidCorrectOption(
                        pageID: page.id,
                        optionID: page.quiz.correctOptionID
                    )
                }
            }
        }

        for card in document.reviewCards where !moduleIDs.contains(card.moduleID) {
            throw CatalogValidationError.missingReference(
                kind: "module",
                id: card.moduleID,
                ownerID: card.id
            )
        }

        try validateAcyclicPrerequisites(document.modules)

        let moduleByID = Dictionary(uniqueKeysWithValues: document.modules.map { ($0.id, $0) })
        let orderedModuleIDs = document.routes.flatMap(\.moduleIDs)
        let remainingModuleIDs = document.modules.map(\.id).filter { !orderedModuleIDs.contains($0) }
        let orderedModules = (orderedModuleIDs + remainingModuleIDs).compactMap { moduleByID[$0] }

        return CourseCatalog(
            schemaVersion: document.schemaVersion,
            primaryRouteID: document.primaryRouteID,
            routes: document.routes.map {
                LearnNowRoute(
                    id: $0.id,
                    title: $0.title,
                    subtitle: $0.subtitle,
                    progress: 0,
                    accent: $0.accent,
                    cta: $0.cta,
                    interactive: $0.interactive
                )
            },
            moduleIDsByRouteID: Dictionary(
                uniqueKeysWithValues: document.routes.map { ($0.id, $0.moduleIDs) }
            ),
            modules: orderedModules.map { module in
                LearnNowModuleDefinition(
                    id: module.id,
                    track: module.track,
                    title: module.title,
                    subtitle: module.subtitle,
                    lessonTitle: module.lessonTitle,
                    lessonPages: module.pages.enumerated().map { index, page in
                        LearnNowLessonPage(
                            id: page.id,
                            badge: page.badge,
                            accent: page.accent,
                            title: page.title,
                            summary: page.summary,
                            calloutTitle: page.calloutTitle,
                            calloutBody: page.calloutBody,
                            calloutAccent: page.calloutAccent,
                            codeSample: page.codeSample,
                            question: LearnNowLessonQuestion(
                                prompt: page.quiz.prompt,
                                options: page.quiz.options.map {
                                    LearnNowLessonOption(id: $0.id, badge: $0.badge, title: $0.title)
                                },
                                correctOptionID: page.quiz.correctOptionID
                            ),
                            successAction: index == module.pages.count - 1 ? .completeLesson : .nextPage
                        )
                    },
                    reviewTags: module.reviewCardIDs.compactMap { cardID in
                        document.reviewCards.first(where: { $0.id == cardID })?.frontTitle
                    },
                    reviewMessage: module.reviewMessage,
                    prerequisiteModuleIDs: module.prerequisiteModuleIDs,
                    completionXP: module.completionXP,
                    reviewCardIDs: module.reviewCardIDs
                )
            },
            reviewCards: document.reviewCards.map {
                CatalogReviewCardDefinition(
                    id: $0.id,
                    topic: $0.topic,
                    moduleID: $0.moduleID,
                    accent: $0.accent,
                    frontTitle: $0.frontTitle,
                    frontSubtitle: $0.frontSubtitle,
                    backTitle: $0.backTitle,
                    backBody: $0.backBody,
                    backHighlight: $0.backHighlight
                )
            },
            dailyTips: document.dailyTips.map {
                CourseCatalog.KnowledgeTip(
                    id: $0.id,
                    title: $0.title,
                    body: $0.body,
                    systemImage: $0.systemImage,
                    accent: $0.accent
                )
            }
        )
    }

    private static func requireUnique(_ ids: [String], kind: String) throws {
        var seen: Set<String> = []
        for id in ids where !seen.insert(id).inserted {
            throw CatalogValidationError.duplicateID(kind: kind, id: id)
        }
    }

    private static func requireNonempty(_ ids: [String], kind: String) throws {
        if ids.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            throw CatalogValidationError.emptyID(kind)
        }
    }

    private static func validateAcyclicPrerequisites(_ modules: [CatalogDocumentV1.Module]) throws {
        let prerequisites = Dictionary(uniqueKeysWithValues: modules.map { ($0.id, $0.prerequisiteModuleIDs) })
        var visited: Set<String> = []
        var visiting: [String] = []

        func visit(_ id: String) throws {
            if let cycleStart = visiting.firstIndex(of: id) {
                throw CatalogValidationError.cyclicPrerequisites(Array(visiting[cycleStart...]) + [id])
            }
            guard !visited.contains(id) else { return }
            visiting.append(id)
            for prerequisite in prerequisites[id, default: []] {
                try visit(prerequisite)
            }
            _ = visiting.popLast()
            visited.insert(id)
        }

        for module in modules {
            try visit(module.id)
        }
    }
}
