import Foundation

struct LearnNowCourseBaseInfo: Decodable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let source: String?
    let sourceHash: String?
    let version: Int
}

struct LearnNowCourseResource: Decodable, Equatable {
    let baseInfo: LearnNowCourseBaseInfo
    let modules: [Module]
    let reviewCards: [ReviewCard]

    struct Module: Decodable, Equatable {
        let id: String
        let track: String
        let title: String
        let subtitle: String
        let lessonTitle: String
        let reviewTags: [String]
        let reviewMessage: String
        let pages: [Page]
    }

    struct Page: Decodable, Equatable {
        let id: String
        let badge: String
        let accent: String
        let title: String
        let summary: String
        let calloutTitle: String
        let calloutBody: String
        let calloutAccent: String
        let codeSample: String?
        let question: Question
        let successAction: String
        let sourceAnchors: [String]?
    }

    struct Question: Decodable, Equatable {
        let prompt: String
        let options: [Option]
        let correctOptionID: String
    }

    struct Option: Decodable, Equatable {
        let id: String
        let badge: String
        let title: String
    }

    struct ReviewCard: Decodable, Equatable {
        let id: String
        let topic: String
        let moduleID: String
        let moduleTitle: String
        let bucket: String
        let accent: String
        let frontTitle: String
        let frontSubtitle: String?
        let backTitle: String
        let backBody: String
        let backHighlight: String
        let dueOffsetSeconds: TimeInterval
        let isMastered: Bool
        let isFavorited: Bool
    }
}

enum LearnNowCourseResourceConversionError: Error, Equatable {
    case unknownTrack(String, moduleID: String)
    case unknownAccent(String, pageID: String)
    case unknownCalloutAccent(String, pageID: String)
    case unknownSuccessAction(String, pageID: String)
    case unknownReviewBucket(String, cardID: String)
    case unknownReviewAccent(String, cardID: String)
    case missingCorrectOption(pageID: String, correctOptionID: String)
    case emptyModulePages(moduleID: String)
}

extension LearnNowCourseResource {
    func makeModules() throws -> [LearnNowModuleDefinition] {
        try modules.map { module in
            guard let track = LearnNowRouteTrack(rawValue: module.track) else {
                throw LearnNowCourseResourceConversionError.unknownTrack(module.track, moduleID: module.id)
            }

            let pages = try module.pages.map(makeLessonPage)
            guard !pages.isEmpty else {
                throw LearnNowCourseResourceConversionError.emptyModulePages(moduleID: module.id)
            }

            return LearnNowModuleDefinition(
                id: module.id,
                track: track,
                title: module.title,
                subtitle: module.subtitle,
                lessonTitle: module.lessonTitle,
                lessonPages: pages,
                reviewTags: module.reviewTags,
                reviewMessage: module.reviewMessage
            )
        }
    }

    func makeReviewCards(startOfToday: Date = Calendar.current.startOfDay(for: Date())) throws -> [LearnNowReviewCard] {
        try reviewCards.map { card in
            guard let bucket = LearnNowReviewBucket(rawValue: card.bucket) else {
                throw LearnNowCourseResourceConversionError.unknownReviewBucket(card.bucket, cardID: card.id)
            }
            guard let accent = LearnNowAccent(rawValue: card.accent) else {
                throw LearnNowCourseResourceConversionError.unknownReviewAccent(card.accent, cardID: card.id)
            }

            return LearnNowReviewCard(
                id: card.id,
                topic: card.topic,
                moduleID: card.moduleID,
                moduleTitle: card.moduleTitle,
                bucket: bucket,
                accent: accent,
                frontTitle: card.frontTitle,
                frontSubtitle: card.frontSubtitle,
                backTitle: card.backTitle,
                backBody: card.backBody,
                backHighlight: card.backHighlight,
                dueAt: startOfToday.addingTimeInterval(card.dueOffsetSeconds),
                isMastered: card.isMastered,
                isFavorited: card.isFavorited
            )
        }
    }

    private func makeLessonPage(_ page: Page) throws -> LearnNowLessonPage {
        guard let accent = LearnNowAccent(rawValue: page.accent) else {
            throw LearnNowCourseResourceConversionError.unknownAccent(page.accent, pageID: page.id)
        }
        guard let calloutAccent = LearnNowAccent(rawValue: page.calloutAccent) else {
            throw LearnNowCourseResourceConversionError.unknownCalloutAccent(page.calloutAccent, pageID: page.id)
        }
        guard let successAction = LearnNowLessonCallToAction(resourceValue: page.successAction) else {
            throw LearnNowCourseResourceConversionError.unknownSuccessAction(page.successAction, pageID: page.id)
        }
        guard page.question.options.contains(where: { $0.id == page.question.correctOptionID }) else {
            throw LearnNowCourseResourceConversionError.missingCorrectOption(
                pageID: page.id,
                correctOptionID: page.question.correctOptionID
            )
        }

        return LearnNowLessonPage(
            id: page.id,
            badge: page.badge,
            accent: accent,
            title: page.title,
            summary: page.summary,
            calloutTitle: page.calloutTitle,
            calloutBody: page.calloutBody,
            calloutAccent: calloutAccent,
            codeSample: page.codeSample,
            question: LearnNowLessonQuestion(
                prompt: page.question.prompt,
                options: page.question.options.map {
                    LearnNowLessonOption(id: $0.id, badge: $0.badge, title: $0.title)
                },
                correctOptionID: page.question.correctOptionID
            ),
            successAction: successAction
        )
    }
}

enum LearnNowCourseResourceLoader {
    enum LoaderError: Error, Equatable {
        case missingResource(courseID: String)
    }

    static func load(courseID: String, bundle: Bundle = .main) throws -> LearnNowCourseResource {
        guard let url = resourceURL(courseID: courseID, bundle: bundle) else {
            throw LoaderError.missingResource(courseID: courseID)
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(LearnNowCourseResource.self, from: data)
    }

    private static func resourceURL(courseID: String, bundle: Bundle) -> URL? {
        let subdirectories = [
            "Resources/Courses/\(courseID)",
            "Courses/\(courseID)",
            nil,
        ]

        for subdirectory in subdirectories {
            if let url = bundle.url(
                forResource: subdirectory == nil ? "\(courseID)-course" : "course",
                withExtension: "json",
                subdirectory: subdirectory
            ) {
                return url
            }
        }

        return nil
    }
}

private extension LearnNowLessonCallToAction {
    init?(resourceValue: String) {
        switch resourceValue {
        case "nextPage":
            self = .nextPage
        case "retry":
            self = .retry
        case "completeLesson":
            self = .completeLesson
        default:
            return nil
        }
    }
}
