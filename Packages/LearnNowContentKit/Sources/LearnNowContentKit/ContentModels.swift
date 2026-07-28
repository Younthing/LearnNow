import Foundation

public enum ContentAccent: String, Codable, CaseIterable, Equatable, Sendable {
    case blue
    case pink
    case mint
    case purple
    case amber
}

public enum ContentTone: String, Codable, CaseIterable, Equatable, Sendable {
    case information
    case success
    case warning
}

public indirect enum InlineContent: Equatable, Sendable {
    case text(String)
    case emphasis([InlineContent])
    case strong([InlineContent])
    case code(String)
    case lineBreak

    public var plainText: String {
        switch self {
        case let .text(value), let .code(value):
            value
        case let .emphasis(children), let .strong(children):
            children.map(\.plainText).joined()
        case .lineBreak:
            "\n"
        }
    }
}

extension InlineContent: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case text
        case children
    }

    private enum Kind: String, Codable {
        case text
        case emphasis
        case strong
        case code
        case lineBreak
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .type) {
        case .text:
            self = .text(try container.decode(String.self, forKey: .text))
        case .emphasis:
            self = .emphasis(try container.decode([InlineContent].self, forKey: .children))
        case .strong:
            self = .strong(try container.decode([InlineContent].self, forKey: .children))
        case .code:
            self = .code(try container.decode(String.self, forKey: .text))
        case .lineBreak:
            self = .lineBreak
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .text(value):
            try container.encode(Kind.text, forKey: .type)
            try container.encode(value, forKey: .text)
        case let .emphasis(children):
            try container.encode(Kind.emphasis, forKey: .type)
            try container.encode(children, forKey: .children)
        case let .strong(children):
            try container.encode(Kind.strong, forKey: .type)
            try container.encode(children, forKey: .children)
        case let .code(value):
            try container.encode(Kind.code, forKey: .type)
            try container.encode(value, forKey: .text)
        case .lineBreak:
            try container.encode(Kind.lineBreak, forKey: .type)
        }
    }
}

public struct ListItem: Codable, Equatable, Sendable {
    public let content: [InlineContent]

    public init(content: [InlineContent]) {
        self.content = content
    }
}

public enum LessonContentBlock: Equatable, Sendable {
    case paragraph([InlineContent])
    case heading(level: Int, content: [InlineContent])
    case list(ordered: Bool, items: [ListItem])
    case callout(title: String, tone: ContentTone, accent: ContentAccent, body: [LessonContentBlock])
    case code(language: String?, code: String)
    case image(path: String, alt: String, caption: [InlineContent]?)
    case singleChoice(exerciseID: String)
}

extension LessonContentBlock: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case content
        case level
        case ordered
        case items
        case title
        case tone
        case accent
        case body
        case language
        case code
        case path
        case alt
        case caption
        case exerciseID
    }

    private enum Kind: String, Codable {
        case paragraph
        case heading
        case list
        case callout
        case code
        case image
        case singleChoice
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .type) {
        case .paragraph:
            self = .paragraph(try container.decode([InlineContent].self, forKey: .content))
        case .heading:
            self = .heading(
                level: try container.decode(Int.self, forKey: .level),
                content: try container.decode([InlineContent].self, forKey: .content)
            )
        case .list:
            self = .list(
                ordered: try container.decode(Bool.self, forKey: .ordered),
                items: try container.decode([ListItem].self, forKey: .items)
            )
        case .callout:
            self = .callout(
                title: try container.decode(String.self, forKey: .title),
                tone: try container.decode(ContentTone.self, forKey: .tone),
                accent: try container.decode(ContentAccent.self, forKey: .accent),
                body: try container.decode([LessonContentBlock].self, forKey: .body)
            )
        case .code:
            self = .code(
                language: try container.decodeIfPresent(String.self, forKey: .language),
                code: try container.decode(String.self, forKey: .code)
            )
        case .image:
            self = .image(
                path: try container.decode(String.self, forKey: .path),
                alt: try container.decode(String.self, forKey: .alt),
                caption: try container.decodeIfPresent([InlineContent].self, forKey: .caption)
            )
        case .singleChoice:
            self = .singleChoice(exerciseID: try container.decode(String.self, forKey: .exerciseID))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .paragraph(content):
            try container.encode(Kind.paragraph, forKey: .type)
            try container.encode(content, forKey: .content)
        case let .heading(level, content):
            try container.encode(Kind.heading, forKey: .type)
            try container.encode(level, forKey: .level)
            try container.encode(content, forKey: .content)
        case let .list(ordered, items):
            try container.encode(Kind.list, forKey: .type)
            try container.encode(ordered, forKey: .ordered)
            try container.encode(items, forKey: .items)
        case let .callout(title, tone, accent, body):
            try container.encode(Kind.callout, forKey: .type)
            try container.encode(title, forKey: .title)
            try container.encode(tone, forKey: .tone)
            try container.encode(accent, forKey: .accent)
            try container.encode(body, forKey: .body)
        case let .code(language, code):
            try container.encode(Kind.code, forKey: .type)
            try container.encodeIfPresent(language, forKey: .language)
            try container.encode(code, forKey: .code)
        case let .image(path, alt, caption):
            try container.encode(Kind.image, forKey: .type)
            try container.encode(path, forKey: .path)
            try container.encode(alt, forKey: .alt)
            try container.encodeIfPresent(caption, forKey: .caption)
        case let .singleChoice(exerciseID):
            try container.encode(Kind.singleChoice, forKey: .type)
            try container.encode(exerciseID, forKey: .exerciseID)
        }
    }
}

