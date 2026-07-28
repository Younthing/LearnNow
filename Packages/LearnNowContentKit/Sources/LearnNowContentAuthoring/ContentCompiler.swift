import CryptoKit
import Foundation
import LearnNowContentKit
import Markdown
import Yams

public struct ContentCompilationResult: Equatable, Sendable {
    public let catalog: CatalogDocumentV2
    public let minAppBuild: Int
    public let requiredCapabilities: [String]
    public let publishedAt: String
    public let assets: [CompiledAsset]

    public init(
        catalog: CatalogDocumentV2,
        minAppBuild: Int,
        requiredCapabilities: [String],
        publishedAt: String,
        assets: [CompiledAsset]
    ) {
        self.catalog = catalog
        self.minAppBuild = minAppBuild
        self.requiredCapabilities = requiredCapabilities
        self.publishedAt = publishedAt
        self.assets = assets
    }
}

public struct CompiledAsset: Equatable, Sendable {
    public let path: String
    public let data: Data
    public let sha256: String

    public init(path: String, data: Data) {
        self.path = path
        self.data = data
        self.sha256 = ContentDigest.sha256Hex(of: data)
    }
}

public struct ContentBuildArtifacts: Equatable, Sendable {
    public let catalogURL: URL
    public let manifestURL: URL
    public let schemaURL: URL
    public let manifest: ContentManifestV1

    public init(
        catalogURL: URL,
        manifestURL: URL,
        schemaURL: URL,
        manifest: ContentManifestV1
    ) {
        self.catalogURL = catalogURL
        self.manifestURL = manifestURL
        self.schemaURL = schemaURL
        self.manifest = manifest
    }
}

public struct ContentCompiler: Sendable {
    public static let compilerVersion = "2.0.0"
    public static let maximumSourceFileSize = 1_048_576

    public init() {}

    public func lint(
        sourceDirectory: URL,
        includeUnreferenced: Bool = false
    ) -> [ContentDiagnostic] {
        var warnings: [ContentDiagnostic] = []
        do {
            _ = try LessonBundleCompilationEngine().compile(
                sourceDirectory: sourceDirectory,
                includeUnreferenced: includeUnreferenced,
                warnings: &warnings
            )
            return warnings.sorted(by: diagnosticOrder)
        } catch let error as ContentValidationError {
            return (warnings + error.diagnostics).sorted(by: diagnosticOrder)
        } catch {
            return (warnings + [
                ContentDiagnostic(
                    severity: .error,
                    code: "compiler.failure",
                    message: error.localizedDescription,
                    file: sourceDirectory.path
                ),
            ]).sorted(by: diagnosticOrder)
        }
    }

    public func compile(sourceDirectory: URL) throws -> ContentCompilationResult {
        var warnings: [ContentDiagnostic] = []
        return try LessonBundleCompilationEngine().compile(
            sourceDirectory: sourceDirectory,
            includeUnreferenced: false,
            warnings: &warnings
        )
    }

    public func makeManifest(
        for result: ContentCompilationResult
    ) throws -> ContentManifestV1 {
        try makeManifest(
            for: result,
            catalogData: DeterministicJSON.encode(result.catalog)
        )
    }

    @discardableResult
    public func build(sourceDirectory: URL, outputDirectory: URL) throws -> ContentBuildArtifacts {
        let result = try compile(sourceDirectory: sourceDirectory)
        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )
        let outputAssetsURL = outputDirectory.appending(path: "assets")
        if FileManager.default.fileExists(atPath: outputAssetsURL.path) {
            try FileManager.default.removeItem(at: outputAssetsURL)
        }

        let catalogData = try DeterministicJSON.encode(result.catalog)
        let catalogURL = outputDirectory.appending(path: "CatalogV2.json")
        try catalogData.write(to: catalogURL, options: .atomic)

        for asset in result.assets {
            let outputURL = outputDirectory.appending(path: asset.path)
            try FileManager.default.createDirectory(
                at: outputURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try asset.data.write(to: outputURL, options: .atomic)
        }

        let manifest = makeManifest(for: result, catalogData: catalogData)
        let manifestURL = outputDirectory.appending(path: "ContentManifest.json")
        try DeterministicJSON.encode(manifest).write(to: manifestURL, options: .atomic)

        let schemaURL = outputDirectory.appending(path: "CatalogV2.schema.json")
        guard let bundledSchemaURL = Bundle.module.url(
            forResource: "CatalogV2.schema",
            withExtension: "json",
            subdirectory: "Resources"
        ) ?? Bundle.module.url(forResource: "CatalogV2.schema", withExtension: "json") else {
            throw diagnostic(
                code: "schema.missing",
                message: "Bundled CatalogV2 JSON Schema was not found.",
                url: schemaURL,
                relativeTo: outputDirectory,
                line: 1
            )
        }
        try Data(contentsOf: bundledSchemaURL).write(to: schemaURL, options: .atomic)

        return ContentBuildArtifacts(
            catalogURL: catalogURL,
            manifestURL: manifestURL,
            schemaURL: schemaURL,
            manifest: manifest
        )
    }

    @discardableResult
    public func publish(
        sourceDirectory: URL,
        outputDirectory: URL,
        privateKeyRawRepresentation: Data,
        keyID: String
    ) throws -> ContentBuildArtifacts {
        let artifacts = try build(
            sourceDirectory: sourceDirectory,
            outputDirectory: outputDirectory
        )
        let signedManifest = try ContentManifestSigner.sign(
            artifacts.manifest,
            privateKeyRawRepresentation: privateKeyRawRepresentation,
            keyID: keyID
        )
        try DeterministicJSON.encode(signedManifest)
            .write(to: artifacts.manifestURL, options: .atomic)
        return ContentBuildArtifacts(
            catalogURL: artifacts.catalogURL,
            manifestURL: artifacts.manifestURL,
            schemaURL: artifacts.schemaURL,
            manifest: signedManifest
        )
    }

    private func makeManifest(
        for result: ContentCompilationResult,
        catalogData: Data
    ) -> ContentManifestV1 {
        var files = [
            ContentManifestFile(
                path: "CatalogV2.json",
                size: catalogData.count,
                sha256: ContentDigest.sha256Hex(of: catalogData)
            ),
        ]
        files.append(
            contentsOf: result.assets.map {
                ContentManifestFile(
                    path: $0.path,
                    size: $0.data.count,
                    sha256: $0.sha256
                )
            }
        )
        files.sort { $0.path < $1.path }

        return ContentManifestV1(
            releaseVersion: result.catalog.releaseVersion,
            compilerVersion: Self.compilerVersion,
            locale: result.catalog.locale,
            minAppBuild: result.minAppBuild,
            requiredCapabilities: result.requiredCapabilities,
            publishedAt: result.publishedAt,
            files: files,
            retiredIDs: result.catalog.retiredIDs
        )
    }

}

private struct LessonBundleCompilationEngine {
    private struct SourceAsset {
        let outputPath: String
        let sourceURL: URL
    }

    private struct ParsedBundle {
        let module: ModuleDefinition
        let lessons: [LessonDefinition]
        let exercises: [ExerciseDefinition]
        let cards: [ReviewCardDefinition]
        let tips: [KnowledgeTipDefinition]
        let assets: [SourceAsset]
        let locations: [String: (file: String, line: Int)]
    }

    func compile(
        sourceDirectory: URL,
        includeUnreferenced: Bool,
        warnings: inout [ContentDiagnostic]
    ) throws -> ContentCompilationResult {
        let projectURL = sourceDirectory.appending(path: "learnnow.yml")
        let project: LessonBundleProjectSource = try decodeStrictYAML(
            at: projectURL,
            relativeTo: sourceDirectory,
            schema: .project
        )

        guard project.format == "learnnow.project/v1" else {
            throw diagnostic(
                code: "format.unsupported",
                message: "Expected format learnnow.project/v1.",
                url: projectURL,
                relativeTo: sourceDirectory,
                line: 1
            )
        }
        guard project.schemaVersion == CatalogDocumentV2.currentSchemaVersion else {
            throw diagnostic(
                code: "schema.unsupported",
                message: "schemaVersion must be \(CatalogDocumentV2.currentSchemaVersion).",
                url: projectURL,
                relativeTo: sourceDirectory,
                line: line(ofKey: "schemaVersion", in: try readAuthorText(projectURL))
            )
        }
        guard ContentReleaseVersion(project.releaseVersion) != nil else {
            throw diagnostic(
                code: "release.invalid",
                message: "releaseVersion must contain only dot-separated UInt64 decimal components.",
                url: projectURL,
                relativeTo: sourceDirectory,
                line: line(ofKey: "releaseVersion", in: try readAuthorText(projectURL))
            )
        }
        guard !project.locale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw diagnostic(
                code: "value.empty",
                message: "locale must not be empty.",
                url: projectURL,
                relativeTo: sourceDirectory,
                line: line(ofKey: "locale", in: try readAuthorText(projectURL))
            )
        }
        guard project.minAppBuild > 0 else {
            throw diagnostic(
                code: "value.invalid",
                message: "minAppBuild must be positive.",
                url: projectURL,
                relativeTo: sourceDirectory,
                line: line(ofKey: "minAppBuild", in: try readAuthorText(projectURL))
            )
        }
        guard ISO8601DateFormatter().date(from: project.publishedAt) != nil else {
            throw diagnostic(
                code: "date.invalid",
                message: "publishedAt must be an RFC 3339 timestamp.",
                url: projectURL,
                relativeTo: sourceDirectory,
                line: line(ofKey: "publishedAt", in: try readAuthorText(projectURL))
            )
        }

        let projectDefaults = try mergeDefaults(
            parent: LessonBundleDefaults(locale: project.locale),
            child: project.defaults,
            projectLocale: project.locale,
            url: projectURL,
            sourceRoot: sourceDirectory
        )

