import Foundation

public struct ContentDiagnostic: Codable, Equatable, Sendable, CustomStringConvertible {
    public enum Severity: String, Codable, Equatable, Sendable {
        case error
        case warning
    }

    public let severity: Severity
    public let code: String
    public let message: String
    public let file: String
    public let line: Int?
    public let column: Int?

    public init(
        severity: Severity,
        code: String,
        message: String,
        file: String,
        line: Int? = nil,
        column: Int? = nil
    ) {
        self.severity = severity
        self.code = code
        self.message = message
        self.file = file
        self.line = line
        self.column = column
    }

    public var description: String {
        let location = [line, column].compactMap { $0 }.map(String.init).joined(separator: ":")
        let suffix = location.isEmpty ? "" : ":\(location)"
        return "\(file)\(suffix): \(severity.rawValue): [\(code)] \(message)"
    }
}

public struct ContentValidationError: LocalizedError, Equatable, Sendable {
    public let diagnostics: [ContentDiagnostic]

    public init(diagnostics: [ContentDiagnostic]) {
        self.diagnostics = diagnostics
    }

    public var errorDescription: String? {
        diagnostics.map(\.description).joined(separator: "\n")
    }
}

public enum ContentPolicy {
    public static let maximumImageAssetSize = 8 * 1_024 * 1_024

    public static let allowedImageExtensions: Set<String> = [
        "gif",
        "jpeg",
        "jpg",
        "png",
        "webp",
    ]

    public static let allowedSystemImages: Set<String> = [
        "cpu",
        "paintpalette",
        "chevron.left.forwardslash.chevron.right",
        "lightbulb",
        "chart.bar.xaxis",
    ]

    public static let supportedCapabilities: Set<String> = [
        "paragraph",
        "heading",
        "list",
        "table",
        "callout",
        "code",
        "image",
        "singleChoice",
        "inlineEmphasis",
        "inlineStrong",
        "inlineCode",
    ]
}

public enum CatalogSemanticValidator {
    public static func validate(_ catalog: CatalogDocumentV2) -> [ContentDiagnostic] {
        var diagnostics: [ContentDiagnostic] = []

        func error(_ code: String, _ message: String, _ file: String = "CatalogV2.json") {
            diagnostics.append(
                ContentDiagnostic(severity: .error, code: code, message: message, file: file)
            )
        }

        guard catalog.schemaVersion == CatalogDocumentV2.currentSchemaVersion else {
            return [
                ContentDiagnostic(
                    severity: .error,
                    code: "schema.unsupported",
                    message: "Expected schemaVersion \(CatalogDocumentV2.currentSchemaVersion), got \(catalog.schemaVersion).",
                    file: "CatalogV2.json"
                ),
            ]
        }

        if catalog.routes.isEmpty { error("collection.empty", "routes must not be empty.") }
        if catalog.modules.isEmpty { error("collection.empty", "modules must not be empty.") }
        if catalog.lessons.isEmpty { error("collection.empty", "lessons must not be empty.") }
        if ContentReleaseVersion(catalog.releaseVersion) == nil {
            error(
                "release.invalid",
                "releaseVersion must contain only dot-separated UInt64 decimal components."
            )
        }
        if catalog.locale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error("value.empty", "locale must not be empty.")
        }

        let tracksByID = dictionary(
            catalog.tracks,
            kind: "track",
            id: \.id,
            diagnostics: &diagnostics
        )
        let routesByID = dictionary(
            catalog.routes,
            kind: "route",
            id: \.id,
            diagnostics: &diagnostics
        )
        let modulesByID = dictionary(
            catalog.modules,
            kind: "module",
            id: \.id,
            diagnostics: &diagnostics
        )
        let lessonsByID = dictionary(
            catalog.lessons,
            kind: "lesson",
            id: \.id,
            diagnostics: &diagnostics
        )
        let exercisesByID = dictionary(
            catalog.exercises,
            kind: "exercise",
            id: \.id,
            diagnostics: &diagnostics
        )
        _ = dictionary(
            catalog.reviewCards,
            kind: "reviewCard",
            id: \.id,
            diagnostics: &diagnostics
        )
        _ = dictionary(
            catalog.knowledgeTips,
            kind: "knowledgeTip",
            id: \.id,
            diagnostics: &diagnostics
        )