public struct TrackDefinition: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

public struct RouteDefinition: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let systemImage: String
    public let accent: ContentAccent
    public let cta: String
    public let interactive: Bool
    public let trackIDs: [String]
    public let moduleIDs: [String]

    public init(
        id: String,
        title: String,
        subtitle: String,
        systemImage: String,
        accent: ContentAccent,
        cta: String,
        interactive: Bool,
        trackIDs: [String],
        moduleIDs: [String]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.accent = accent
        self.cta = cta
        self.interactive = interactive
        self.trackIDs = trackIDs
        self.moduleIDs = moduleIDs
    }
}

public struct ModuleDefinition: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let trackID: String
    public let title: String
    public let subtitle: String
    public let lessonTitle: String
    public let prerequisiteModuleIDs: [String]
    public let completionXP: Int
    public let reviewMessage: String

    public init(
        id: String,
        trackID: String,
        title: String,
        subtitle: String,
        lessonTitle: String,
        prerequisiteModuleIDs: [String],
        completionXP: Int,
        reviewMessage: String
    ) {
        self.id = id
        self.trackID = trackID
        self.title = title
        self.subtitle = subtitle
        self.lessonTitle = lessonTitle
        self.prerequisiteModuleIDs = prerequisiteModuleIDs
        self.completionXP = completionXP
        self.reviewMessage = reviewMessage
    }
}

public struct LessonDefinition: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let moduleID: String
    public let order: Int
    public let title: String
    public let accent: ContentAccent
    public let revision: Int
    public let locale: String
    public let objectives: [String]
    public let blocks: [LessonContentBlock]

    public init(
        id: String,
        moduleID: String,
        order: Int,
        title: String,
        accent: ContentAccent,
        revision: Int,
        locale: String,
        objectives: [String],
        blocks: [LessonContentBlock]
    ) {
        self.id = id
        self.moduleID = moduleID
        self.order = order
        self.title = title
        self.accent = accent
        self.revision = revision
        self.locale = locale
        self.objectives = objectives
        self.blocks = blocks
    }
}

public struct ExerciseOptionDefinition: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let content: [InlineContent]
    public let feedback: FeedbackDefinition?

    public init(id: String, content: [InlineContent], feedback: FeedbackDefinition? = nil) {
        self.id = id
        self.content = content
        self.feedback = feedback
    }
}

public struct FeedbackDefinition: Codable, Equatable, Sendable {
    public let title: String
    public let body: [InlineContent]
    public let tone: ContentTone
    public let accent: ContentAccent

    public init(title: String, body: [InlineContent], tone: ContentTone, accent: ContentAccent) {
        self.title = title
        self.body = body
        self.tone = tone
        self.accent = accent
    }
}

public struct ExerciseDefinition: Codable, Equatable, Identifiable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case singleChoice
    }

    public let id: String
    public let lessonID: String
    public let kind: Kind
    public let prompt: [InlineContent]
    public let options: [ExerciseOptionDefinition]
    public let correctOptionID: String
    public let correctFeedback: FeedbackDefinition
    public let incorrectFeedback: FeedbackDefinition

    public init(
        id: String,
        lessonID: String,
        kind: Kind = .singleChoice,
        prompt: [InlineContent],
        options: [ExerciseOptionDefinition],
        correctOptionID: String,
        correctFeedback: FeedbackDefinition,
        incorrectFeedback: FeedbackDefinition
    ) {
        self.id = id
        self.lessonID = lessonID
        self.kind = kind
        self.prompt = prompt
        self.options = options
        self.correctOptionID = correctOptionID
        self.correctFeedback = correctFeedback
        self.incorrectFeedback = incorrectFeedback
    }
}

