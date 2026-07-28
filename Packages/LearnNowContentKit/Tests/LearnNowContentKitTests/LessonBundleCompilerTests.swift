import Foundation
import LearnNowContentAuthoring
import LearnNowContentKit
import XCTest

final class LessonBundleCompilerTests: XCTestCase {
    func testProjectArraysDefineRouteTrackLessonAndPageOrder() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }

        let catalog = try ContentCompiler().compile(sourceDirectory: source).catalog

        XCTAssertEqual(catalog.routes.map(\.id), ["route-one"])
        XCTAssertEqual(catalog.routes.first?.trackIDs, ["track-one"])
        XCTAssertEqual(catalog.routes.first?.moduleIDs, ["alpha", "beta"])
        XCTAssertEqual(catalog.modules.map(\.id), ["alpha", "beta"])
        XCTAssertEqual(
            catalog.lessons.map(\.id),
            ["alpha-page-2", "alpha-page-1", "beta-page-1"]
        )
        XCTAssertEqual(catalog.lessons.map(\.order), [1, 2, 1])
    }

    func testDefaultsCascadeThroughProjectRouteTrackAndLesson() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }

        let catalog = try ContentCompiler().compile(sourceDirectory: source).catalog
        let alphaPage = try XCTUnwrap(
            catalog.lessons.first { $0.id == "alpha-page-2" }
        )
        let betaPage = try XCTUnwrap(
            catalog.lessons.first { $0.id == "beta-page-1" }
        )
        let card = try XCTUnwrap(
            catalog.reviewCards.first { $0.id == "alpha-card-2" }
        )
        let tip = try XCTUnwrap(
            catalog.knowledgeTips.first { $0.id == "alpha-tip-2" }
        )
        let globalTip = try XCTUnwrap(
            catalog.knowledgeTips.first { $0.id == "global-tip" }
        )

        XCTAssertEqual(alphaPage.locale, "zh-Hans")
        XCTAssertEqual(alphaPage.accent, .purple)
        XCTAssertEqual(betaPage.accent, .mint)
        XCTAssertEqual(card.locale, "zh-Hans")
        XCTAssertEqual(card.accent, .blue)
        XCTAssertEqual(card.topic, "Track Topic")
        XCTAssertEqual(tip.locale, "zh-Hans")
        XCTAssertEqual(tip.accent, .amber)
        XCTAssertEqual(tip.systemImage, "chart.bar.xaxis")
        XCTAssertEqual(globalTip.accent, .amber)
        XCTAssertEqual(globalTip.systemImage, "lightbulb")
    }

    func testCardsTipsAndGlobalTipsAggregateInDeclarationOrder() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }

        let catalog = try ContentCompiler().compile(sourceDirectory: source).catalog

        XCTAssertEqual(
            catalog.reviewCards.map(\.id),
            ["alpha-card-2", "alpha-card-1"]
        )
        XCTAssertEqual(
            catalog.reviewCards.map(\.moduleID),
            ["alpha", "alpha"]
        )
        XCTAssertEqual(
            catalog.reviewCards.map(\.sourceLessonID),
            ["alpha-page-2", "alpha-page-1"]
        )
        XCTAssertEqual(
            catalog.knowledgeTips.map(\.id),
            ["alpha-tip-2", "alpha-tip-1", "global-tip"]
        )
        XCTAssertEqual(
            catalog.knowledgeTips.map(\.sourceLessonID),
            ["alpha-page-2", "alpha-page-1", nil]
        )
        XCTAssertNil(catalog.knowledgeTips.last?.moduleID)
    }

    func testMultipleCardAndTipFilesPreserveFileThenDeclarationOrder() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let manifestURL = source.appending(path: "lessons/alpha/lesson.yml")
        let manifest = try String(contentsOf: manifestURL, encoding: .utf8)
        try write(
            manifest
                .replacingOccurrences(
                    of: "cards:\n  - cards.md",
                    with: "cards:\n  - cards.md\n  - cards-extra.md"
                )
                .replacingOccurrences(
                    of: "tips:\n  - tips.md",
                    with: "tips:\n  - tips.md\n  - tips-extra.md"
                ),
            to: manifestURL
        )
        try write(
            """
            @Card(id: "alpha-card-extra", revision: 1, sourcePage: "alpha-page-1", frontTitle: "Extra", backTitle: "Remember") {
            Extra card body.

            @Highlight {
            Extra highlight.
            }
            }
            """,
            to: source.appending(path: "lessons/alpha/cards-extra.md")
        )
        try write(
            """
            @Tip(id: "alpha-tip-extra", revision: 1, sourcePage: "alpha-page-1", title: "Extra") {
            Extra tip body.
            }
            """,
            to: source.appending(path: "lessons/alpha/tips-extra.md")
        )

        let catalog = try ContentCompiler().compile(sourceDirectory: source).catalog

        XCTAssertEqual(
            catalog.reviewCards.map(\.id),
            ["alpha-card-2", "alpha-card-1", "alpha-card-extra"]
        )
        XCTAssertEqual(
            catalog.knowledgeTips.map(\.id),
            ["alpha-tip-2", "alpha-tip-1", "alpha-tip-extra", "global-tip"]
        )
    }

    func testMissingCardsAndTipsAreWarningsButDoNotFailLint() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }

        let diagnostics = ContentCompiler().lint(sourceDirectory: source)

        XCTAssertFalse(diagnostics.contains { $0.severity == .error })
        XCTAssertTrue(
            diagnostics.contains {
                $0.severity == .warning
                    && $0.code == "lesson.missingCards"
                    && $0.message.contains("beta")
            }
        )
        XCTAssertTrue(
            diagnostics.contains {
                $0.severity == .warning
                    && $0.code == "lesson.missingTips"
                    && $0.message.contains("beta")
            }
        )
    }

    func testDeclaredEmptyCardAndTipFilesAreWarningsNotErrors() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        try write("", to: source.appending(path: "lessons/alpha/cards.md"))
        try write("\n", to: source.appending(path: "lessons/alpha/tips.md"))

        let diagnostics = ContentCompiler().lint(sourceDirectory: source)
        XCTAssertFalse(
            diagnostics.contains { $0.severity == .error },
            diagnostics.map(\.description).joined(separator: "\n")
        )
        XCTAssertTrue(
            diagnostics.contains {
                $0.severity == .warning
                    && $0.code == "lesson.missingCards"
                    && $0.message.contains("alpha")
            }
        )
        XCTAssertTrue(
            diagnostics.contains {
                $0.severity == .warning
                    && $0.code == "lesson.missingTips"
                    && $0.message.contains("alpha")
            }
        )

        let catalog = try ContentCompiler().compile(sourceDirectory: source).catalog
        XCTAssertFalse(catalog.reviewCards.contains { $0.moduleID == "alpha" })
        XCTAssertFalse(catalog.knowledgeTips.contains { $0.moduleID == "alpha" })
    }

    func testDuplicateLessonMountIsRejected() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let projectURL = source.appending(path: "learnnow.yml")
        let project = try String(contentsOf: projectURL, encoding: .utf8)
        try write(
            project.replacingOccurrences(
                of: "          - lessons/beta/lesson.yml",
                with: "          - lessons/alpha/lesson.yml"
            ),
            to: projectURL
        )

        let diagnostics = ContentCompiler().lint(sourceDirectory: source)

        XCTAssertTrue(
            diagnostics.contains {
                $0.severity == .error && $0.code == "lesson.duplicateMount"
            }
        )
    }

    func testSourcePageMustBelongToTheLessonBundle() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let cardsURL = source.appending(path: "lessons/alpha/cards.md")
        let cards = try String(contentsOf: cardsURL, encoding: .utf8)
        try write(
            cards.replacingOccurrences(
                of: #"sourcePage: "alpha-page-2""#,
                with: #"sourcePage: "beta-page-1""#
            ),
            to: cardsURL
        )

        let diagnostics = ContentCompiler().lint(sourceDirectory: source)

        XCTAssertTrue(
            diagnostics.contains {
                $0.severity == .error
                    && $0.code == "reference.missing"
                    && $0.message.contains("beta-page-1")
            }
        )
    }

    func testLintAllFindsAndValidatesUnreferencedLessonBundles() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let draftDirectory = source.appending(path: "drafts/draft")
        try write(
            """
            format: learnnow.lesson-bundle/v1 # draft entry may use any filename
            id: draft
            title: Draft Lesson
            prerequisites: []
            completion:
              xp: 5
              message: Draft complete.
            pages:
              - id: draft-page-1
                title: Draft page
                source: page.md
                revision: 1
                objectives: [draft.objective]
            """,
            to: draftDirectory.appending(path: "learnnow.yml")
        )
        try write("Draft body.", to: draftDirectory.appending(path: "page.md"))

        let normalDiagnostics = ContentCompiler().lint(
            sourceDirectory: source,
            includeUnreferenced: false
        )
        let allDiagnostics = ContentCompiler().lint(
            sourceDirectory: source,
            includeUnreferenced: true
        )

        XCTAssertFalse(normalDiagnostics.contains { $0.code == "lesson.unreferenced" })
        XCTAssertTrue(
            allDiagnostics.contains {
                $0.severity == .warning
                    && $0.code == "lesson.unreferenced"
                    && $0.file.contains("draft")
            }
        )

        try write("@Mystery {\nInvalid draft body.\n}", to: draftDirectory.appending(path: "page.md"))
        XCTAssertFalse(
            ContentCompiler().lint(sourceDirectory: source)
                .contains { $0.file.contains("draft") && $0.severity == .error }
        )
        XCTAssertTrue(
            ContentCompiler().lint(
                sourceDirectory: source,
                includeUnreferenced: true
            )
            .contains { $0.file.contains("draft") && $0.severity == .error }
        )
    }

    func testLintAllValidatesDraftsAgainstThePublishedTree() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let draftDirectory = source.appending(path: "drafts/draft")
        try write(
            """
            format: learnnow.lesson-bundle/v1
            id: alpha
            title: Conflicting Draft
            prerequisites: [does-not-exist]
            completion:
              xp: 5
              message: Draft complete.
            pages:
              - id: draft-page-1
                title: Draft page
                source: page.md
                revision: 1
                objectives: [draft.objective]
            """,
            to: draftDirectory.appending(path: "lesson.yml")
        )
        try write("Draft body.", to: draftDirectory.appending(path: "page.md"))

        XCTAssertFalse(
            ContentCompiler().lint(sourceDirectory: source)
                .contains { $0.severity == .error && $0.file.contains("draft") }
        )

        let diagnostics = ContentCompiler().lint(
            sourceDirectory: source,
            includeUnreferenced: true
        )
        XCTAssertTrue(
            diagnostics.contains {
                $0.severity == .error
                    && $0.code == "id.duplicate"
                    && $0.message.contains("alpha")
            },
            diagnostics.map(\.description).joined(separator: "\n")
        )
        XCTAssertTrue(
            diagnostics.contains {
                $0.severity == .error
                    && $0.code == "reference.missing"
                    && $0.message.contains("does-not-exist")
            },
            diagnostics.map(\.description).joined(separator: "\n")
        )
    }

    func testLessonLocalImageIsNamespacedInCompiledAssets() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let pageURL = source.appending(path: "lessons/alpha/pages/second.md")
        let page = try String(contentsOf: pageURL, encoding: .utf8)
        try write(
            page + "\n\n@Image(path: \"assets/example.png\", alt: \"Example\")\n",
            to: pageURL
        )
        try write(
            validPNGHeader,
            to: source.appending(path: "lessons/alpha/assets/example.png")
        )

        let result = try ContentCompiler().compile(sourceDirectory: source)
        let lesson = try XCTUnwrap(
            result.catalog.lessons.first { $0.id == "alpha-page-2" }
        )
        let imagePath = try XCTUnwrap(
            lesson.blocks.compactMap { block -> String? in
                if case let .image(path, _, _) = block { return path }
                return nil
            }.first
        )

        XCTAssertEqual(imagePath, "assets/alpha/assets/example.png")
        XCTAssertEqual(result.assets.map(\.path), ["assets/alpha/assets/example.png"])
    }

    func testAssetOutputPathsRejectCaseInsensitiveCollisions() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let pageURL = source.appending(path: "lessons/alpha/pages/second.md")
        let page = try String(contentsOf: pageURL, encoding: .utf8)
        try write(
            page + """


            @Image(path: "assets/case.png", alt: "Lowercase")

            @Image(path: "assets/CASE.png", alt: "Uppercase")
            """,
            to: pageURL
        )
        try write(
            validPNGHeader,
            to: source.appending(path: "lessons/alpha/assets/case.png")
        )
        try write(
            validPNGHeader,
            to: source.appending(path: "lessons/alpha/assets/CASE.png")
        )

        let diagnostics = ContentCompiler().lint(sourceDirectory: source)
        XCTAssertTrue(
            diagnostics.contains {
                $0.severity == .error && $0.code == "asset.collision"
            },
            diagnostics.map(\.description).joined(separator: "\n")
        )
    }

    func testPagePathMayNotEscapeLessonBundle() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let manifestURL = source.appending(path: "lessons/alpha/lesson.yml")
        let manifest = try String(contentsOf: manifestURL, encoding: .utf8)
        try write(
            manifest.replacingOccurrences(
                of: "source: pages/second.md",
                with: "source: ../outside.md"
            ),
            to: manifestURL
        )
        try write("Outside body.", to: source.appending(path: "lessons/outside.md"))

        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: source)
                .contains { $0.code == "path.outsideBundle" }
        )
    }

    func testMissingManifestPageAndDeclaredResourceReportFileMissing() throws {
        let missingManifestSource = try makeSource()
        defer {
            try? FileManager.default.removeItem(
                at: missingManifestSource.deletingLastPathComponent()
            )
        }
        let projectURL = missingManifestSource.appending(path: "learnnow.yml")
        let project = try String(contentsOf: projectURL, encoding: .utf8)
        try write(
            project.replacingOccurrences(
                of: "lessons/beta/lesson.yml",
                with: "lessons/beta/missing.yml"
            ),
            to: projectURL
        )
        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: missingManifestSource)
                .contains { $0.code == "file.missing" }
        )

        let missingPageSource = try makeSource()
        defer {
            try? FileManager.default.removeItem(
                at: missingPageSource.deletingLastPathComponent()
            )
        }
        let manifestURL = missingPageSource.appending(path: "lessons/alpha/lesson.yml")
        let manifest = try String(contentsOf: manifestURL, encoding: .utf8)
        try write(
            manifest.replacingOccurrences(
                of: "source: pages/second.md",
                with: "source: pages/missing.md"
            ),
            to: manifestURL
        )
        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: missingPageSource)
                .contains { $0.code == "file.missing" }
        )

        let missingCardsSource = try makeSource()
        defer {
            try? FileManager.default.removeItem(
                at: missingCardsSource.deletingLastPathComponent()
            )
        }
        let resourceManifestURL = missingCardsSource
            .appending(path: "lessons/alpha/lesson.yml")
        let resourceManifest = try String(
            contentsOf: resourceManifestURL,
            encoding: .utf8
        )
        try write(
            resourceManifest.replacingOccurrences(
                of: "- cards.md",
                with: "- missing-cards.md"
            ),
            to: resourceManifestURL
        )
        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: missingCardsSource)
                .contains { $0.code == "file.missing" }
        )
    }

    func testSymbolicLinkPageIsRejected() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let manifestURL = source.appending(path: "lessons/alpha/lesson.yml")
        let manifest = try String(contentsOf: manifestURL, encoding: .utf8)
        try write(
            manifest.replacingOccurrences(
                of: "source: pages/second.md",
                with: "source: pages/link.md"
            ),
            to: manifestURL
        )
        try FileManager.default.createSymbolicLink(
            at: source.appending(path: "lessons/alpha/pages/link.md"),
            withDestinationURL: source.appending(path: "lessons/alpha/pages/second.md")
        )

        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: source)
                .contains { $0.code == "path.symbolicLink" }
        )
    }

    func testPageFrontMatterIsRejected() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let pageURL = source.appending(path: "lessons/alpha/pages/second.md")
        let page = try String(contentsOf: pageURL, encoding: .utf8)
        try write("---\ntitle: Hidden metadata\n---\n\n" + page, to: pageURL)

        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: source)
                .contains { $0.code == "frontMatter.forbidden" }
        )
    }

    func testUnknownFieldsAndLocaleOverridesAreRejected() throws {
        let unknownSource = try makeSource()
        defer {
            try? FileManager.default.removeItem(
                at: unknownSource.deletingLastPathComponent()
            )
        }
        let unknownManifestURL = unknownSource.appending(path: "lessons/alpha/lesson.yml")
        let unknownManifest = try String(
            contentsOf: unknownManifestURL,
            encoding: .utf8
        )
        try write(
            unknownManifest.replacingOccurrences(
                of: "title: Alpha Lesson",
                with: "title: Alpha Lesson\nunexpected: true"
            ),
            to: unknownManifestURL
        )
        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: unknownSource)
                .contains { $0.code == "yaml.unknownField" }
        )

        let localeSource = try makeSource()
        defer {
            try? FileManager.default.removeItem(
                at: localeSource.deletingLastPathComponent()
            )
        }
        let localeManifestURL = localeSource.appending(path: "lessons/alpha/lesson.yml")
        let localeManifest = try String(
            contentsOf: localeManifestURL,
            encoding: .utf8
        )
        try write(
            localeManifest.replacingOccurrences(
                of: "revision: 1\n    objectives: [alpha.second]",
                with: "revision: 1\n    locale: en\n    objectives: [alpha.second]"
            ),
            to: localeManifestURL
        )
        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: localeSource)
                .contains { $0.code == "locale.mismatch" }
        )
    }

    func testDefaultsRejectTypeConflictsAndNonInheritableArrays() throws {
        let typeConflictSource = try makeSource()
        defer {
            try? FileManager.default.removeItem(
                at: typeConflictSource.deletingLastPathComponent()
            )
        }
        let typeConflictProjectURL = typeConflictSource.appending(path: "learnnow.yml")
        let typeConflictProject = try String(
            contentsOf: typeConflictProjectURL,
            encoding: .utf8
        )
        try write(
            typeConflictProject.replacingOccurrences(
                of: """
                  page:
                    accent: blue
                """,
                with: "  page: blue"
            ),
            to: typeConflictProjectURL
        )
        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: typeConflictSource)
                .contains { $0.code == "yaml.typeConflict" }
        )

        let arraySource = try makeSource()
        defer {
            try? FileManager.default.removeItem(
                at: arraySource.deletingLastPathComponent()
            )
        }
        let arrayProjectURL = arraySource.appending(path: "learnnow.yml")
        let arrayProject = try String(contentsOf: arrayProjectURL, encoding: .utf8)
        try write(
            arrayProject.replacingOccurrences(
                of: "    accent: blue",
                with: "    accent: blue\n    objectives: [not-inheritable]"
            ),
            to: arrayProjectURL
        )
        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: arraySource)
                .contains { $0.code == "yaml.unknownField" }
        )
    }

    func testAuthorSourcesRejectDuplicateTrackIDsAndPrerequisiteCycles() throws {
        let duplicateTrackSource = try makeSource()
        defer {
            try? FileManager.default.removeItem(
                at: duplicateTrackSource.deletingLastPathComponent()
            )
        }
        let duplicateTrackProjectURL = duplicateTrackSource.appending(path: "learnnow.yml")
        let duplicateTrackProject = try String(
            contentsOf: duplicateTrackProjectURL,
            encoding: .utf8
        )
        try write(
            duplicateTrackProject.replacingOccurrences(
                of: "          - lessons/beta/lesson.yml",
                with: """
                          - lessons/beta/lesson.yml
                      - id: track-one
                        title: Duplicate Track
                        lessons: []
                """
            ),
            to: duplicateTrackProjectURL
        )
        let duplicateTrackDiagnostics = ContentCompiler().lint(
            sourceDirectory: duplicateTrackSource
        )
        XCTAssertTrue(
            duplicateTrackDiagnostics.contains {
                $0.code == "id.duplicate" && $0.message.contains("track-one")
            },
            duplicateTrackDiagnostics.map(\.description).joined(separator: "\n")
        )

        let cycleSource = try makeSource()
        defer {
            try? FileManager.default.removeItem(
                at: cycleSource.deletingLastPathComponent()
            )
        }
        let alphaManifestURL = cycleSource.appending(path: "lessons/alpha/lesson.yml")
        let alphaManifest = try String(contentsOf: alphaManifestURL, encoding: .utf8)
        try write(
            alphaManifest.replacingOccurrences(
                of: "prerequisites: []",
                with: "prerequisites: [beta]"
            ),
            to: alphaManifestURL
        )
        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: cycleSource)
                .contains { $0.code == "prerequisite.cycle" }
        )
    }

    func testLegacyCatalogEntryPointIsNotAccepted() throws {
        let source = try makeSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        try FileManager.default.moveItem(
            at: source.appending(path: "learnnow.yml"),
            to: source.appending(path: "catalog.yaml")
        )

        let diagnostics = ContentCompiler().lint(sourceDirectory: source)

        XCTAssertTrue(diagnostics.contains { $0.severity == .error })
        XCTAssertTrue(
            diagnostics.contains {
                $0.file.contains("learnnow.yml")
                    || $0.message.contains("learnnow.yml")
            }
        )
    }

    private func makeSource() throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appending(path: "learnnow-lesson-bundle-tests-\(UUID().uuidString)")
        let source = root.appending(path: "ContentSource")
        try write(projectSource, to: source.appending(path: "learnnow.yml"))
        try write(alphaManifest, to: source.appending(path: "lessons/alpha/lesson.yml"))
        try write("Second page.", to: source.appending(path: "lessons/alpha/pages/second.md"))
        try write("First page.", to: source.appending(path: "lessons/alpha/pages/first.md"))
        try write(alphaCards, to: source.appending(path: "lessons/alpha/cards.md"))
        try write(alphaTips, to: source.appending(path: "lessons/alpha/tips.md"))
        try write(betaManifest, to: source.appending(path: "lessons/beta/lesson.yml"))
        try write("Beta page.", to: source.appending(path: "lessons/beta/page.md"))
        try write(globalTips, to: source.appending(path: "shared/tips.md"))
        return source
    }

    private func write(_ text: String, to url: URL) throws {
        try write(Data(text.utf8), to: url)
    }

    private func write(_ data: Data, to url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: .atomic)
    }

    private let projectSource = """
    format: learnnow.project/v1
    schemaVersion: 2
    releaseVersion: "2026.07.28.2"
    locale: zh-Hans
    primaryRouteID: route-one
    minAppBuild: 1
    publishedAt: "2026-07-28T00:00:00Z"
    defaults:
      locale: zh-Hans
      page:
        accent: blue
      card:
        accent: mint
        topic: Project Topic
      tip:
        accent: amber
        systemImage: lightbulb
    routes:
      - id: route-one
        title: Route One
        subtitle: Explicit ordering
        systemImage: cpu
        accent: blue
        cta: Continue
        interactive: true
        defaults:
          page:
            accent: mint
        tracks:
          - id: track-one
            title: Track One
            defaults:
              card:
                topic: Track Topic
            lessons:
              - lessons/alpha/lesson.yml
              - lessons/beta/lesson.yml
    globalTips:
      - shared/tips.md
    """

    private let alphaManifest = """
    format: learnnow.lesson-bundle/v1
    id: alpha
    title: Alpha Lesson
    prerequisites: []
    completion:
      xp: 10
      message: Alpha complete.
    defaults:
      page:
        accent: purple
      card:
        accent: blue
      tip:
        systemImage: chart.bar.xaxis
    pages:
      - id: alpha-page-2
        title: Alpha second
        source: pages/second.md
        revision: 1
        objectives: [alpha.second]
      - id: alpha-page-1
        title: Alpha first
        source: pages/first.md
        revision: 1
        objectives: [alpha.first]
    cards:
      - cards.md
    tips:
      - tips.md
    """

    private let betaManifest = """
    format: learnnow.lesson-bundle/v1
    id: beta
    title: Beta Lesson
    prerequisites: [alpha]
    completion:
      xp: 10
      message: Beta complete.
    pages:
      - id: beta-page-1
        title: Beta first
        source: page.md
        revision: 1
        objectives: [beta.first]
    """

    private let alphaCards = """
    @Card(
      id: "alpha-card-2",
      revision: 1,
      sourcePage: "alpha-page-2",
      frontTitle: "Alpha second",
      backTitle: "Remember"
    ) {
    Second card body.

    @Highlight {
    Second highlight.
    }
    }

    @Card(
      id: "alpha-card-1",
      revision: 1,
      sourcePage: "alpha-page-1",
      frontTitle: "Alpha first",
      backTitle: "Remember"
    ) {
    First card body.

    @Highlight {
    First highlight.
    }
    }
    """

    private let alphaTips = """
    @Tip(
      id: "alpha-tip-2",
      revision: 1,
      sourcePage: "alpha-page-2",
      title: "Second tip"
    ) {
    Second tip body.
    }

    @Tip(
      id: "alpha-tip-1",
      revision: 1,
      sourcePage: "alpha-page-1",
      title: "First tip"
    ) {
    First tip body.
    }
    """

    private let globalTips = """
    @Tip(
      id: "global-tip",
      revision: 1,
      title: "Global tip"
    ) {
    Global tip body.
    }
    """

    private let validPNGHeader = Data([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    ])
}