        var liveEntityIDs = catalog.tracks.map(\.id)
        liveEntityIDs.append(contentsOf: catalog.routes.map(\.id))
        liveEntityIDs.append(contentsOf: catalog.modules.map(\.id))
        liveEntityIDs.append(contentsOf: catalog.lessons.map(\.id))
        liveEntityIDs.append(contentsOf: catalog.exercises.map(\.id))
        liveEntityIDs.append(
            contentsOf: catalog.exercises.flatMap { $0.options.map(\.id) }
        )
        liveEntityIDs.append(contentsOf: catalog.reviewCards.map(\.id))
        liveEntityIDs.append(contentsOf: catalog.knowledgeTips.map(\.id))
        requireUnique(liveEntityIDs, kind: "entity", diagnostics: &diagnostics)

        if routesByID[catalog.primaryRouteID] == nil {
            error(
                "reference.missing",
                "primaryRouteID '\(catalog.primaryRouteID)' does not reference a route."
            )
        }

        var routeOwnerByModuleID: [String: String] = [:]
        for route in catalog.routes {
            requireNonempty(route.title, field: "route.title", ownerID: route.id, diagnostics: &diagnostics)
            requireUnique(route.trackIDs, kind: "route.trackID", diagnostics: &diagnostics)
            requireUnique(route.moduleIDs, kind: "route.moduleID", diagnostics: &diagnostics)
            if !ContentPolicy.allowedSystemImages.contains(route.systemImage) {
                error(
                    "symbol.unsupported",
                    "Route '\(route.id)' uses unsupported systemImage '\(route.systemImage)'."
                )
            }
            for trackID in route.trackIDs where tracksByID[trackID] == nil {
                error(
                    "reference.missing",
                    "Route '\(route.id)' references missing track '\(trackID)'."
                )
            }
            for moduleID in route.moduleIDs {
                guard let module = modulesByID[moduleID] else {
                    error(
                        "reference.missing",
                        "Route '\(route.id)' references missing module '\(moduleID)'."
                    )
                    continue
                }
                if !route.trackIDs.contains(module.trackID) {
                    error(
                        "reference.inconsistent",
                        "Module '\(moduleID)' uses track '\(module.trackID)' outside route '\(route.id)' trackIDs."
                    )
                }
                if let owner = routeOwnerByModuleID.updateValue(route.id, forKey: moduleID), owner != route.id {
                    error(
                        "reference.multipleOwners",
                        "Module '\(moduleID)' belongs to both routes '\(owner)' and '\(route.id)'."
                    )
                }
            }
        }

        for track in catalog.tracks {
            requireNonempty(track.title, field: "track.title", ownerID: track.id, diagnostics: &diagnostics)
        }

        for module in catalog.modules {
            if tracksByID[module.trackID] == nil {
                error(
                    "reference.missing",
                    "Module '\(module.id)' references missing track '\(module.trackID)'."
                )
            }
            if routeOwnerByModuleID[module.id] == nil {
                error("reference.unowned", "Module '\(module.id)' is not owned by a route.")
            }
            if module.completionXP <= 0 {
                error("value.invalid", "Module '\(module.id)' completionXP must be positive.")
            }
            requireUnique(
                module.prerequisiteModuleIDs,
                kind: "module.prerequisiteModuleID",
                diagnostics: &diagnostics
            )
            for prerequisiteID in module.prerequisiteModuleIDs where modulesByID[prerequisiteID] == nil {
                error(
                    "reference.missing",
                    "Module '\(module.id)' references missing prerequisite '\(prerequisiteID)'."
                )
            }
            if !catalog.lessons.contains(where: { $0.moduleID == module.id }) {
                error("collection.empty", "Module '\(module.id)' has no lessons.")
            }
        }
        validatePrerequisiteGraph(catalog.modules, diagnostics: &diagnostics)