public struct ReviewCardDefinition: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let moduleID: String
    public let sourceLessonID: String?
    public let revision: Int
    public let locale: String
    public let topic: String
    public let accent: ContentAccent
    public let frontTitle: String
    public let frontSubtitle: String?
    public let backTitle: String
    public let backBody: [InlineContent]
    public let backHighlight: [InlineContent]

    public init(
        id: String,
        moduleID: String,
        sourceLessonID: String? = nil,
        revision: Int,
        locale: String,
        topic: String,
        accent: ContentAccent,
        frontTitle: String,
        frontSubtitle: String? = nil,
        backTitle: String,
        backBody: [InlineContent],
        backHighlight: [InlineContent]
    ) {
        self.id = id
        self.moduleID = moduleID
        self.sourceLessonID = sourceLessonID
        self.revision = revision
        self.locale = locale
        self.topic = topic
        self.accent = accent
        self.frontTitle = frontTitle
        self.frontSubtitle = frontSubtitle
        self.backTitle = backTitle
        self.backBody = backBody
        self.backHighlight = backHighlight
    }
}

public struct KnowledgeTipDefinition: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let moduleID: String?
    public let sourceLessonID: String?
    public let revision: Int
    public let locale: String
    public let title: String
    public let body: [InlineContent]
    public let systemImage: String
    public let accent: ContentAccent

    public init(
        id: String,
        moduleID: String? = nil,
        sourceLessonID: String? = nil,
        revision: Int,
        locale: String,
        title: String,
        body: [InlineContent],
        systemImage: String,
        accent: ContentAccent
    ) {
        self.id = id
        self.moduleID = moduleID
        self.sourceLessonID = sourceLessonID
        self.revision = revision
        self.locale = locale
        self.title = title
        self.body = body
        self.systemImage = systemImage
        self.accent = accent
    }
}

public struct CatalogDocumentV2: Codable, Equatable, Sendable {
    public static let currentSchemaVersion = 2

    public let schemaVersion: Int
    public let releaseVersion: String
    public let locale: String
    public let primaryRouteID: String
    public let tracks: [TrackDefinition]
    public let routes: [RouteDefinition]
    public let modules: [ModuleDefinition]
    public let lessons: [LessonDefinition]
    public let exercises: [ExerciseDefinition]
    public let reviewCards: [ReviewCardDefinition]
    public let knowledgeTips: [KnowledgeTipDefinition]
    public let retiredIDs: [String]

    public init(
        schemaVersion: Int = CatalogDocumentV2.currentSchemaVersion,
        releaseVersion: String,
        locale: String,
        primaryRouteID: String,
        tracks: [TrackDefinition],
        routes: [RouteDefinition],
        modules: [ModuleDefinition],
        lessons: [LessonDefinition],
        exercises: [ExerciseDefinition],
        reviewCards: [ReviewCardDefinition],
        knowledgeTips: [KnowledgeTipDefinition],
        retiredIDs: [String] = []
    ) {
        self.schemaVersion = schemaVersion
        self.releaseVersion = releaseVersion
        self.locale = locale
        self.primaryRouteID = primaryRouteID
        self.tracks = tracks
        self.routes = routes
        self.modules = modules
        self.lessons = lessons
        self.exercises = exercises
        self.reviewCards = reviewCards
        self.knowledgeTips = knowledgeTips
        self.retiredIDs = retiredIDs
    }
}

public struct ContentManifestFile: Codable, Equatable, Sendable {
    public let path: String
    public let size: Int
    public let sha256: String

    public init(path: String, size: Int, sha256: String) {
        self.path = path
        self.size = size
        self.sha256 = sha256
    }
}

public struct ContentManifestV1: Codable, Equatable, Sendable {
    public static let currentSchemaVersion = 1

    public let schemaVersion: Int
    public let releaseVersion: String
    public let compilerVersion: String
    public let locale: String
    public let minAppBuild: Int
    public let requiredCapabilities: [String]
    public let publishedAt: String
    public let files: [ContentManifestFile]
    public let retiredIDs: [String]
    public let keyID: String?
    public let signature: String?

    public init(
        schemaVersion: Int = ContentManifestV1.currentSchemaVersion,
        releaseVersion: String,
        compilerVersion: String,
        locale: String,
        minAppBuild: Int,
        requiredCapabilities: [String],
        publishedAt: String,
        files: [ContentManifestFile],
        retiredIDs: [String],
        keyID: String? = nil,
        signature: String? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.releaseVersion = releaseVersion
        self.compilerVersion = compilerVersion
        self.locale = locale
        self.minAppBuild = minAppBuild
        self.requiredCapabilities = requiredCapabilities
        self.publishedAt = publishedAt
        self.files = files
        self.retiredIDs = retiredIDs
        self.keyID = keyID
        self.signature = signature
    }

    public func unsigned() -> ContentManifestV1 {
        ContentManifestV1(
            schemaVersion: schemaVersion,
            releaseVersion: releaseVersion,
            compilerVersion: compilerVersion,
            locale: locale,
            minAppBuild: minAppBuild,
            requiredCapabilities: requiredCapabilities,
            publishedAt: publishedAt,
            files: files,
            retiredIDs: retiredIDs,
            keyID: keyID
        )
    }
}
