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
    public static let compilerVersion = "1.0.0"
    public static let maximumSourceFileSize = 1_048_576

    public init() {}

    public func lint(sourceDirectory: URL) -> [ContentDiagnostic] {
        do {
            _ = try compile(sourceDirectory: sourceDirectory)
            return []
        } catch let error as ContentValidationError {
            return error.diagnostics
        } catch {
            return [
                ContentDiagnostic(
                    severity: .error,
                    code: "compiler.failure",
                    message: error.localizedDescription,
                    file: sourceDirectory.path
                ),
            ]
        }
    }

    public func compile(sourceDirectory: URL) throws -> ContentCompilationResult {
        let catalogURL = sourceDirectory.appending(path: "catalog.yaml")
        let catalogSource: CatalogSource = try decodeYAML(at: catalogURL, relativeTo: sourceDirectory)

        guard catalogSource.format == "learnnow.catalog/v1" else {
            throw diagnostic(
                code: "format.unsupported",
                message: "Expected format learnnow.catalog/v1.",
                url: catalogURL,
                relativeTo: sourceDirectory,
                line: 1
            )
        }
        guard catalogSource.schemaVersion == CatalogDocumentV2.currentSchemaVersion else {
            throw diagnostic(
                code: "schema.unsupported",
                message: "catalog.yaml schemaVersion must be \(CatalogDocumentV2.currentSchemaVersion).",
                url: catalogURL,
                relativeTo: sourceDirectory,
                line: line(ofKey: "schemaVersion", in: try readText(catalogURL))
            )
        }
        guard ContentReleaseVersion(catalogSource.releaseVersion) != nil else {
            throw diagnostic(
                code: "release.invalid",
                message: "releaseVersion must contain only dot-separated UInt64 decimal components.",
                url: catalogURL,
                relativeTo: sourceDirectory,
                line: line(ofKey: "releaseVersion", in: try readText(catalogURL))
            )
        }

        let unsupportedCapabilities = Set(catalogSource.requiredCapabilities)
            .subtracting(ContentPolicy.supportedCapabilities)
        if !unsupportedCapabilities.isEmpty {
            throw diagnostic(
                code: "capability.unsupported",
                message: "Unsupported capabilities: \(unsupportedCapabilities.sorted().joined(separator: ", ")).",
                url: catalogURL,
                relativeTo: sourceDirectory,
                line: line(ofKey: "requiredCapabilities", in: try readText(catalogURL))
            )
        }
        if Set(catalogSource.requiredCapabilities).count != catalogSource.requiredCapabilities.count {
            throw diagnostic(
                code: "capability.duplicate",
                message: "requiredCapabilities must not contain duplicates.",
                url: catalogURL,
                relativeTo: sourceDirectory,
                line: line(ofKey: "requiredCapabilities", in: try readText(catalogURL))
            )
        }
        if catalogSource.minAppBuild <= 0 {
            throw diagnostic(
                code: "value.invalid",
                message: "minAppBuild must be positive.",
                url: catalogURL,
                relativeTo: sourceDirectory,
                line: line(ofKey: "minAppBuild", in: try readText(catalogURL))
            )
        }
        if ISO8601DateFormatter().date(from: catalogSource.publishedAt) == nil {
            throw diagnostic(
                code: "date.invalid",
                message: "publishedAt must be an RFC 3339 timestamp.",
                url: catalogURL,
                relativeTo: sourceDirectory,
                line: line(ofKey: "publishedAt", in: try readText(catalogURL))
            )
        }

        let routeFiles = try sourceFiles(
            below: sourceDirectory.appending(path: "routes"),
            extension: "yaml"
        )
        let moduleFiles = try sourceFiles(
            below: sourceDirectory.appending(path: "modules"),
            extension: "yaml"
        )
        let lessonFiles = try sourceFiles(
            below: sourceDirectory.appending(path: "lessons"),
            extension: "md"
        )
        let cardFiles = try sourceFiles(
            below: sourceDirectory.appending(path: "cards"),
            extension: "md"
        )
        let tipFiles = try sourceFiles(
            below: sourceDirectory.appending(path: "tips"),
            extension: "md"
        )

        var sourceLocationByID: [String: (file: String, line: Int)] = [:]

        let routePairs: [(Int, RouteDefinition)] = try routeFiles.map { url in
            let source: RouteSource = try decodeYAML(at: url, relativeTo: sourceDirectory)
            if sourceLocationByID[source.id] == nil {
                sourceLocationByID[source.id] = (
                    relativePath(url, to: sourceDirectory),
                    line(ofKey: "id", in: try readText(url))
                )
            }
            return (
                source.order,
                RouteDefinition(
                    id: source.id,
                    title: source.title,
                    subtitle: source.subtitle,
                    systemImage: source.systemImage,
                    accent: source.accent,
                    cta: source.cta,
                    interactive: source.interactive,
                    trackIDs: source.trackIDs,
                    moduleIDs: source.moduleIDs
                )
            )
        }
        let routes = routePairs.sorted(by: orderThenID).map(\.1)

        let modulePairs: [(String, ModuleDefinition)] = try moduleFiles.map { url in
            let source: ModuleSource = try decodeYAML(at: url, relativeTo: sourceDirectory)
            if sourceLocationByID[source.id] == nil {
                sourceLocationByID[source.id] = (
                    relativePath(url, to: sourceDirectory),
                    line(ofKey: "id", in: try readText(url))
                )
            }
            return (
                source.id,
                ModuleDefinition(
                    id: source.id,
                    trackID: source.trackID,
                    title: source.title,
                    subtitle: source.subtitle,
                    lessonTitle: source.lessonTitle,
                    prerequisiteModuleIDs: source.prerequisiteModuleIDs,
                    completionXP: source.completionXP,
                    reviewMessage: source.reviewMessage
                )
            )
        }
        var moduleByID: [String: ModuleDefinition] = [:]
        var duplicateModuleDiagnostics: [ContentDiagnostic] = []
        for (id, module) in modulePairs {
            if moduleByID[id] == nil {
                moduleByID[id] = module
            } else {
                let location = sourceLocationByID[id]
                duplicateModuleDiagnostics.append(
                    ContentDiagnostic(
                        severity: .error,
                        code: "id.duplicate",
                        message: "Duplicate module ID '\(id)'.",
                        file: location?.file ?? "modules",
                        line: location?.line
                    )
                )
            }
        }
        if !duplicateModuleDiagnostics.isEmpty {
            throw ContentValidationError(
                diagnostics: duplicateModuleDiagnostics.sorted(by: diagnosticOrder)
            )
        }
        let orderedModuleIDs = routes.flatMap(\.moduleIDs)
        let remainingModuleIDs = moduleByID.keys.filter { !orderedModuleIDs.contains($0) }.sorted()
        let modules = (orderedModuleIDs + remainingModuleIDs).compactMap { moduleByID[$0] }

        var lessonAndExercises: [(lesson: LessonDefinition, exercises: [ExerciseDefinition])] = []
        var parseDiagnostics: [ContentDiagnostic] = []
        for url in lessonFiles {
            do {
                let parsed = try LessonSourceParser(
                    url: url,
                    sourceRoot: sourceDirectory
                ).parse()
                lessonAndExercises.append(parsed)
                if sourceLocationByID[parsed.lesson.id] == nil {
                    sourceLocationByID[parsed.lesson.id] = (
                        relativePath(url, to: sourceDirectory),
                        line(ofKey: "id", in: try readText(url))
                    )
                }
                for exercise in parsed.exercises {
                    if sourceLocationByID[exercise.id] == nil {
                        sourceLocationByID[exercise.id] = (
                            relativePath(url, to: sourceDirectory),
                            line(of: "@Quiz", in: try readText(url))
                        )
                    }
                }
            } catch let error as ContentValidationError {
                parseDiagnostics.append(contentsOf: error.diagnostics)
            }
        }

        var cardPairs: [(Int, ReviewCardDefinition)] = []
        for url in cardFiles {
            do {
                let parsed = try parseCard(at: url, sourceRoot: sourceDirectory)
                cardPairs.append(parsed)
                if sourceLocationByID[parsed.1.id] == nil {
                    sourceLocationByID[parsed.1.id] = (
                        relativePath(url, to: sourceDirectory),
                        line(ofKey: "id", in: try readText(url))
                    )
                }
            } catch let error as ContentValidationError {
                parseDiagnostics.append(contentsOf: error.diagnostics)
            }
        }

        var tipPairs: [(Int, KnowledgeTipDefinition)] = []
        for url in tipFiles {
            do {
                let parsed = try parseTip(at: url, sourceRoot: sourceDirectory)
                tipPairs.append(parsed)
                if sourceLocationByID[parsed.1.id] == nil {
                    sourceLocationByID[parsed.1.id] = (
                        relativePath(url, to: sourceDirectory),
                        line(ofKey: "id", in: try readText(url))
                    )
                }
            } catch let error as ContentValidationError {
                parseDiagnostics.append(contentsOf: error.diagnostics)
            }
        }

        if !parseDiagnostics.isEmpty {
            throw ContentValidationError(diagnostics: parseDiagnostics.sorted(by: diagnosticOrder))
        }

        var moduleIndex: [String: Int] = [:]
        for (index, module) in modules.enumerated() where moduleIndex[module.id] == nil {
            moduleIndex[module.id] = index
        }
        lessonAndExercises.sort {
            let leftModule = moduleIndex[$0.lesson.moduleID, default: .max]
            let rightModule = moduleIndex[$1.lesson.moduleID, default: .max]
            if leftModule != rightModule { return leftModule < rightModule }
            if $0.lesson.order != $1.lesson.order { return $0.lesson.order < $1.lesson.order }
            return $0.lesson.id < $1.lesson.id
        }

        let catalog = CatalogDocumentV2(
            releaseVersion: catalogSource.releaseVersion,
            locale: catalogSource.locale,
            primaryRouteID: catalogSource.primaryRouteID,
            tracks: catalogSource.tracks,
            routes: routes,
            modules: modules,
            lessons: lessonAndExercises.map(\.lesson),
            exercises: lessonAndExercises.flatMap(\.exercises),
            reviewCards: cardPairs.sorted(by: orderThenID).map(\.1),
            knowledgeTips: tipPairs.sorted(by: orderThenID).map(\.1),
            retiredIDs: catalogSource.retiredIDs.sorted()
        )

        let semanticDiagnostics = CatalogSemanticValidator.validate(catalog).map { item in
            remap(item, using: sourceLocationByID)
        }
        if semanticDiagnostics.contains(where: { $0.severity == .error }) {
            throw ContentValidationError(diagnostics: semanticDiagnostics.sorted(by: diagnosticOrder))
        }

        // The manifest is derived from the compiled IR. The catalog declaration is
        // retained as an author-facing allowlist hint, but can never omit a
        // capability actually needed by the runtime.
        let derivedCapabilities = ContentCapabilityAnalyzer.requiredCapabilities(for: catalog)

        let assets = try compileAssets(
            sourceDirectory: sourceDirectory,
            catalog: catalog
        )
        return ContentCompilationResult(
            catalog: catalog,
            minAppBuild: catalogSource.minAppBuild,
            requiredCapabilities: derivedCapabilities.sorted(),
            publishedAt: catalogSource.publishedAt,
            assets: assets
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

    private func compileAssets(
        sourceDirectory: URL,
        catalog: CatalogDocumentV2
    ) throws -> [CompiledAsset] {
        var referencedPaths: Set<String> = []

        func collect(_ blocks: [LessonContentBlock]) {
            for block in blocks {
                switch block {
                case let .image(path, _, _):
                    referencedPaths.insert(path)
                case let .callout(_, _, _, body):
                    collect(body)
                default:
                    break
                }
            }
        }
        for lesson in catalog.lessons {
            collect(lesson.blocks)
        }

        var assets: [CompiledAsset] = []
        for path in referencedPaths.sorted() {
            guard CatalogSemanticValidator.isSafeImageAssetPath(path) else {
                throw diagnostic(
                    code: "asset.invalidPath",
                    message: "Referenced asset '\(path)' is not an allowed local image path.",
                    url: sourceDirectory.appending(path: path),
                    relativeTo: sourceDirectory,
                    line: 1
                )
            }
            let url = sourceDirectory.appending(path: path)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw diagnostic(
                    code: "asset.missing",
                    message: "Referenced asset '\(path)' does not exist.",
                    url: url,
                    relativeTo: sourceDirectory,
                    line: 1
                )
            }
            let values = try url.resourceValues(
                forKeys: [.fileSizeKey, .isRegularFileKey, .isSymbolicLinkKey]
            )
            guard values.isRegularFile == true, values.isSymbolicLink != true else {
                throw diagnostic(
                    code: "asset.invalidFile",
                    message: "Referenced asset '\(path)' must be a regular, non-symbolic-link file.",
                    url: url,
                    relativeTo: sourceDirectory,
                    line: 1
                )
            }
            guard let fileSize = values.fileSize,
                  fileSize > 0,
                  fileSize <= ContentPolicy.maximumImageAssetSize
            else {
                throw diagnostic(
                    code: "asset.invalidSize",
                    message: "Referenced asset '\(path)' must be 1...\(ContentPolicy.maximumImageAssetSize) bytes.",
                    url: url,
                    relativeTo: sourceDirectory,
                    line: 1
                )
            }
            let data = try Data(contentsOf: url)
            guard isValidImageSignature(data, extension: url.pathExtension.lowercased()) else {
                throw diagnostic(
                    code: "asset.invalidSignature",
                    message: "Referenced asset '\(path)' does not match its image extension.",
                    url: url,
                    relativeTo: sourceDirectory,
                    line: 1
                )
            }
            assets.append(CompiledAsset(path: path, data: data))
        }
        return assets
    }

    private func decodeYAML<Value: Decodable>(
        at url: URL,
        relativeTo sourceRoot: URL
    ) throws -> Value {
        let source = try readText(url)
        try validateSafeYAML(source, url: url, sourceRoot: sourceRoot)
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

    private func parseCard(
        at url: URL,
        sourceRoot: URL
    ) throws -> (Int, ReviewCardDefinition) {
        let source = try readText(url)
        let frontMatter = try splitFrontMatter(source, url: url, sourceRoot: sourceRoot)
        let metadata: ReviewCardSource = try decodeFrontMatter(
            frontMatter.yaml,
            as: ReviewCardSource.self,
            url: url,
            sourceRoot: sourceRoot
        )
        guard metadata.format == "learnnow.card/v1" else {
            throw diagnostic(
                code: "format.unsupported",
                message: "Expected format learnnow.card/v1.",
                url: url,
                relativeTo: sourceRoot,
                line: 1
            )
        }

        let document = Document(
            parsing: frontMatter.paddedBody,
            source: url,
            options: .parseBlockDirectives
        )
        var body: [InlineContent] = []
        var highlight: [InlineContent]?
        for child in document.children {
            if let paragraph = child as? Paragraph {
                appendParagraph(
                    try parseInline(paragraph, url: url, sourceRoot: sourceRoot),
                    to: &body
                )
            } else if let directive = child as? BlockDirective,
                      directive.name == "Highlight"
            {
                if highlight != nil {
                    throw markupDiagnostic(
                        code: "directive.duplicate",
                        message: "A card may contain only one @Highlight.",
                        markup: directive,
                        url: url,
                        sourceRoot: sourceRoot
                    )
                }
                highlight = try parseInlineBody(
                    directive,
                    url: url,
                    sourceRoot: sourceRoot
                )
            } else {
                throw markupDiagnostic(
                    code: "block.unsupported",
                    message: "Cards support paragraphs and one @Highlight directive.",
                    markup: child,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
        }
        guard !body.isEmpty, let highlight, !highlight.isEmpty else {
            throw diagnostic(
                code: "card.incomplete",
                message: "Card body and @Highlight are required.",
                url: url,
                relativeTo: sourceRoot,
                line: frontMatter.bodyStartLine
            )
        }

        return (
            metadata.order,
            ReviewCardDefinition(
                id: metadata.id,
                moduleID: metadata.moduleID,
                sourceLessonID: metadata.sourceLessonID,
                revision: metadata.revision,
                locale: metadata.locale,
                topic: metadata.topic,
                accent: metadata.accent,
                frontTitle: metadata.frontTitle,
                frontSubtitle: metadata.frontSubtitle,
                backTitle: metadata.backTitle,
                backBody: body,
                backHighlight: highlight
            )
        )
    }

    private func parseTip(
        at url: URL,
        sourceRoot: URL
    ) throws -> (Int, KnowledgeTipDefinition) {
        let source = try readText(url)
        let frontMatter = try splitFrontMatter(source, url: url, sourceRoot: sourceRoot)
        let metadata: KnowledgeTipSource = try decodeFrontMatter(
            frontMatter.yaml,
            as: KnowledgeTipSource.self,
            url: url,
            sourceRoot: sourceRoot
        )
        guard metadata.format == "learnnow.tip/v1" else {
            throw diagnostic(
                code: "format.unsupported",
                message: "Expected format learnnow.tip/v1.",
                url: url,
                relativeTo: sourceRoot,
                line: 1
            )
        }

        let document = Document(
            parsing: frontMatter.paddedBody,
            source: url,
            options: .parseBlockDirectives
        )
        var body: [InlineContent] = []
        for child in document.children {
            guard let paragraph = child as? Paragraph else {
                throw markupDiagnostic(
                    code: "block.unsupported",
                    message: "Tips support paragraph content only.",
                    markup: child,
                    url: url,
                    sourceRoot: sourceRoot
                )
            }
            appendParagraph(
                try parseInline(paragraph, url: url, sourceRoot: sourceRoot),
                to: &body
            )
        }
        guard !body.isEmpty else {
            throw diagnostic(
                code: "tip.incomplete",
                message: "Tip body is required.",
                url: url,
                relativeTo: sourceRoot,
                line: frontMatter.bodyStartLine
            )
        }

        return (
            metadata.order,
            KnowledgeTipDefinition(
                id: metadata.id,
                moduleID: metadata.moduleID,
                sourceLessonID: metadata.sourceLessonID,
                revision: metadata.revision,
                locale: metadata.locale,
                title: metadata.title,
                body: body,
                systemImage: metadata.systemImage,
                accent: metadata.accent
            )
        )
    }

    private func decodeFrontMatter<Value: Decodable>(
        _ yaml: String,
        as type: Value.Type,
        url: URL,
        sourceRoot: URL
    ) throws -> Value {
        try validateSafeYAML(yaml, url: url, sourceRoot: sourceRoot)
        do {
            return try YAMLDecoder().decode(type, from: yaml)
        } catch {
            throw diagnostic(
                code: "yaml.invalid",
                message: error.localizedDescription,
                url: url,
                relativeTo: sourceRoot,
                line: 2
            )
        }
    }

    private func validateSafeYAML(_ source: String, url: URL, sourceRoot: URL) throws {
        try validateSafeYAMLSource(source, url: url, sourceRoot: sourceRoot)
    }

    private func readText(_ url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        guard data.count <= Self.maximumSourceFileSize else {
            throw ContentValidationError(
                diagnostics: [
                    ContentDiagnostic(
                        severity: .error,
                        code: "file.tooLarge",
                        message: "Source file exceeds \(Self.maximumSourceFileSize) bytes.",
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

    private func sourceFiles(below directory: URL, extension: String) throws -> [URL] {
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        return enumerator.compactMap { $0 as? URL }
            .filter { $0.pathExtension.lowercased() == `extension` }
            .sorted { $0.path < $1.path }
    }
}

private struct CatalogSource: Decodable {
    let format: String
    let schemaVersion: Int
    let releaseVersion: String
    let locale: String
    let primaryRouteID: String
    let minAppBuild: Int
    let requiredCapabilities: [String]
    let publishedAt: String
    let retiredIDs: [String]
    let tracks: [TrackDefinition]
}

private struct RouteSource: Decodable {
    let order: Int
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let accent: ContentAccent
    let cta: String
    let interactive: Bool
    let trackIDs: [String]
    let moduleIDs: [String]
}

private struct ModuleSource: Decodable {
    let id: String
    let trackID: String
    let title: String
    let subtitle: String
    let lessonTitle: String
    let prerequisiteModuleIDs: [String]
    let completionXP: Int
    let reviewMessage: String
}

private struct LessonSource: Decodable {
    let format: String
    let id: String
    let module: String
    let order: Int
    let title: String
    let accent: ContentAccent
    let revision: Int
    let locale: String
    let objectives: [String]
}

private struct ReviewCardSource: Decodable {
    let format: String
    let order: Int
    let id: String
    let moduleID: String
    let sourceLessonID: String?
    let revision: Int
    let locale: String
    let topic: String
    let accent: ContentAccent
    let frontTitle: String
    let frontSubtitle: String?
    let backTitle: String
}

private struct KnowledgeTipSource: Decodable {
    let format: String
    let order: Int
    let id: String
    let moduleID: String?
    let sourceLessonID: String?
    let revision: Int
    let locale: String
    let title: String
    let systemImage: String
    let accent: ContentAccent
}

private struct FrontMatter {
    let yaml: String
    let paddedBody: String
    let bodyStartLine: Int
}

private struct LessonSourceParser {
    let url: URL
    let sourceRoot: URL

    func parse() throws -> (lesson: LessonDefinition, exercises: [ExerciseDefinition]) {
        let source = try readSource()
        let frontMatter = try splitFrontMatter(source, url: url, sourceRoot: sourceRoot)
        try validateSafeYAMLSource(frontMatter.yaml, url: url, sourceRoot: sourceRoot)
        let metadata: LessonSource
        do {
            metadata = try YAMLDecoder().decode(LessonSource.self, from: frontMatter.yaml)
        } catch {
            throw diagnostic(
                code: "yaml.invalid",
                message: error.localizedDescription,
                url: url,
                relativeTo: sourceRoot,
                line: 2
            )
        }
        guard metadata.format == "learnnow.lesson/v1" else {
            throw diagnostic(
                code: "format.unsupported",
                message: "Expected format learnnow.lesson/v1.",
                url: url,
                relativeTo: sourceRoot,
                line: 2
            )
        }

        let document = Document(
            parsing: frontMatter.paddedBody,
            source: url,
            options: .parseBlockDirectives
        )
        var exercises: [ExerciseDefinition] = []
        let blocks = try parseBlocks(
            document.children,
            lessonID: metadata.id,
            url: url,
            sourceRoot: sourceRoot,
            exercises: &exercises
        )
        return (
            LessonDefinition(
                id: metadata.id,
                moduleID: metadata.module,
                order: metadata.order,
                title: metadata.title,
                accent: metadata.accent,
                revision: metadata.revision,
                locale: metadata.locale,
                objectives: metadata.objectives,
                blocks: blocks
            ),
            exercises
        )
    }

    private func readSource() throws -> String {
        let data = try Data(contentsOf: url)
        guard data.count <= ContentCompiler.maximumSourceFileSize,
              let value = String(data: data, encoding: .utf8)
        else {
            throw diagnostic(
                code: "file.invalid",
                message: "Lesson must be UTF-8 and at most \(ContentCompiler.maximumSourceFileSize) bytes.",
                url: url,
                relativeTo: sourceRoot,
                line: 1
            )
        }
        return value
    }
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

private func splitFrontMatter(
    _ source: String,
    url: URL,
    sourceRoot: URL
) throws -> FrontMatter {
    let lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    guard lines.first == "---",
          let closingIndex = lines.dropFirst().firstIndex(where: { $0 == "---" })
    else {
        throw diagnostic(
            code: "frontMatter.missing",
            message: "Markdown source must begin with --- YAML front matter ---.",
            url: url,
            relativeTo: sourceRoot,
            line: 1
        )
    }
    let yaml = lines[1..<closingIndex].joined(separator: "\n")
    let bodyStart = closingIndex + 2
    let body = lines.dropFirst(closingIndex + 1).joined(separator: "\n")
    let paddedBody = String(repeating: "\n", count: closingIndex + 1) + body
    return FrontMatter(yaml: yaml, paddedBody: paddedBody, bodyStartLine: bodyStart)
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

private func orderThenID<Value: Identifiable>(
    _ left: (Int, Value),
    _ right: (Int, Value)
) -> Bool where Value.ID == String {
    if left.0 != right.0 { return left.0 < right.0 }
    return left.1.id < right.1.id
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