        var ordersByModuleID: [String: Set<Int>] = [:]
        var referencedExerciseIDs: Set<String> = []
        for lesson in catalog.lessons {
            if modulesByID[lesson.moduleID] == nil {
                error(
                    "reference.missing",
                    "Lesson '\(lesson.id)' references missing module '\(lesson.moduleID)'."
                )
            }
            if lesson.order <= 0 {
                error("value.invalid", "Lesson '\(lesson.id)' order must be positive.")
            } else if !ordersByModuleID[lesson.moduleID, default: []].insert(lesson.order).inserted {
                error(
                    "value.duplicateOrder",
                    "Module '\(lesson.moduleID)' contains duplicate lesson order \(lesson.order)."
                )
            }
            if lesson.revision <= 0 {
                error("value.invalid", "Lesson '\(lesson.id)' revision must be positive.")
            }
            if lesson.locale != catalog.locale {
                error(
                    "locale.mismatch",
                    "Lesson '\(lesson.id)' locale '\(lesson.locale)' differs from catalog locale '\(catalog.locale)'."
                )
            }
            if lesson.objectives.isEmpty {
                error("quality.missingObjective", "Lesson '\(lesson.id)' must declare at least one objective.")
            }
            if lesson.blocks.isEmpty {
                error("collection.empty", "Lesson '\(lesson.id)' has no content blocks.")
            }
            validateBlocks(
                lesson.blocks,
                lessonID: lesson.id,
                exercisesByID: exercisesByID,
                referencedExerciseIDs: &referencedExerciseIDs,
                diagnostics: &diagnostics
            )
        }