        var routes: [RouteDefinition] = []
        var tracks: [TrackDefinition] = []
        var modules: [ModuleDefinition] = []
        var lessons: [LessonDefinition] = []
        var exercises: [ExerciseDefinition] = []
        var cards: [ReviewCardDefinition] = []
        var tips: [KnowledgeTipDefinition] = []
        var sourceAssets: [SourceAsset] = []
        var sourceLocationByID: [String: (file: String, line: Int)] = [:]
        var referencedManifestPaths: Set<String> = []
        let projectText = try readAuthorText(projectURL)

        for routeSource in project.routes {
            let routeDefaults = try mergeDefaults(
                parent: projectDefaults,
                child: routeSource.defaults,
                projectLocale: project.locale,
                url: projectURL,
                sourceRoot: sourceDirectory,
                line: line(of: "id: \(routeSource.id)", in: projectText)
            )
            var routeTrackIDs: [String] = []
            var routeModuleIDs: [String] = []
            sourceLocationByID[routeSource.id] = (
                relativePath(projectURL, to: sourceDirectory),
                line(of: "id: \(routeSource.id)", in: projectText)
            )

            for trackSource in routeSource.tracks {
                let trackDefaults = try mergeDefaults(
                    parent: routeDefaults,
                    child: trackSource.defaults,
                    projectLocale: project.locale,
                    url: projectURL,
                    sourceRoot: sourceDirectory,
                    line: line(of: "id: \(trackSource.id)", in: projectText)
                )
                routeTrackIDs.append(trackSource.id)
                tracks.append(TrackDefinition(id: trackSource.id, title: trackSource.title))
                sourceLocationByID[trackSource.id] = (
                    relativePath(projectURL, to: sourceDirectory),
                    line(of: "id: \(trackSource.id)", in: projectText)
                )

                for manifestPath in trackSource.lessons {
                    let manifestURL = try resolveAuthorFile(
                        manifestPath,
                        relativeTo: sourceDirectory,
                        boundary: sourceDirectory,
                        sourceRoot: sourceDirectory
                    )
                    let canonicalPath = relativePath(
                        manifestURL.standardizedFileURL,
                        to: sourceDirectory.standardizedFileURL
                    )
                    guard referencedManifestPaths.insert(canonicalPath).inserted else {
                        throw diagnostic(
                            code: "lesson.duplicateMount",
                            message: "Lesson manifest '\(manifestPath)' is mounted more than once.",
                            url: projectURL,
                            relativeTo: sourceDirectory,
                            line: line(of: manifestPath, in: projectText)
                        )
                    }
                    let bundle = try parseBundle(
                        manifestURL: manifestURL,
                        trackID: trackSource.id,
                        inheritedDefaults: trackDefaults,
                        projectLocale: project.locale,
                        sourceRoot: sourceDirectory,
                        warnings: &warnings
                    )
                    routeModuleIDs.append(bundle.module.id)
                    modules.append(bundle.module)
                    lessons.append(contentsOf: bundle.lessons)
                    exercises.append(contentsOf: bundle.exercises)
                    cards.append(contentsOf: bundle.cards)
                    tips.append(contentsOf: bundle.tips)
                    sourceAssets.append(contentsOf: bundle.assets)
                    for (id, location) in bundle.locations where sourceLocationByID[id] == nil {
                        sourceLocationByID[id] = location
                    }
                }
            }

            routes.append(
                RouteDefinition(
                    id: routeSource.id,
                    title: routeSource.title,
                    subtitle: routeSource.subtitle,
                    systemImage: routeSource.systemImage,
                    accent: routeSource.accent,
                    cta: routeSource.cta,
                    interactive: routeSource.interactive,
                    trackIDs: routeTrackIDs,
                    moduleIDs: routeModuleIDs
                )
            )
        }

        for path in project.globalTips ?? [] {
            let url = try resolveAuthorFile(
                path,
                relativeTo: sourceDirectory,
                boundary: sourceDirectory,
                sourceRoot: sourceDirectory
            )
            let parsed = try parseTips(
                at: url,
                moduleID: nil,
                pageIDs: [],
                defaults: projectDefaults,
                projectLocale: project.locale,
                sourceRoot: sourceDirectory
            )
            tips.append(contentsOf: parsed.items)
            for (id, location) in parsed.locations where sourceLocationByID[id] == nil {
                sourceLocationByID[id] = location
            }
        }

        let catalog = CatalogDocumentV2(
            releaseVersion: project.releaseVersion,
            locale: project.locale,
            primaryRouteID: project.primaryRouteID,
            tracks: tracks,
            routes: routes,
            modules: modules,
            lessons: lessons,
            exercises: exercises,
            reviewCards: cards,
            knowledgeTips: tips,
            retiredIDs: (project.retiredIDs ?? []).sorted()
        )

        let semanticDiagnostics = CatalogSemanticValidator.validate(catalog).map {
            remap($0, using: sourceLocationByID)
        }
        if semanticDiagnostics.contains(where: { $0.severity == .error }) {
            throw ContentValidationError(
                diagnostics: semanticDiagnostics.sorted(by: diagnosticOrder)
            )
        }

        if includeUnreferenced {
            let draftBundles = try lintUnreferencedBundles(
                below: sourceDirectory,
                excluding: referencedManifestPaths,
                inheritedDefaults: projectDefaults,
                projectLocale: project.locale,
                warnings: &warnings
            )
            try validateUnreferencedBundles(
                draftBundles,
                against: catalog,
                publishedLocations: sourceLocationByID
            )
            _ = try compileAssets(
                sourceAssets + draftBundles.flatMap(\.assets),
                sourceRoot: sourceDirectory
            )
        }