        for exercise in catalog.exercises {
            if lessonsByID[exercise.lessonID] == nil {
                error(
                    "reference.missing",
                    "Exercise '\(exercise.id)' references missing lesson '\(exercise.lessonID)'."
                )
            }
            if exercise.prompt.map(\.plainText).joined().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                error("value.empty", "Exercise '\(exercise.id)' prompt must not be empty.")
            }
            if exercise.options.count < 2 {
                error("collection.tooSmall", "Exercise '\(exercise.id)' must have at least two options.")
            }
            requireUnique(
                exercise.options.map(\.id),
                kind: "exerciseOption",
                diagnostics: &diagnostics
            )
            if !exercise.options.contains(where: { $0.id == exercise.correctOptionID }) {
                error(
                    "answer.missing",
                    "Exercise '\(exercise.id)' correctOptionID '\(exercise.correctOptionID)' is not an option."
                )
            }
            for option in exercise.options {
                requireValidID(option.id, kind: "exerciseOption", diagnostics: &diagnostics)
                if option.content.map(\.plainText).joined()
                    .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                {
                    error("value.empty", "Exercise '\(exercise.id)' contains an empty option.")
                }
                if let feedback = option.feedback {
                    validateFeedback(
                        feedback,
                        ownerID: "\(exercise.id)' option '\(option.id)",
                        diagnostics: &diagnostics
                    )
                }
            }
            validateFeedback(exercise.correctFeedback, ownerID: exercise.id, diagnostics: &diagnostics)
            validateFeedback(exercise.incorrectFeedback, ownerID: exercise.id, diagnostics: &diagnostics)
            if !referencedExerciseIDs.contains(exercise.id) {
                error("reference.unused", "Exercise '\(exercise.id)' is not referenced by a lesson block.")
            }
        }

        for card in catalog.reviewCards {
            if modulesByID[card.moduleID] == nil {
                error(
                    "reference.missing",
                    "Review card '\(card.id)' references missing module '\(card.moduleID)'."
                )
            }
            if let sourceLessonID = card.sourceLessonID {
                guard let lesson = lessonsByID[sourceLessonID] else {
                    error(
                        "reference.missing",
                        "Review card '\(card.id)' references missing lesson '\(sourceLessonID)'."
                    )
                    continue
                }
                if lesson.moduleID != card.moduleID {
                    error(
                        "reference.inconsistent",
                        "Review card '\(card.id)' lesson and module ownership disagree."
                    )
                }
            }
            if card.revision <= 0 {
                error("value.invalid", "Review card '\(card.id)' revision must be positive.")
            }
            if card.locale != catalog.locale {
                error(
                    "locale.mismatch",
                    "Review card '\(card.id)' locale '\(card.locale)' differs from catalog locale '\(catalog.locale)'."
                )
            }
        }

        for tip in catalog.knowledgeTips {
            if !ContentPolicy.allowedSystemImages.contains(tip.systemImage) {
                error(
                    "symbol.unsupported",
                    "Knowledge tip '\(tip.id)' uses unsupported systemImage '\(tip.systemImage)'."
                )
            }
            if let moduleID = tip.moduleID, modulesByID[moduleID] == nil {
                error(
                    "reference.missing",
                    "Knowledge tip '\(tip.id)' references missing module '\(moduleID)'."
                )
            }
            if let sourceLessonID = tip.sourceLessonID {
                guard let lesson = lessonsByID[sourceLessonID] else {
                    error(
                        "reference.missing",
                        "Knowledge tip '\(tip.id)' references missing lesson '\(sourceLessonID)'."
                    )
                    continue
                }
                if let moduleID = tip.moduleID, lesson.moduleID != moduleID {
                    error(
                        "reference.inconsistent",
                        "Knowledge tip '\(tip.id)' lesson and module ownership disagree."
                    )
                }
            }
            if tip.revision <= 0 {
                error("value.invalid", "Knowledge tip '\(tip.id)' revision must be positive.")
            }
            if tip.locale != catalog.locale {
                error(
                    "locale.mismatch",
                    "Knowledge tip '\(tip.id)' locale '\(tip.locale)' differs from catalog locale '\(catalog.locale)'."
                )
            }
        }

        requireUnique(catalog.retiredIDs, kind: "retiredID", diagnostics: &diagnostics)
        for retiredID in catalog.retiredIDs {
            requireValidID(retiredID, kind: "retiredID", diagnostics: &diagnostics)
        }
        let liveIDs = Set(liveEntityIDs)
        for retiredID in catalog.retiredIDs where liveIDs.contains(retiredID) {
            error("id.retiredAndLive", "ID '\(retiredID)' is both live and retired.")
        }

        return diagnostics
    }

    private static func dictionary<Element>(
        _ elements: [Element],
        kind: String,
        id: KeyPath<Element, String>,
        diagnostics: inout [ContentDiagnostic]
    ) -> [String: Element] {
        var result: [String: Element] = [:]
        for element in elements {
            let value = element[keyPath: id]
            requireValidID(value, kind: kind, diagnostics: &diagnostics)
            if result.updateValue(element, forKey: value) != nil {
                diagnostics.append(
                    ContentDiagnostic(
                        severity: .error,
                        code: "id.duplicate",
                        message: "Duplicate \(kind) ID '\(value)'.",
                        file: "CatalogV2.json"
                    )
                )
            }
        }
        return result
    }

    private static func requireValidID(
        _ id: String,
        kind: String,
        diagnostics: inout [ContentDiagnostic]
    ) {
        let valid = id.range(
            of: #"^[A-Za-z0-9][A-Za-z0-9._-]*$"#,
            options: .regularExpression
        ) != nil
        if !valid {
            diagnostics.append(
                ContentDiagnostic(
                    severity: .error,
                    code: "id.invalid",
                    message: "\(kind) ID '\(id)' must match [A-Za-z0-9][A-Za-z0-9._-]*.",
                    file: "CatalogV2.json"
                )
            )
        }
    }

    private static func requireUnique(
        _ ids: [String],
        kind: String,
        diagnostics: inout [ContentDiagnostic]
    ) {
        var seen: Set<String> = []
        for id in ids where !seen.insert(id).inserted {
            diagnostics.append(
                ContentDiagnostic(
                    severity: .error,
                    code: "id.duplicate",
                    message: "Duplicate \(kind) ID '\(id)'.",
                    file: "CatalogV2.json"
                )
            )
        }
    }

    private static func requireNonempty(
        _ value: String,
        field: String,
        ownerID: String,
        diagnostics: inout [ContentDiagnostic]
    ) {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            diagnostics.append(
                ContentDiagnostic(
                    severity: .error,
                    code: "value.empty",
                    message: "\(field) for '\(ownerID)' must not be empty.",
                    file: "CatalogV2.json"
                )
            )
        }
    }

    private static func validatePrerequisiteGraph(
        _ modules: [ModuleDefinition],
        diagnostics: inout [ContentDiagnostic]
    ) {
        // Duplicate IDs are already reported by `dictionary(_:kind:id:diagnostics:)`.
        // Keep the first definition here so malformed input produces diagnostics
        // instead of trapping in Dictionary(uniqueKeysWithValues:).
        var prerequisites: [String: [String]] = [:]
        for module in modules where prerequisites[module.id] == nil {
            prerequisites[module.id] = module.prerequisiteModuleIDs
        }
        var visited: Set<String> = []
        var visiting: [String] = []

        func visit(_ id: String) {
            if let index = visiting.firstIndex(of: id) {
                let cycle = Array(visiting[index...]) + [id]
                diagnostics.append(
                    ContentDiagnostic(
                        severity: .error,
                        code: "prerequisite.cycle",
                        message: "Prerequisite cycle: \(cycle.joined(separator: " -> ")).",
                        file: "CatalogV2.json"
                    )
                )
                return
            }
            guard !visited.contains(id) else { return }
            visiting.append(id)
            for prerequisiteID in prerequisites[id, default: []] where prerequisites[prerequisiteID] != nil {
                visit(prerequisiteID)
            }
            _ = visiting.popLast()
            visited.insert(id)
        }

        for module in modules {
            visit(module.id)
        }
    }

    private static func validateBlocks(
        _ blocks: [LessonContentBlock],
        lessonID: String,
        exercisesByID: [String: ExerciseDefinition],
        referencedExerciseIDs: inout Set<String>,
        diagnostics: inout [ContentDiagnostic]
    ) {
        for block in blocks {
            switch block {
            case let .paragraph(content):
                if content.map(\.plainText).joined()
                    .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                {
                    diagnostics.append(
                        ContentDiagnostic(
                            severity: .error,
                            code: "value.empty",
                            message: "Lesson '\(lessonID)' contains an empty paragraph.",
                            file: "CatalogV2.json"
                        )
                    )
                }
            case let .heading(level, _):
                if !(1...6).contains(level) {
                    diagnostics.append(
                        ContentDiagnostic(
                            severity: .error,
                            code: "heading.level",
                            message: "Lesson '\(lessonID)' heading level must be 1...6.",
                            file: "CatalogV2.json"
                        )
                    )
                }
            case let .list(_, items):
                if items.isEmpty {
                    diagnostics.append(
                        ContentDiagnostic(
                            severity: .error,
                            code: "collection.empty",
                            message: "Lesson '\(lessonID)' contains an empty list.",
                            file: "CatalogV2.json"
                        )
                    )
                }
            case let .table(header, rows, columnAlignments):
                if header.isEmpty {
                    diagnostics.append(
                        ContentDiagnostic(
                            severity: .error,
                            code: "table.empty",
                            message: "Lesson '\(lessonID)' contains a table without a header.",
                            file: "CatalogV2.json"
                        )
                    )
                } else {
                    let columnCount = header.count
                    for row in rows where row.count != columnCount {
                        diagnostics.append(
                            ContentDiagnostic(
                                severity: .error,
                                code: "table.columnMismatch",
                                message: "Lesson '\(lessonID)' table row has \(row.count) columns; expected \(columnCount).",
                                file: "CatalogV2.json"
                            )
                        )
                    }
                    if let columnAlignments, columnAlignments.count != columnCount {
                        diagnostics.append(
                            ContentDiagnostic(
                                severity: .error,
                                code: "table.alignmentCount",
                                message: "Lesson '\(lessonID)' table columnAlignments has \(columnAlignments.count) entries; expected \(columnCount).",
                                file: "CatalogV2.json"
                            )
                        )
                    }
                }
            case let .callout(_, _, _, body):
                validateBlocks(
                    body,
                    lessonID: lessonID,
                    exercisesByID: exercisesByID,
                    referencedExerciseIDs: &referencedExerciseIDs,
                    diagnostics: &diagnostics
                )
                if body.contains(where: {
                    if case .singleChoice = $0 { return true }
                    return false
                }) {
                    diagnostics.append(
                        ContentDiagnostic(
                            severity: .error,
                            code: "block.invalidNesting",
                            message: "Lesson '\(lessonID)' may not nest an exercise in a callout.",
                            file: "CatalogV2.json"
                        )
                    )
                }
            case let .code(_, code):
                if code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    diagnostics.append(
                        ContentDiagnostic(
                            severity: .error,
                            code: "value.empty",
                            message: "Lesson '\(lessonID)' contains an empty code block.",
                            file: "CatalogV2.json"
                        )
                    )
                }
            case let .image(path, alt, _):
                if !isSafeAssetPath(path) {
                    diagnostics.append(
                        ContentDiagnostic(
                            severity: .error,
                            code: "asset.invalidPath",
                            message: "Lesson '\(lessonID)' image path '\(path)' is not a safe local assets path.",
                            file: "CatalogV2.json"
                        )
                    )
                }
                if alt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    diagnostics.append(
                        ContentDiagnostic(
                            severity: .error,
                            code: "asset.missingAlt",
                            message: "Lesson '\(lessonID)' image '\(path)' requires alt text.",
                            file: "CatalogV2.json"
                        )
                    )
                }
            case let .singleChoice(exerciseID):
                guard let exercise = exercisesByID[exerciseID] else {
                    diagnostics.append(
                        ContentDiagnostic(
                            severity: .error,
                            code: "reference.missing",
                            message: "Lesson '\(lessonID)' references missing exercise '\(exerciseID)'.",
                            file: "CatalogV2.json"
                        )
                    )
                    continue
                }
                if exercise.lessonID != lessonID {
                    diagnostics.append(
                        ContentDiagnostic(
                            severity: .error,
                            code: "reference.inconsistent",
                            message: "Exercise '\(exerciseID)' belongs to '\(exercise.lessonID)', not '\(lessonID)'.",
                            file: "CatalogV2.json"
                        )
                    )
                }
                if !referencedExerciseIDs.insert(exerciseID).inserted {
                    diagnostics.append(
                        ContentDiagnostic(
                            severity: .error,
                            code: "reference.duplicate",
                            message: "Exercise '\(exerciseID)' is referenced more than once.",
                            file: "CatalogV2.json"
                        )
                    )
                }
            }
        }
    }

    private static func validateFeedback(
        _ feedback: FeedbackDefinition,
        ownerID: String,
        diagnostics: inout [ContentDiagnostic]
    ) {
        if feedback.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || feedback.body.map(\.plainText).joined()
                .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        {
            diagnostics.append(
                ContentDiagnostic(
                    severity: .error,
                    code: "feedback.empty",
                    message: "Exercise '\(ownerID)' feedback requires a title and body.",
                    file: "CatalogV2.json"
                )
            )
        }
    }

    public static func isSafeImageAssetPath(_ path: String) -> Bool {
        guard path.hasPrefix("assets/"),
              !path.hasPrefix("/"),
              !path.contains("\\"),
              !path.contains("://"),
              path.range(
                  of: #"^assets/[A-Za-z0-9][A-Za-z0-9._/-]*$"#,
                  options: .regularExpression
              ) != nil
        else {
            return false
        }
        let components = path.split(separator: "/", omittingEmptySubsequences: false)
        guard components.count >= 2,
              !components.contains(where: { $0.isEmpty || $0 == "." || $0 == ".." })
        else {
            return false
        }
        return ContentPolicy.allowedImageExtensions.contains(
            String(path.split(separator: ".").last ?? "").lowercased()
        )
    }

    private static func isSafeAssetPath(_ path: String) -> Bool {
        isSafeImageAssetPath(path)
    }
}