        let assets = try compileAssets(
            sourceAssets,
            sourceRoot: sourceDirectory
        )
        let requiredCapabilities = ContentCapabilityAnalyzer
            .requiredCapabilities(for: catalog)
            .sorted()
        return ContentCompilationResult(
            catalog: catalog,
            minAppBuild: project.minAppBuild,
            requiredCapabilities: requiredCapabilities,
            publishedAt: project.publishedAt,
            assets: assets
        )
    }

    private func parseBundle(
        manifestURL: URL,
        trackID: String,
        inheritedDefaults: LessonBundleDefaults,
        projectLocale: String,
        sourceRoot: URL,
        warnings: inout [ContentDiagnostic]
    ) throws -> ParsedBundle {
        let source: LessonBundleSource = try decodeStrictYAML(
            at: manifestURL,
            relativeTo: sourceRoot,
            schema: .lesson
        )
        let manifestText = try readAuthorText(manifestURL)
        guard source.format == "learnnow.lesson-bundle/v1" else {
            throw diagnostic(
                code: "format.unsupported",
                message: "Expected format learnnow.lesson-bundle/v1.",
                url: manifestURL,
                relativeTo: sourceRoot,
                line: 1
            )
        }
        let defaults = try mergeDefaults(
            parent: inheritedDefaults,
            child: source.defaults,
            projectLocale: projectLocale,
            url: manifestURL,
            sourceRoot: sourceRoot,
            line: line(ofKey: "id", in: manifestText)
        )
        let bundleDirectory = manifestURL.deletingLastPathComponent()
        let cardSources = source.cards ?? []
        let tipSources = source.tips ?? []

        var lessons: [LessonDefinition] = []
        var exercises: [ExerciseDefinition] = []
        var assets: [SourceAsset] = []
        var locations: [String: (file: String, line: Int)] = [
            source.id: (
                relativePath(manifestURL, to: sourceRoot),
                line(ofKey: "id", in: manifestText)
            ),
        ]
        let pageIDs = Set(source.pages.map(\.id))

        for (index, page) in source.pages.enumerated() {
            let pageURL = try resolveAuthorFile(
                page.source,
                relativeTo: bundleDirectory,
                boundary: bundleDirectory,
                sourceRoot: sourceRoot
            )
            let pageText = try readAuthorText(pageURL)
            try rejectFrontMatter(
                in: pageText,
                url: pageURL,
                sourceRoot: sourceRoot
            )
            let pageLocale = try resolvedLocale(
                page.locale ?? defaults.locale,
                projectLocale: projectLocale,
                url: manifestURL,
                sourceRoot: sourceRoot,
                line: line(of: "id: \(page.id)", in: manifestText)
            )
            guard let accent = page.accent ?? defaults.page?.accent else {
                throw diagnostic(
                    code: "value.missing",
                    message: "Page '\(page.id)' requires accent or an inherited page accent.",
                    url: manifestURL,
                    relativeTo: sourceRoot,
                    line: line(of: "id: \(page.id)", in: manifestText)
                )
            }
            let document = Document(
                parsing: pageText,
                source: pageURL,
                options: .parseBlockDirectives
            )
            var pageExercises: [ExerciseDefinition] = []
            let parsedBlocks = try parseBlocks(
                document.children,
                lessonID: page.id,
                url: pageURL,
                sourceRoot: sourceRoot,
                exercises: &pageExercises
            )
            let rewritten = try rewriteImages(
                in: parsedBlocks,
                lessonID: source.id,
                bundleDirectory: bundleDirectory,
                sourceRoot: sourceRoot,
                sourceURL: pageURL
            )
            lessons.append(
                LessonDefinition(
                    id: page.id,
                    moduleID: source.id,
                    order: index + 1,
                    title: page.title,
                    accent: accent,
                    revision: page.revision,
                    locale: pageLocale,
                    objectives: page.objectives,
                    blocks: rewritten.blocks
                )
            )
            exercises.append(contentsOf: pageExercises)
            assets.append(contentsOf: rewritten.assets)
            locations[page.id] = (
                relativePath(manifestURL, to: sourceRoot),
                line(of: "id: \(page.id)", in: manifestText)
            )
            for exercise in pageExercises {
                locations[exercise.id] = (
                    relativePath(pageURL, to: sourceRoot),
                    line(of: "@Quiz", in: pageText)
                )
            }
        }

        var cards: [ReviewCardDefinition] = []
        for path in cardSources {
            let url = try resolveAuthorFile(
                path,
                relativeTo: bundleDirectory,
                boundary: bundleDirectory,
                sourceRoot: sourceRoot
            )
            let parsed = try parseCards(
                at: url,
                moduleID: source.id,
                pageIDs: pageIDs,
                defaults: defaults,
                projectLocale: projectLocale,
                sourceRoot: sourceRoot
            )
            cards.append(contentsOf: parsed.items)
            locations.merge(parsed.locations) { current, _ in current }
        }

        var tips: [KnowledgeTipDefinition] = []
        for path in tipSources {
            let url = try resolveAuthorFile(
                path,
                relativeTo: bundleDirectory,
                boundary: bundleDirectory,
                sourceRoot: sourceRoot
            )
            let parsed = try parseTips(
                at: url,
                moduleID: source.id,
                pageIDs: pageIDs,
                defaults: defaults,
                projectLocale: projectLocale,
                sourceRoot: sourceRoot
            )
            tips.append(contentsOf: parsed.items)
            locations.merge(parsed.locations) { current, _ in current }
        }
        if cards.isEmpty {
            warnings.append(
                ContentDiagnostic(
                    severity: .warning,
                    code: "lesson.missingCards",
                    message: "Lesson '\(source.id)' has no review cards.",
                    file: relativePath(manifestURL, to: sourceRoot),
                    line: line(ofKey: "id", in: manifestText)
                )
            )
        }
        if tips.isEmpty {
            warnings.append(
                ContentDiagnostic(
                    severity: .warning,
                    code: "lesson.missingTips",
                    message: "Lesson '\(source.id)' has no tips.",
                    file: relativePath(manifestURL, to: sourceRoot),
                    line: line(ofKey: "id", in: manifestText)
                )
            )
        }

        return ParsedBundle(
            module: ModuleDefinition(
                id: source.id,
                trackID: trackID,
                title: source.title,
                subtitle: "\(source.pages.count) 个小节",
                lessonTitle: source.title,
                prerequisiteModuleIDs: source.prerequisites,
                completionXP: source.completion.xp,
                reviewMessage: source.completion.message
            ),
            lessons: lessons,
            exercises: exercises,
            cards: cards,
            tips: tips,
            assets: assets,
            locations: locations
        )
    }

    private func parseCards(
        at url: URL,
        moduleID: String,
        pageIDs: Set<String>,
        defaults: LessonBundleDefaults,
        projectLocale: String,
        sourceRoot: URL
    ) throws -> (
        items: [ReviewCardDefinition],
        locations: [String: (file: String, line: Int)]
    ) {
        let source = try readAuthorText(url)
        try rejectFrontMatter(in: source, url: url, sourceRoot: sourceRoot)
        let document = Document(
            parsing: source,
            source: url,
            options: .parseBlockDirectives
        )
        var cards: [ReviewCardDefinition] = []
        var locations: [String: (file: String, line: Int)] = [:]
        for child in document.children {
            guard let directive = child as? BlockDirective, directive.name == "Card" else {
                throw markupDiagnostic(
                    code: "block.unsupported",
                    message: "Card source files support top-level @Card directives only.",
                    markup: child,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
            let parsed = try parseCardDirective(
                directive,
                moduleID: moduleID,
                pageIDs: pageIDs,
                defaults: defaults,
                projectLocale: projectLocale,
                url: url,
                sourceRoot: sourceRoot
            )
            cards.append(parsed)
            locations[parsed.id] = (
                relativePath(url, to: sourceRoot),
                directive.range?.lowerBound.line ?? 1
            )
        }
        return (cards, locations)
    }

    private func parseCardDirective(
        _ directive: BlockDirective,
        moduleID: String,
        pageIDs: Set<String>,
        defaults: LessonBundleDefaults,
        projectLocale: String,
        url: URL,
        sourceRoot: URL
    ) throws -> ReviewCardDefinition {
        let arguments = try directiveArguments(
            directive,
            allowed: [
                "id", "revision", "sourcePage", "locale", "topic", "accent",
                "frontTitle", "frontSubtitle", "backTitle",
            ],
            required: ["id", "revision", "frontTitle", "backTitle"],
            url: url,
            sourceRoot: sourceRoot
        )
        let revision = try positiveRevision(
            arguments["revision"]!,
            directive: directive,
            url: url,
            sourceRoot: sourceRoot
        )
        let locale = try resolvedLocale(
            arguments["locale"] ?? defaults.locale,
            projectLocale: projectLocale,
            url: url,
            sourceRoot: sourceRoot,
            line: directive.range?.lowerBound.line ?? 1
        )
        guard let topic = arguments["topic"] ?? defaults.card?.topic,
              !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            throw markupDiagnostic(
                code: "value.missing",
                message: "@Card requires topic or an inherited card topic.",
                markup: directive,
                url: url,
                sourceRoot: sourceRoot
            )
        }
        guard let accentText = arguments["accent"]
            ?? defaults.card?.accent?.rawValue,
            let accent = ContentAccent(rawValue: accentText)
        else {
            throw markupDiagnostic(
                code: "directive.invalidArgument",
                message: "@Card requires a supported accent or an inherited card accent.",
                markup: directive,
                url: url,
                sourceRoot: sourceRoot
            )
        }
        let sourcePage = arguments["sourcePage"]
        if let sourcePage, !pageIDs.contains(sourcePage) {
            throw markupDiagnostic(
                code: "reference.missing",
                message: "@Card references missing sourcePage '\(sourcePage)'.",
                markup: directive,
                url: url,
                sourceRoot: sourceRoot
            )
        }

        var body: [InlineContent] = []
        var highlight: [InlineContent]?
        for child in directive.children {
            if let paragraph = child as? Paragraph {
                appendParagraph(
                    try parseInline(paragraph, url: url, sourceRoot: sourceRoot),
                    to: &body
                )
            } else if let nested = child as? BlockDirective,
                      nested.name == "Highlight"
            {
                guard highlight == nil else {
                    throw markupDiagnostic(
                        code: "directive.duplicate",
                        message: "@Card accepts only one @Highlight.",
                        markup: nested,
                        url: url,
                        sourceRoot: sourceRoot
                    )
                }
                highlight = try parseInlineBody(
                    nested,
                    url: url,
                    sourceRoot: sourceRoot
                )
            } else {
                throw markupDiagnostic(
                    code: "block.unsupported",
                    message: "@Card supports paragraphs and one @Highlight only.",
                    markup: child,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
        }
        guard !body.isEmpty, let highlight, !highlight.isEmpty else {
            throw markupDiagnostic(
                code: "card.incomplete",
                message: "@Card body and @Highlight are required.",
                markup: directive,
                url: url,
                sourceRoot: sourceRoot
            )
        }
        return ReviewCardDefinition(
            id: arguments["id"]!,
            moduleID: moduleID,
            sourceLessonID: sourcePage,
            revision: revision,
            locale: locale,
            topic: topic,
            accent: accent,
            frontTitle: arguments["frontTitle"]!,
            frontSubtitle: arguments["frontSubtitle"],
            backTitle: arguments["backTitle"]!,
            backBody: body,
            backHighlight: highlight
        )
    }

    private func parseTips(
        at url: URL,
        moduleID: String?,
        pageIDs: Set<String>,
        defaults: LessonBundleDefaults,
        projectLocale: String,
        sourceRoot: URL
    ) throws -> (
        items: [KnowledgeTipDefinition],
        locations: [String: (file: String, line: Int)]
    ) {
        let source = try readAuthorText(url)
        try rejectFrontMatter(in: source, url: url, sourceRoot: sourceRoot)
        let document = Document(
            parsing: source,
            source: url,
            options: .parseBlockDirectives
        )
        var tips: [KnowledgeTipDefinition] = []
        var locations: [String: (file: String, line: Int)] = [:]
        for child in document.children {
            guard let directive = child as? BlockDirective, directive.name == "Tip" else {
                throw markupDiagnostic(
                    code: "block.unsupported",
                    message: "Tip source files support top-level @Tip directives only.",
                    markup: child,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
            let arguments = try directiveArguments(
                directive,
                allowed: [
                    "id", "revision", "sourcePage", "locale", "title",
                    "systemImage", "accent",
                ],
                required: ["id", "revision", "title"],
                url: url,
                sourceRoot: sourceRoot
            )
            if moduleID == nil, arguments["sourcePage"] != nil {
                throw markupDiagnostic(
                    code: "reference.invalid",
                    message: "A global @Tip may not declare sourcePage.",
                    markup: directive,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
            let sourcePage = arguments["sourcePage"]
            if let sourcePage, !pageIDs.contains(sourcePage) {
                throw markupDiagnostic(
                    code: "reference.missing",
                    message: "@Tip references missing sourcePage '\(sourcePage)'.",
                    markup: directive,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
            let revision = try positiveRevision(
                arguments["revision"]!,
                directive: directive,
                url: url,
                sourceRoot: sourceRoot
            )
            let locale = try resolvedLocale(
                arguments["locale"] ?? defaults.locale,
                projectLocale: projectLocale,
                url: url,
                sourceRoot: sourceRoot,
                line: directive.range?.lowerBound.line ?? 1
            )
            guard let systemImage = arguments["systemImage"]
                ?? defaults.tip?.systemImage,
                !systemImage.isEmpty
            else {
                throw markupDiagnostic(
                    code: "value.missing",
                    message: "@Tip requires systemImage or an inherited tip systemImage.",
                    markup: directive,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
            guard let accentText = arguments["accent"]
                ?? defaults.tip?.accent?.rawValue,
                let accent = ContentAccent(rawValue: accentText)
            else {
                throw markupDiagnostic(
                    code: "directive.invalidArgument",
                    message: "@Tip requires a supported accent or an inherited tip accent.",
                    markup: directive,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
            let body = try parseInlineBody(
                directive,
                url: url,
                sourceRoot: sourceRoot
            )
            guard !body.isEmpty else {
                throw markupDiagnostic(
                    code: "tip.incomplete",
                    message: "@Tip body is required.",
                    markup: directive,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
            let item = KnowledgeTipDefinition(
                id: arguments["id"]!,
                moduleID: moduleID,
                sourceLessonID: sourcePage,
                revision: revision,
                locale: locale,
                title: arguments["title"]!,
                body: body,
                systemImage: systemImage,
                accent: accent
            )
            tips.append(item)
            locations[item.id] = (
                relativePath(url, to: sourceRoot),
                directive.range?.lowerBound.line ?? 1
            )
        }
        return (tips, locations)
    }

    private func rewriteImages(
        in blocks: [LessonContentBlock],
        lessonID: String,
        bundleDirectory: URL,
        sourceRoot: URL,
        sourceURL: URL
    ) throws -> (blocks: [LessonContentBlock], assets: [SourceAsset]) {
        var rewritten: [LessonContentBlock] = []
        var assets: [SourceAsset] = []
        for block in blocks {
            switch block {
            case let .callout(title, tone, accent, body):
                let nested = try rewriteImages(
                    in: body,
                    lessonID: lessonID,
                    bundleDirectory: bundleDirectory,
                    sourceRoot: sourceRoot,
                    sourceURL: sourceURL
                )
                rewritten.append(
                    .callout(
                        title: title,
                        tone: tone,
                        accent: accent,
                        body: nested.blocks
                    )
                )
                assets.append(contentsOf: nested.assets)
            case let .image(path, alt, caption):
                let sourceAssetURL = try resolveAuthorFile(
                    path,
                    relativeTo: bundleDirectory,
                    boundary: bundleDirectory,
                    sourceRoot: sourceRoot
                )
                guard ContentPolicy.allowedImageExtensions.contains(
                    sourceAssetURL.pathExtension.lowercased()
                ) else {
                    throw diagnostic(
                        code: "asset.invalidExtension",
                        message: "Image '\(path)' uses an unsupported extension.",
                        url: sourceURL,
                        relativeTo: sourceRoot,
                        line: 1
                    )
                }
                let outputPath = "assets/\(lessonID)/\(path)"
                guard CatalogSemanticValidator.isSafeImageAssetPath(outputPath) else {
                    throw diagnostic(
                        code: "asset.invalidPath",
                        message: "Image '\(path)' cannot be represented as a safe bundle asset path.",
                        url: sourceURL,
                        relativeTo: sourceRoot,
                        line: 1
                    )
                }
                rewritten.append(
                    .image(path: outputPath, alt: alt, caption: caption)
                )
                assets.append(
                    SourceAsset(outputPath: outputPath, sourceURL: sourceAssetURL)
                )
            default:
                rewritten.append(block)
            }
        }
        return (rewritten, assets)
    }

    private func compileAssets(
        _ sourceAssets: [SourceAsset],
        sourceRoot: URL
    ) throws -> [CompiledAsset] {
        var sourceByOutputPath: [String: URL] = [:]
        var outputPathByCollisionKey: [String: String] = [:]
        for asset in sourceAssets {
            let collisionKey = asset.outputPath
                .precomposedStringWithCanonicalMapping
                .lowercased()
            if let existingPath = outputPathByCollisionKey[collisionKey],
               existingPath != asset.outputPath
            {
                throw diagnostic(
                    code: "asset.collision",
                    message: "Asset output paths '\(existingPath)' and '\(asset.outputPath)' collide on case-insensitive filesystems.",
                    url: asset.sourceURL,
                    relativeTo: sourceRoot,
                    line: 1
                )
            }
            outputPathByCollisionKey[collisionKey] = asset.outputPath
            if let existing = sourceByOutputPath[asset.outputPath],
               existing.standardizedFileURL != asset.sourceURL.standardizedFileURL
            {
                throw diagnostic(
                    code: "asset.collision",
                    message: "Multiple source files map to '\(asset.outputPath)'.",
                    url: asset.sourceURL,
                    relativeTo: sourceRoot,
                    line: 1
                )
            }
            sourceByOutputPath[asset.outputPath] = asset.sourceURL
        }

        var result: [CompiledAsset] = []
        for path in sourceByOutputPath.keys.sorted() {
            guard let url = sourceByOutputPath[path] else { continue }
            let values = try url.resourceValues(
                forKeys: [.fileSizeKey, .isRegularFileKey, .isSymbolicLinkKey]
            )
            guard values.isRegularFile == true, values.isSymbolicLink != true else {
                throw diagnostic(
                    code: "asset.invalidFile",
                    message: "Image must be a regular, non-symbolic-link file.",
                    url: url,
                    relativeTo: sourceRoot,
                    line: 1
                )
            }
            guard let size = values.fileSize,
                  size > 0,
                  size <= ContentPolicy.maximumImageAssetSize
            else {
                throw diagnostic(
                    code: "asset.invalidSize",
                    message: "Image must be 1...\(ContentPolicy.maximumImageAssetSize) bytes.",
                    url: url,
                    relativeTo: sourceRoot,
                    line: 1
                )
            }
            let data = try Data(contentsOf: url)
            guard isValidImageSignature(
                data,
                extension: url.pathExtension.lowercased()
            ) else {
                throw diagnostic(
                    code: "asset.invalidSignature",
                    message: "Image does not match its file extension.",
                    url: url,
                    relativeTo: sourceRoot,
                    line: 1
                )
            }
            result.append(CompiledAsset(path: path, data: data))
        }
        return result
    }

    private func lintUnreferencedBundles(
        below sourceRoot: URL,
        excluding referencedPaths: Set<String>,
        inheritedDefaults: LessonBundleDefaults,
        projectLocale: String,
        warnings: inout [ContentDiagnostic]
    ) throws -> [ParsedBundle] {
        var bundles: [ParsedBundle] = []
        let projectURL = sourceRoot.appending(path: "learnnow.yml").standardizedFileURL
        for url in try recursiveSourceFiles(below: sourceRoot, extensions: ["yaml", "yml"]) {
            let relative = relativePath(url.standardizedFileURL, to: sourceRoot.standardizedFileURL)
            guard !referencedPaths.contains(relative),
                  url.standardizedFileURL != projectURL,
                  try topLevelYAMLFormat(at: url, sourceRoot: sourceRoot)
                    == "learnnow.lesson-bundle/v1"
            else {
                continue
            }
            let text = try readAuthorText(url)
            warnings.append(
                ContentDiagnostic(
                    severity: .warning,
                    code: "lesson.unreferenced",
                    message: "Lesson bundle '\(relative)' is not referenced by learnnow.yml.",
                    file: relative,
                    line: line(ofKey: "format", in: text)
                )
            )
            var draftWarnings: [ContentDiagnostic] = []
            let bundle = try parseBundle(
                manifestURL: url,
                trackID: "__draft__",
                inheritedDefaults: inheritedDefaults,
                projectLocale: projectLocale,
                sourceRoot: sourceRoot,
                warnings: &draftWarnings
            )
            warnings.append(contentsOf: draftWarnings)
            bundles.append(bundle)
        }
        return bundles
    }

    private func validateUnreferencedBundles(
        _ bundles: [ParsedBundle],
        against publishedCatalog: CatalogDocumentV2,
        publishedLocations: [String: (file: String, line: Int)]
    ) throws {
        guard !bundles.isEmpty else { return }

        var occupiedIDs = Set(publishedCatalog.retiredIDs)
        occupiedIDs.formUnion(publishedCatalog.tracks.map(\.id))
        occupiedIDs.formUnion(publishedCatalog.routes.map(\.id))
        occupiedIDs.formUnion(publishedCatalog.modules.map(\.id))
        occupiedIDs.formUnion(publishedCatalog.lessons.map(\.id))
        occupiedIDs.formUnion(publishedCatalog.exercises.map(\.id))
        occupiedIDs.formUnion(
            publishedCatalog.exercises.flatMap { $0.options.map(\.id) }
        )
        occupiedIDs.formUnion(publishedCatalog.reviewCards.map(\.id))
        occupiedIDs.formUnion(publishedCatalog.knowledgeTips.map(\.id))
        for bundle in bundles {
            occupiedIDs.insert(bundle.module.id)
            occupiedIDs.formUnion(bundle.lessons.map(\.id))
            occupiedIDs.formUnion(bundle.exercises.map(\.id))
            occupiedIDs.formUnion(bundle.exercises.flatMap { $0.options.map(\.id) })
            occupiedIDs.formUnion(bundle.cards.map(\.id))
            occupiedIDs.formUnion(bundle.tips.map(\.id))
        }
        let trackID = availableSyntheticID(
            startingWith: "learnnow-lint-draft-track",
            excluding: &occupiedIDs
        )
        let routeID = availableSyntheticID(
            startingWith: "learnnow-lint-draft-route",
            excluding: &occupiedIDs
        )

        let draftModules = bundles.map { bundle in
            ModuleDefinition(
                id: bundle.module.id,
                trackID: trackID,
                title: bundle.module.title,
                subtitle: bundle.module.subtitle,
                lessonTitle: bundle.module.lessonTitle,
                prerequisiteModuleIDs: bundle.module.prerequisiteModuleIDs,
                completionXP: bundle.module.completionXP,
                reviewMessage: bundle.module.reviewMessage
            )
        }
        let combinedCatalog = CatalogDocumentV2(
            releaseVersion: publishedCatalog.releaseVersion,
            locale: publishedCatalog.locale,
            primaryRouteID: publishedCatalog.primaryRouteID,
            tracks: publishedCatalog.tracks + [
                TrackDefinition(id: trackID, title: "Unreferenced lessons"),
            ],
            routes: publishedCatalog.routes + [
                RouteDefinition(
                    id: routeID,
                    title: "Unreferenced lessons",
                    subtitle: "Lint-only draft route",
                    systemImage: "cpu",
                    accent: .blue,
                    cta: "Preview",
                    interactive: false,
                    trackIDs: [trackID],
                    moduleIDs: draftModules.map(\.id)
                ),
            ],
            modules: publishedCatalog.modules + draftModules,
            lessons: publishedCatalog.lessons + bundles.flatMap(\.lessons),
            exercises: publishedCatalog.exercises + bundles.flatMap(\.exercises),
            reviewCards: publishedCatalog.reviewCards + bundles.flatMap(\.cards),
            knowledgeTips: publishedCatalog.knowledgeTips + bundles.flatMap(\.tips),
            retiredIDs: publishedCatalog.retiredIDs
        )
        var locations = publishedLocations
        for bundle in bundles {
            for (id, location) in bundle.locations where locations[id] == nil {
                locations[id] = location
            }
        }
        let diagnostics = CatalogSemanticValidator.validate(combinedCatalog)
            .filter { $0.severity == .error }
            .map { remap($0, using: locations) }
            .sorted(by: diagnosticOrder)
        if !diagnostics.isEmpty {
            throw ContentValidationError(diagnostics: diagnostics)
        }
    }

    private func availableSyntheticID(
        startingWith base: String,
        excluding occupied: inout Set<String>
    ) -> String {
        var candidate = base
        var suffix = 2
        while occupied.contains(candidate) {
            candidate = "\(base)-\(suffix)"
            suffix += 1
        }
        occupied.insert(candidate)
        return candidate
    }
}

private struct LessonBundleProjectSource: Decodable {
    let format: String
    let schemaVersion: Int
    let releaseVersion: String
    let locale: String
    let primaryRouteID: String
    let minAppBuild: Int
    let publishedAt: String
    let retiredIDs: [String]?
    let defaults: LessonBundleDefaults?
    let routes: [LessonBundleRouteSource]
    let globalTips: [String]?
}

private struct LessonBundleRouteSource: Decodable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let accent: ContentAccent
    let cta: String
    let interactive: Bool
    let defaults: LessonBundleDefaults?
    let tracks: [LessonBundleTrackSource]
}

private struct LessonBundleTrackSource: Decodable {
    let id: String
    let title: String
    let defaults: LessonBundleDefaults?
    let lessons: [String]
}

private struct LessonBundleSource: Decodable {
    let format: String
    let id: String
    let title: String
    let prerequisites: [String]
    let completion: LessonBundleCompletionSource
    let defaults: LessonBundleDefaults?
    let pages: [LessonBundlePageSource]
    let cards: [String]?
    let tips: [String]?
}

private struct LessonBundleCompletionSource: Decodable {
    let xp: Int
    let message: String
}

private struct LessonBundlePageSource: Decodable {
    let id: String
    let title: String
    let source: String
    let accent: ContentAccent?
    let revision: Int
    let locale: String?
    let objectives: [String]
}

private struct LessonBundleDefaults: Decodable {
    let locale: String?
    let page: LessonBundlePageDefaults?
    let card: LessonBundleCardDefaults?
    let tip: LessonBundleTipDefaults?

    init(
        locale: String? = nil,
        page: LessonBundlePageDefaults? = nil,
        card: LessonBundleCardDefaults? = nil,
        tip: LessonBundleTipDefaults? = nil
    ) {
        self.locale = locale
        self.page = page
        self.card = card
        self.tip = tip
    }
}

private struct LessonBundlePageDefaults: Decodable {
    let accent: ContentAccent?
}

private struct LessonBundleCardDefaults: Decodable {
    let accent: ContentAccent?
    let topic: String?
}

private struct LessonBundleTipDefaults: Decodable {
    let accent: ContentAccent?
    let systemImage: String?
}

private indirect enum StrictYAMLSchema {
    case scalar
    case mapping([String: StrictYAMLSchema])
    case sequence(StrictYAMLSchema)

    static var defaults: StrictYAMLSchema {
        .mapping([
            "locale": .scalar,
            "page": .mapping([
                "accent": .scalar,
            ]),
            "card": .mapping([
                "accent": .scalar,
                "topic": .scalar,
            ]),
            "tip": .mapping([
                "accent": .scalar,
                "systemImage": .scalar,
            ]),
        ])
    }

    static var project: StrictYAMLSchema {
        .mapping([
            "format": .scalar,
            "schemaVersion": .scalar,
            "releaseVersion": .scalar,
            "locale": .scalar,
            "primaryRouteID": .scalar,
            "minAppBuild": .scalar,
            "publishedAt": .scalar,
            "retiredIDs": .sequence(.scalar),
            "defaults": .defaults,
            "globalTips": .sequence(.scalar),
            "routes": .sequence(
                .mapping([
                    "id": .scalar,
                    "title": .scalar,
                    "subtitle": .scalar,
                    "systemImage": .scalar,
                    "accent": .scalar,
                    "cta": .scalar,
                    "interactive": .scalar,
                    "defaults": .defaults,
                    "tracks": .sequence(
                        .mapping([
                            "id": .scalar,
                            "title": .scalar,
                            "defaults": .defaults,
                            "lessons": .sequence(.scalar),
                        ])
                    ),
                ])
            ),
        ])
    }

    static var lesson: StrictYAMLSchema {
        .mapping([
            "format": .scalar,
            "id": .scalar,
            "title": .scalar,
            "prerequisites": .sequence(.scalar),
            "completion": .mapping([
                "xp": .scalar,
                "message": .scalar,
            ]),
            "defaults": .defaults,
            "pages": .sequence(
                .mapping([
                    "id": .scalar,
                    "title": .scalar,
                    "source": .scalar,
                    "accent": .scalar,
                    "revision": .scalar,
                    "locale": .scalar,
                    "objectives": .sequence(.scalar),
                ])
            ),
            "cards": .sequence(.scalar),
            "tips": .sequence(.scalar),
        ])
    }
}

private func topLevelYAMLFormat(
    at url: URL,
    sourceRoot: URL
) throws -> String? {
    let source = try readAuthorText(url)
    try validateSafeYAMLSource(source, url: url, sourceRoot: sourceRoot)

    let node: Node
    do {
        guard let composed = try compose(yaml: source) else { return nil }
        node = composed
    } catch let error as ContentValidationError {
        throw error
    } catch {
        throw diagnostic(
            code: "yaml.invalid",
            message: error.localizedDescription,
            url: url,
            relativeTo: sourceRoot,
            line: 1
        )
    }

    guard case let .mapping(mapping) = node else { return nil }
    for pair in mapping {
        guard case let .scalar(key) = pair.key, key.string == "format" else {
            continue
        }
        guard case let .scalar(value) = pair.value else {
            throw diagnostic(
                code: "yaml.typeConflict",
                message: "Top-level format must be a scalar value.",
                url: url,
                relativeTo: sourceRoot,
                line: pair.value.mark?.line ?? 1,
                column: pair.value.mark?.column
            )
        }
        return value.string
    }
    return nil
}

private func decodeStrictYAML<Value: Decodable>(
    at url: URL,
    relativeTo sourceRoot: URL,
    schema: StrictYAMLSchema
) throws -> Value {
    guard FileManager.default.fileExists(atPath: url.path) else {
        throw diagnostic(
            code: "file.missing",
            message: "Required YAML file does not exist.",
            url: url,
            relativeTo: sourceRoot,
            line: 1
        )
    }
    let source = try readAuthorText(url)
    try validateSafeYAMLSource(source, url: url, sourceRoot: sourceRoot)
    let node: Node
    do {
        guard let composed = try compose(yaml: source) else {
            throw diagnostic(
                code: "yaml.invalid",
                message: "YAML document must not be empty.",
                url: url,
                relativeTo: sourceRoot,
                line: 1
            )
        }
        node = composed
    } catch let error as ContentValidationError {
        throw error
    } catch {
        throw diagnostic(
            code: "yaml.invalid",
            message: error.localizedDescription,
            url: url,
            relativeTo: sourceRoot,
            line: 1
        )
    }
    try validateStrictYAMLNode(
        node,
        schema: schema,
        url: url,
        sourceRoot: sourceRoot
    )
    do {
        return try YAMLDecoder().decode(Value.self, from: source)
    } catch {
        throw diagnostic(
            code: "yaml.invalid",
            message: error.localizedDescription,
            url: url,
            relativeTo: sourceRoot,
            line: 1
        )
    }
}

private func validateStrictYAMLNode(
    _ node: Node,
    schema: StrictYAMLSchema,
    url: URL,
    sourceRoot: URL
) throws {
    switch schema {
    case .scalar:
        guard case .scalar = node else {
            throw diagnostic(
                code: "yaml.typeConflict",
                message: "Expected a scalar value.",
                url: url,
                relativeTo: sourceRoot,
                line: node.mark?.line ?? 1,
                column: node.mark?.column
            )
        }
    case let .sequence(elementSchema):
        guard case let .sequence(sequence) = node else {
            throw diagnostic(
                code: "yaml.typeConflict",
                message: "Expected an array.",
                url: url,
                relativeTo: sourceRoot,
                line: node.mark?.line ?? 1,
                column: node.mark?.column
            )
        }
        for element in sequence {
            try validateStrictYAMLNode(
                element,
                schema: elementSchema,
                url: url,
                sourceRoot: sourceRoot
            )
        }
    case let .mapping(fields):
        guard case let .mapping(mapping) = node else {
            throw diagnostic(
                code: "yaml.typeConflict",
                message: "Expected a map.",
                url: url,
                relativeTo: sourceRoot,
                line: node.mark?.line ?? 1,
                column: node.mark?.column
            )
        }
        var seen: Set<String> = []
        for pair in mapping {
            guard case let .scalar(keyScalar) = pair.key else {
                throw diagnostic(
                    code: "yaml.invalid",
                    message: "YAML map keys must be strings.",
                    url: url,
                    relativeTo: sourceRoot,
                    line: pair.key.mark?.line ?? 1,
                    column: pair.key.mark?.column
                )
            }
            let key = keyScalar.string
            guard seen.insert(key).inserted else {
                throw diagnostic(
                    code: "yaml.duplicateField",
                    message: "Duplicate YAML field '\(key)'.",
                    url: url,
                    relativeTo: sourceRoot,
                    line: pair.key.mark?.line ?? 1,
                    column: pair.key.mark?.column
                )
            }
            guard let childSchema = fields[key] else {
                throw diagnostic(
                    code: "yaml.unknownField",
                    message: "Unknown YAML field '\(key)'.",
                    url: url,
                    relativeTo: sourceRoot,
                    line: pair.key.mark?.line ?? 1,
                    column: pair.key.mark?.column
                )
            }
            try validateStrictYAMLNode(
                pair.value,
                schema: childSchema,
                url: url,
                sourceRoot: sourceRoot
            )
        }
    }
}

private func mergeDefaults(
    parent: LessonBundleDefaults,
    child: LessonBundleDefaults?,
    projectLocale: String,
    url: URL,
    sourceRoot: URL,
    line diagnosticLine: Int? = nil
) throws -> LessonBundleDefaults {
    if let locale = child?.locale, locale != projectLocale {
        let localeLine: Int
        if let diagnosticLine {
            localeLine = diagnosticLine
        } else {
            localeLine = line(ofKey: "locale", in: try readAuthorText(url))
        }
        throw diagnostic(
            code: "locale.mismatch",
            message: "Inherited locale '\(locale)' differs from project locale '\(projectLocale)'.",
            url: url,
            relativeTo: sourceRoot,
            line: localeLine
        )
    }
    return LessonBundleDefaults(
        locale: child?.locale ?? parent.locale,
        page: LessonBundlePageDefaults(
            accent: child?.page?.accent ?? parent.page?.accent
        ),
        card: LessonBundleCardDefaults(
            accent: child?.card?.accent ?? parent.card?.accent,
            topic: child?.card?.topic ?? parent.card?.topic
        ),
        tip: LessonBundleTipDefaults(
            accent: child?.tip?.accent ?? parent.tip?.accent,
            systemImage: child?.tip?.systemImage ?? parent.tip?.systemImage
        )
    )
}

private func resolvedLocale(
    _ locale: String?,
    projectLocale: String,
    url: URL,
    sourceRoot: URL,
    line: Int = 1
) throws -> String {
    guard let locale,
          !locale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
        throw diagnostic(
            code: "value.missing",
            message: "Content requires an inherited locale.",
            url: url,
            relativeTo: sourceRoot,
            line: line
        )
    }
    guard locale == projectLocale else {
        throw diagnostic(
            code: "locale.mismatch",
            message: "Content locale '\(locale)' differs from project locale '\(projectLocale)'.",
            url: url,
            relativeTo: sourceRoot,
            line: line
        )
    }
    return locale
}

private func positiveRevision(
    _ value: String,
    directive: BlockDirective,
    url: URL,
    sourceRoot: URL
) throws -> Int {
    guard let revision = Int(value), revision > 0 else {
        throw markupDiagnostic(
            code: "value.invalid",
            message: "revision must be a positive integer.",
            markup: directive,
            url: url,
            sourceRoot: sourceRoot
        )
    }
    return revision
}

private func rejectFrontMatter(
    in source: String,
    url: URL,
    sourceRoot: URL
) throws {
    let firstLine = source.split(
        separator: "\n",
        maxSplits: 1,
        omittingEmptySubsequences: false
    ).first.map(String.init)
    guard firstLine != "---" else {
        throw diagnostic(
            code: "frontMatter.forbidden",
            message: "Lesson Bundle Markdown must not contain YAML front matter.",
            url: url,
            relativeTo: sourceRoot,
            line: 1
        )
    }
}

private func resolveAuthorFile(
    _ path: String,
    relativeTo baseDirectory: URL,
    boundary: URL,
    sourceRoot: URL
) throws -> URL {
    let components = path.split(
        separator: "/",
        omittingEmptySubsequences: false
    ).map(String.init)
    if path.hasPrefix("/") || components.contains("..") {
        throw diagnostic(
            code: "path.outsideBundle",
            message: "Author paths must remain inside their owning directory.",
            url: baseDirectory.appending(path: path),
            relativeTo: sourceRoot,
            line: 1
        )
    }
    guard !path.isEmpty,
          !path.contains("\\"),
          !path.contains("://"),
          !components.contains(where: { $0.isEmpty || $0 == "." })
    else {
        throw diagnostic(
            code: "path.invalid",
            message: "Author path '\(path)' is not a valid relative path.",
            url: baseDirectory,
            relativeTo: sourceRoot,
            line: 1
        )
    }

    let boundaryURL = boundary.standardizedFileURL
    let candidate = baseDirectory.appending(path: path).standardizedFileURL
    let boundaryPath = boundaryURL.path
    guard candidate.path.hasPrefix(boundaryPath + "/") else {
        throw diagnostic(
            code: "path.outsideBundle",
            message: "Author path '\(path)' resolves outside its owning directory.",
            url: candidate,
            relativeTo: sourceRoot,
            line: 1
        )
    }
    guard FileManager.default.fileExists(atPath: candidate.path) else {
        throw diagnostic(
            code: "file.missing",
            message: "Referenced file '\(path)' does not exist.",
            url: candidate,
            relativeTo: sourceRoot,
            line: 1
        )
    }

    let relative = String(candidate.path.dropFirst(boundaryPath.count + 1))
    var current = boundaryURL
    for component in relative.split(separator: "/") {
        current.append(path: String(component))
        let values = try current.resourceValues(
            forKeys: [.isSymbolicLinkKey]
        )
        guard values.isSymbolicLink != true else {
            throw diagnostic(
                code: "path.symbolicLink",
                message: "Author paths may not traverse symbolic links.",
                url: current,
                relativeTo: sourceRoot,
                line: 1
            )
        }
    }
    let values = try candidate.resourceValues(
        forKeys: [.isRegularFileKey, .isSymbolicLinkKey]
    )
    guard values.isRegularFile == true, values.isSymbolicLink != true else {
        throw diagnostic(
            code: "file.invalid",
            message: "Referenced source must be a regular, non-symbolic-link file.",
            url: candidate,
            relativeTo: sourceRoot,
            line: 1
        )
    }
    return candidate
}

private func readAuthorText(_ url: URL) throws -> String {
    let data: Data
    do {
        data = try Data(contentsOf: url)
    } catch {
        throw ContentValidationError(
            diagnostics: [
                ContentDiagnostic(
                    severity: .error,
                    code: "file.missing",
                    message: "Source file could not be read.",
                    file: url.path,
                    line: 1
                ),
            ]
        )
    }
    guard data.count <= ContentCompiler.maximumSourceFileSize else {
        throw ContentValidationError(
            diagnostics: [
                ContentDiagnostic(
                    severity: .error,
                    code: "file.tooLarge",
                    message: "Source file exceeds \(ContentCompiler.maximumSourceFileSize) bytes.",
                    file: url.path,
                    line: 1
                ),
            ]
        )
    }
    guard let source = String(data: data, encoding: .utf8) else {
        throw ContentValidationError(
            diagnostics: [
                ContentDiagnostic(
                    severity: .error,
                    code: "file.encoding",
                    message: "Source file must be UTF-8.",
                    file: url.path,
                    line: 1
                ),
            ]
        )
    }
    return source
}

private func recursiveSourceFiles(
    below directory: URL,
    extensions: Set<String>
) throws -> [URL] {
    guard let enumerator = FileManager.default.enumerator(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey],
        options: [.skipsHiddenFiles, .skipsPackageDescendants]
    ) else {
        return []
    }
    var result: [URL] = []
    for case let url as URL in enumerator {
        let values = try url.resourceValues(
            forKeys: [.isRegularFileKey, .isSymbolicLinkKey]
        )
        if values.isRegularFile == true,
           values.isSymbolicLink != true,
           extensions.contains(url.pathExtension.lowercased())
        {
            result.append(url)
        }
    }
    return result.sorted { $0.path < $1.path }
}

private func parseBlocks<C: Sequence>(
    _ children: C,
    lessonID: String,
    url: URL,
    sourceRoot: URL,
    exercises: inout [ExerciseDefinition]
) throws -> [LessonContentBlock] where C.Element == Markup {
    var blocks: [LessonContentBlock] = []
    for child in children {
        if let paragraph = child as? Paragraph {
            blocks.append(.paragraph(try parseInline(paragraph, url: url, sourceRoot: sourceRoot)))
        } else if let heading = child as? Heading {
            blocks.append(
                .heading(
                    level: heading.level,
                    content: try parseInline(heading, url: url, sourceRoot: sourceRoot)
                )
            )
        } else if let list = child as? UnorderedList {
            blocks.append(
                .list(
                    ordered: false,
                    items: try parseList(list, url: url, sourceRoot: sourceRoot)
                )
            )
        } else if let list = child as? OrderedList {
            blocks.append(
                .list(
                    ordered: true,
                    items: try parseList(list, url: url, sourceRoot: sourceRoot)
                )
            )
        } else if let codeBlock = child as? CodeBlock {
            blocks.append(.code(language: codeBlock.language, code: codeBlock.code))
        } else if let directive = child as? BlockDirective {
            switch directive.name {
            case "Callout":
                let arguments = try directiveArguments(
                    directive,
                    allowed: ["title", "tone", "accent"],
                    required: ["title", "tone", "accent"],
                    url: url,
                    sourceRoot: sourceRoot
                )
                guard let tone = ContentTone(rawValue: arguments["tone"]!),
                      let accent = ContentAccent(rawValue: arguments["accent"]!)
                else {
                    throw markupDiagnostic(
                        code: "directive.invalidArgument",
                        message: "@Callout tone or accent is not supported.",
                        markup: directive,
                        url: url,
                        sourceRoot: sourceRoot
                    )
                }
                var nestedExercises: [ExerciseDefinition] = []
                let body = try parseBlocks(
                    directive.children,
                    lessonID: lessonID,
                    url: url,
                    sourceRoot: sourceRoot,
                    exercises: &nestedExercises
                )
                if !nestedExercises.isEmpty {
                    throw markupDiagnostic(
                        code: "block.invalidNesting",
                        message: "@Quiz may not be nested inside @Callout.",
                        markup: directive,
                        url: url,
                        sourceRoot: sourceRoot
                    )
                }
                blocks.append(
                    .callout(
                        title: arguments["title"]!,
                        tone: tone,
                        accent: accent,
                        body: body
                    )
                )
            case "Image":
                let arguments = try directiveArguments(
                    directive,
                    allowed: ["path", "alt", "caption"],
                    required: ["path", "alt"],
                    url: url,
                    sourceRoot: sourceRoot
                )
                guard directive.childCount == 0 else {
                    throw markupDiagnostic(
                        code: "directive.unexpectedBody",
                        message: "@Image does not accept a body.",
                        markup: directive,
                        url: url,
                        sourceRoot: sourceRoot
                    )
                }
                let caption = arguments["caption"].map { [InlineContent.text($0)] }
                blocks.append(
                    .image(path: arguments["path"]!, alt: arguments["alt"]!, caption: caption)
                )
            case "Quiz":
                let exercise = try parseQuiz(
                    directive,
                    lessonID: lessonID,
                    url: url,
                    sourceRoot: sourceRoot
                )
                exercises.append(exercise)
                blocks.append(.singleChoice(exerciseID: exercise.id))
            default:
                throw markupDiagnostic(
                    code: "directive.unknown",
                    message: "Unknown directive @\(directive.name).",
                    markup: directive,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
        } else {
            throw markupDiagnostic(
                code: "block.unsupported",
                message: "Unsupported Markdown block '\(String(describing: type(of: child)))'.",
                markup: child,
                url: url,
                sourceRoot: sourceRoot
            )
        }
    }
    return blocks
}

private func parseList(
    _ list: Markup,
    url: URL,
    sourceRoot: URL
) throws -> [LearnNowContentKit.ListItem] {
    try list.children.map { child in
        guard let item = child as? Markdown.ListItem,
              item.childCount == 1,
              let paragraph = item.child(at: 0) as? Paragraph
        else {
            throw markupDiagnostic(
                code: "list.unsupportedNesting",
                message: "V1 lists require one paragraph per item and do not allow nested lists.",
                markup: child,
                url: url,
                sourceRoot: sourceRoot
            )
        }
        return LearnNowContentKit.ListItem(
            content: try parseInline(paragraph, url: url, sourceRoot: sourceRoot)
        )
    }
}

private func parseQuiz(
    _ directive: BlockDirective,
    lessonID: String,
    url: URL,
    sourceRoot: URL
) throws -> ExerciseDefinition {
    let arguments = try directiveArguments(
        directive,
        allowed: ["id", "kind"],
        required: ["id", "kind"],
        url: url,
        sourceRoot: sourceRoot
    )
    guard arguments["kind"] == ExerciseDefinition.Kind.singleChoice.rawValue else {
        throw markupDiagnostic(
            code: "quiz.unsupportedKind",
            message: "Only kind singleChoice is supported.",
            markup: directive,
            url: url,
            sourceRoot: sourceRoot
        )
    }

    var prompt: [InlineContent] = []
    var options: [ExerciseOptionDefinition] = []
    var correctOptionIDs: [String] = []
    var correctFeedback: FeedbackDefinition?
    var incorrectFeedback: FeedbackDefinition?

    for child in directive.children {
        if let paragraph = child as? Paragraph {
            appendParagraph(
                try parseInline(paragraph, url: url, sourceRoot: sourceRoot),
                to: &prompt
            )
            continue
        }
        guard let nested = child as? BlockDirective else {
            throw markupDiagnostic(
                code: "quiz.invalidChild",
                message: "@Quiz supports prompt paragraphs, @Option, and @Feedback only.",
                markup: child,
                url: url,
                sourceRoot: sourceRoot
            )
        }
        switch nested.name {
        case "Option":
            let optionArguments = try directiveArguments(
                nested,
                allowed: ["id", "correct"],
                required: ["id"],
                url: url,
                sourceRoot: sourceRoot
            )
            let isCorrect: Bool
            switch optionArguments["correct"] {
            case nil, "false":
                isCorrect = false
            case "true":
                isCorrect = true
            default:
                throw markupDiagnostic(
                    code: "directive.invalidArgument",
                    message: "@Option correct must be true or false.",
                    markup: nested,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
            var optionContent: [InlineContent] = []
            var optionFeedback: FeedbackDefinition?
            for optionChild in nested.children {
                if let paragraph = optionChild as? Paragraph {
                    appendParagraph(
                        try parseInline(paragraph, url: url, sourceRoot: sourceRoot),
                        to: &optionContent
                    )
                } else if let feedbackDirective = optionChild as? BlockDirective,
                          feedbackDirective.name == "Feedback"
                {
                    guard optionFeedback == nil else {
                        throw markupDiagnostic(
                            code: "directive.duplicate",
                            message: "@Option accepts at most one @Feedback.",
                            markup: feedbackDirective,
                            url: url,
                            sourceRoot: sourceRoot
                        )
                    }
                    optionFeedback = try parseFeedback(
                        feedbackDirective,
                        requireWhen: false,
                        url: url,
                        sourceRoot: sourceRoot
                    ).feedback
                } else {
                    throw markupDiagnostic(
                        code: "quiz.invalidOptionChild",
                        message: "@Option supports paragraphs and one @Feedback only.",
                        markup: optionChild,
                        url: url,
                        sourceRoot: sourceRoot
                    )
                }
            }
            guard !optionContent.isEmpty else {
                throw markupDiagnostic(
                    code: "quiz.emptyOption",
                    message: "@Option body must not be empty.",
                    markup: nested,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
            let optionID = optionArguments["id"]!
            options.append(
                ExerciseOptionDefinition(
                    id: optionID,
                    content: optionContent,
                    feedback: optionFeedback
                )
            )
            if isCorrect { correctOptionIDs.append(optionID) }
        case "Feedback":
            let parsed = try parseFeedback(
                nested,
                requireWhen: true,
                url: url,
                sourceRoot: sourceRoot
            )
            switch parsed.when {
            case "correct":
                guard correctFeedback == nil else {
                    throw markupDiagnostic(
                        code: "directive.duplicate",
                        message: "Duplicate correct @Feedback.",
                        markup: nested,
                        url: url,
                        sourceRoot: sourceRoot
                    )
                }
                correctFeedback = parsed.feedback
            case "incorrect":
                guard incorrectFeedback == nil else {
                    throw markupDiagnostic(
                        code: "directive.duplicate",
                        message: "Duplicate incorrect @Feedback.",
                        markup: nested,
                        url: url,
                        sourceRoot: sourceRoot
                    )
                }
                incorrectFeedback = parsed.feedback
            default:
                throw markupDiagnostic(
                    code: "directive.invalidArgument",
                    message: "@Feedback when must be correct or incorrect.",
                    markup: nested,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
        default:
            throw markupDiagnostic(
                code: "directive.unknown",
                message: "Unknown @Quiz child @\(nested.name).",
                markup: nested,
                url: url,
                sourceRoot: sourceRoot
            )
        }
    }

    guard !prompt.isEmpty else {
        throw markupDiagnostic(
            code: "quiz.missingPrompt",
            message: "@Quiz requires a prompt paragraph.",
            markup: directive,
            url: url,
            sourceRoot: sourceRoot
        )
    }
    guard correctOptionIDs.count == 1 else {
        throw markupDiagnostic(
            code: "quiz.correctCount",
            message: "@Quiz requires exactly one @Option(correct: true).",
            markup: directive,
            url: url,
            sourceRoot: sourceRoot
        )
    }
    guard let correctFeedback, let incorrectFeedback else {
        throw markupDiagnostic(
            code: "quiz.missingFeedback",
            message: "@Quiz requires correct and incorrect @Feedback directives.",
            markup: directive,
            url: url,
            sourceRoot: sourceRoot
        )
    }

    return ExerciseDefinition(
        id: arguments["id"]!,
        lessonID: lessonID,
        prompt: prompt,
        options: options,
        correctOptionID: correctOptionIDs[0],
        correctFeedback: correctFeedback,
        incorrectFeedback: incorrectFeedback
    )
}

private func parseFeedback(
    _ directive: BlockDirective,
    requireWhen: Bool,
    url: URL,
    sourceRoot: URL
) throws -> (when: String?, feedback: FeedbackDefinition) {
    var required = ["title", "tone", "accent"]
    if requireWhen { required.append("when") }
    let arguments = try directiveArguments(
        directive,
        allowed: ["when", "title", "tone", "accent"],
        required: Set(required),
        url: url,
        sourceRoot: sourceRoot
    )
    guard let tone = ContentTone(rawValue: arguments["tone"]!),
          let accent = ContentAccent(rawValue: arguments["accent"]!)
    else {
        throw markupDiagnostic(
            code: "directive.invalidArgument",
            message: "@Feedback tone or accent is not supported.",
            markup: directive,
            url: url,
            sourceRoot: sourceRoot
        )
    }
    let body = try parseInlineBody(directive, url: url, sourceRoot: sourceRoot)
    guard !body.isEmpty else {
        throw markupDiagnostic(
            code: "feedback.empty",
            message: "@Feedback body must not be empty.",
            markup: directive,
            url: url,
            sourceRoot: sourceRoot
        )
    }
    return (
        arguments["when"],
        FeedbackDefinition(
            title: arguments["title"]!,
            body: body,
            tone: tone,
            accent: accent
        )
    )
}

private func parseInlineBody(
    _ directive: BlockDirective,
    url: URL,
    sourceRoot: URL
) throws -> [InlineContent] {
    var result: [InlineContent] = []
    for child in directive.children {
        guard let paragraph = child as? Paragraph else {
            throw markupDiagnostic(
                code: "block.unsupported",
                message: "@\(directive.name) supports paragraph content only.",
                markup: child,
                url: url,
                sourceRoot: sourceRoot
            )
        }
        appendParagraph(
            try parseInline(paragraph, url: url, sourceRoot: sourceRoot),
            to: &result
        )
    }
    return result
}

private func parseInline(
    _ markup: Markup,
    url: URL,
    sourceRoot: URL
) throws -> [InlineContent] {
    var result: [InlineContent] = []
    for child in markup.children {
        if let text = child as? Text {
            result.append(.text(text.string))
        } else if let emphasis = child as? Emphasis {
            result.append(
                .emphasis(try parseInline(emphasis, url: url, sourceRoot: sourceRoot))
            )
        } else if let strong = child as? Strong {
            result.append(
                .strong(try parseInline(strong, url: url, sourceRoot: sourceRoot))
            )
        } else if let code = child as? InlineCode {
            result.append(.code(code.code))
        } else if child is SoftBreak || child is LineBreak {
            result.append(.lineBreak)
        } else {
            throw markupDiagnostic(
                code: "inline.unsupported",
                message: "Unsupported inline Markdown '\(String(describing: type(of: child)))'. Links, HTML, and inline images are not allowed.",
                markup: child,
                url: url,
                sourceRoot: sourceRoot
            )
        }
    }
    return result
}

private func directiveArguments(
    _ directive: BlockDirective,
    allowed: Set<String>,
    required: Set<String>,
    url: URL,
    sourceRoot: URL
) throws -> [String: String] {
    var parseErrors: [DirectiveArgumentText.ParseError] = []
    let parsed = directive.argumentText.parseNameValueArguments(parseErrors: &parseErrors)
    guard parseErrors.isEmpty else {
        throw markupDiagnostic(
            code: "directive.invalidArguments",
            message: "Could not parse @\(directive.name) arguments.",
            markup: directive,
            url: url,
            sourceRoot: sourceRoot
        )
    }
    var arguments: [String: String] = [:]
    var duplicateNames: Set<String> = []
    for argument in parsed {
        if arguments.updateValue(argument.value, forKey: argument.name) != nil {
            duplicateNames.insert(argument.name)
        }
    }
    guard duplicateNames.isEmpty else {
        throw markupDiagnostic(
            code: "directive.duplicateArgument",
            message: "@\(directive.name) repeats arguments: \(duplicateNames.sorted().joined(separator: ", ")).",
            markup: directive,
            url: url,
            sourceRoot: sourceRoot
        )
    }
    let unknown = Set(arguments.keys).subtracting(allowed)
    guard unknown.isEmpty else {
        throw markupDiagnostic(
            code: "directive.unknownArgument",
            message: "@\(directive.name) has unknown arguments: \(unknown.sorted().joined(separator: ", ")).",
            markup: directive,
            url: url,
            sourceRoot: sourceRoot
        )
    }
    let missing = required.filter { arguments[$0] == nil }
    guard missing.isEmpty else {
        throw markupDiagnostic(
            code: "directive.missingArgument",
            message: "@\(directive.name) is missing arguments: \(missing.sorted().joined(separator: ", ")).",
            markup: directive,
            url: url,
            sourceRoot: sourceRoot
        )
    }
    return arguments
}

private func appendParagraph(_ paragraph: [InlineContent], to result: inout [InlineContent]) {
    if !result.isEmpty { result.append(.lineBreak) }
    result.append(contentsOf: paragraph)
}

private func strippingQuotedText(_ source: String) -> String {
    var result = ""
    var quote: Character?
    var escaped = false
    for character in source {
        if escaped {
            escaped = false
            if quote == nil { result.append(character) }
            continue
        }
        if character == "\\" {
            escaped = true
            if quote == nil { result.append(" ") }
            continue
        }
        if let current = quote {
            if character == current { quote = nil }
            result.append(" ")
        } else if character == "\"" || character == "'" {
            quote = character
            result.append(" ")
        } else {
            result.append(character)
        }
    }
    return result
}

private func validateSafeYAMLSource(
    _ source: String,
    url: URL,
    sourceRoot: URL
) throws {
    for (index, lineText) in source.split(
        separator: "\n",
        omittingEmptySubsequences: false
    ).enumerated() {
        let unquoted = strippingQuotedText(String(lineText))
        if unquoted.range(
            of: #"(^|\s)[&*!][A-Za-z0-9_-]+"#,
            options: .regularExpression
        ) != nil {
            throw diagnostic(
                code: "yaml.unsafeFeature",
                message: "YAML anchors, aliases, and custom tags are not supported.",
                url: url,
                relativeTo: sourceRoot,
                line: index + 1
            )
        }
    }
}

private func line(ofKey key: String, in source: String) -> Int {
    line(of: "\(key):", in: source)
}

private func line(of needle: String, in source: String) -> Int {
    for (index, line) in source.split(
        separator: "\n",
        omittingEmptySubsequences: false
    ).enumerated() where line.contains(needle) {
        return index + 1
    }
    return 1
}

private func relativePath(_ url: URL, to root: URL) -> String {
    let rootPath = root.standardizedFileURL.path
    let path = url.standardizedFileURL.path
    guard path.hasPrefix(rootPath + "/") else { return path }
    return String(path.dropFirst(rootPath.count + 1))
}

private func diagnostic(
    code: String,
    message: String,
    url: URL,
    relativeTo root: URL,
    line: Int,
    column: Int? = nil
) -> ContentValidationError {
    ContentValidationError(
        diagnostics: [
            ContentDiagnostic(
                severity: .error,
                code: code,
                message: message,
                file: relativePath(url, to: root),
                line: line,
                column: column
            ),
        ]
    )
}

private func markupDiagnostic(
    code: String,
    message: String,
    markup: Markup,
    url: URL,
    sourceRoot: URL
) -> ContentValidationError {
    diagnostic(
        code: code,
        message: message,
        url: url,
        relativeTo: sourceRoot,
        line: markup.range?.lowerBound.line ?? 1,
        column: markup.range?.lowerBound.column
    )
}

private func remap(
    _ diagnostic: ContentDiagnostic,
    using locations: [String: (file: String, line: Int)]
) -> ContentDiagnostic {
    guard diagnostic.file == "CatalogV2.json",
          let location = locations.first(where: { id, _ in
              diagnostic.message.contains("'\(id)'")
          })?.value
    else {
        return diagnostic
    }
    return ContentDiagnostic(
        severity: diagnostic.severity,
        code: diagnostic.code,
        message: diagnostic.message,
        file: location.file,
        line: location.line
    )
}

private func diagnosticOrder(_ left: ContentDiagnostic, _ right: ContentDiagnostic) -> Bool {
    if left.file != right.file { return left.file < right.file }
    if left.line != right.line { return (left.line ?? 0) < (right.line ?? 0) }
    return left.code < right.code
}

private enum ContentCapabilityAnalyzer {
    static func requiredCapabilities(for catalog: CatalogDocumentV2) -> Set<String> {
        var result: Set<String> = []

        func collectInline(_ content: [InlineContent]) {
            for item in content {
                switch item {
                case .text, .lineBreak:
                    break
                case let .emphasis(children):
                    result.insert("inlineEmphasis")
                    collectInline(children)
                case let .strong(children):
                    result.insert("inlineStrong")
                    collectInline(children)
                case .code:
                    result.insert("inlineCode")
                }
            }
        }

        func collectFeedback(_ feedback: FeedbackDefinition) {
            collectInline(feedback.body)
        }

        func collectBlocks(_ blocks: [LessonContentBlock]) {
            for block in blocks {
                switch block {
                case let .paragraph(content):
                    result.insert("paragraph")
                    collectInline(content)
                case let .heading(_, content):
                    result.insert("heading")
                    collectInline(content)
                case let .list(_, items):
                    result.insert("list")
                    for item in items {
                        collectInline(item.content)
                    }
                case let .callout(_, _, _, body):
                    result.insert("callout")
                    collectBlocks(body)
                case .code:
                    result.insert("code")
                case let .image(_, _, caption):
                    result.insert("image")
                    if let caption { collectInline(caption) }
                case .singleChoice:
                    result.insert("singleChoice")
                }
            }
        }

        for lesson in catalog.lessons {
            collectBlocks(lesson.blocks)
        }
        for exercise in catalog.exercises {
            collectInline(exercise.prompt)
            for option in exercise.options {
                collectInline(option.content)
                if let feedback = option.feedback {
                    collectFeedback(feedback)
                }
            }
            collectFeedback(exercise.correctFeedback)
            collectFeedback(exercise.incorrectFeedback)
        }
        for card in catalog.reviewCards {
            collectInline(card.backBody)
            collectInline(card.backHighlight)
        }
        for tip in catalog.knowledgeTips {
            collectInline(tip.body)
        }
        return result
    }
}

private func isValidImageSignature(_ data: Data, extension: String) -> Bool {
    let bytes = [UInt8](data.prefix(12))
    switch `extension` {
    case "png":
        return bytes.starts(with: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
    case "jpg", "jpeg":
        return bytes.starts(with: [0xFF, 0xD8, 0xFF])
    case "gif":
        return data.starts(with: Data("GIF87a".utf8))
            || data.starts(with: Data("GIF89a".utf8))
    case "webp":
        return bytes.count >= 12
            && Array(bytes[0..<4]) == Array("RIFF".utf8)
            && Array(bytes[8..<12]) == Array("WEBP".utf8)
    default:
        return false
    }
}
