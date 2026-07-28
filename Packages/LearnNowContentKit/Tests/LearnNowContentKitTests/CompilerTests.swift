import Foundation
import LearnNowContentAuthoring
import LearnNowContentKit
import XCTest

final class CompilerTests: XCTestCase {
    func testLessonBundleMigrationPreservesCompleteCatalogSemantics() throws {
        let catalog = try ContentCompiler().compile(sourceDirectory: contentSourceURL).catalog
        let encoded = try DeterministicJSON.encode(catalog, prettyPrinted: false)
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )

        // The authoring refactor intentionally changes the release version and
        // emits lesson-owned tips in lesson order. Normalize only those two
        // representation details before comparing with the pre-migration V2 golden.
        object["releaseVersion"] = "migration-golden"
        var tips = try XCTUnwrap(object["knowledgeTips"] as? [[String: Any]])
        tips.sort {
            ($0["id"] as? String ?? "") < ($1["id"] as? String ?? "")
        }
        object["knowledgeTips"] = tips

        let normalized = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys]
        )
        XCTAssertEqual(
            ContentDigest.sha256Hex(of: normalized),
            "475175bc47082a2846fde16408f5cc430da6d9382ab80afdad7ca3945a52ec65"
        )
    }

    func testMigratedContentPreservesEveryV1StableID() throws {
        let catalog = try ContentCompiler().compile(sourceDirectory: contentSourceURL).catalog
        let v1 = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: Data(
                    contentsOf: repositoryRoot.appending(
                        path: "Packages/LearnNowContentKit/Fixtures/CatalogV1.json"
                    )
                )
            ) as? [String: Any]
        )

        let v1Routes = try dictionaries(v1["routes"])
        let v1Modules = try dictionaries(v1["modules"])
        let v1Cards = try dictionaries(v1["reviewCards"])
        let v1Tips = try dictionaries(v1["dailyTips"])
        let v1Pages = try v1Modules.flatMap { try dictionaries($0["pages"]) }
        let v1Options = try v1Pages.flatMap { page -> [[String: Any]] in
            let quiz = try XCTUnwrap(page["quiz"] as? [String: Any])
            return try dictionaries(quiz["options"])
        }

        XCTAssertEqual(Set(try ids(v1Routes)), Set(catalog.routes.map(\.id)))
        XCTAssertEqual(Set(try ids(v1Modules)), Set(catalog.modules.map(\.id)))
        XCTAssertEqual(Set(try ids(v1Pages)), Set(catalog.lessons.map(\.id)))
        XCTAssertEqual(Set(try ids(v1Cards)), Set(catalog.reviewCards.map(\.id)))
        XCTAssertEqual(Set(try ids(v1Tips)), Set(catalog.knowledgeTips.map(\.id)))
        XCTAssertEqual(
            Set(try ids(v1Options)),
            Set(catalog.exercises.flatMap { $0.options.map(\.id) })
        )
    }

    func testTwoBuildsAreByteForByteIdentical() throws {
        let first = temporaryDirectory()
        let second = temporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: first)
            try? FileManager.default.removeItem(at: second)
        }

        let compiler = ContentCompiler()
        let result = try compiler.compile(sourceDirectory: contentSourceURL)
        let firstArtifacts = try compiler.build(
            sourceDirectory: contentSourceURL,
            outputDirectory: first
        )
        XCTAssertEqual(
            try compiler.makeManifest(for: result),
            firstArtifacts.manifest
        )
        _ = try compiler.build(sourceDirectory: contentSourceURL, outputDirectory: second)
        let staleAsset = first.appending(path: "assets/stale.png")
        try FileManager.default.createDirectory(
            at: staleAsset.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try validPNGHeader.write(to: staleAsset)
        _ = try compiler.build(sourceDirectory: contentSourceURL, outputDirectory: first)
        XCTAssertFalse(FileManager.default.fileExists(atPath: staleAsset.path))

        for filename in ["CatalogV2.json", "ContentManifest.json", "CatalogV2.schema.json"] {
            XCTAssertEqual(
                try Data(contentsOf: first.appending(path: filename)),
                try Data(contentsOf: second.appending(path: filename)),
                "\(filename) was not deterministic"
            )
        }
    }

    func testDSLCompilesEveryV1BlockAndSafeInlineStyle() throws {
        let source = try copiedContentSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let lessonURL = source.appending(path: "lessons/stats/pages/mean.md")
        try Data(allBlocksLesson.utf8).write(to: lessonURL, options: .atomic)
        try FileManager.default.createDirectory(
            at: source.appending(path: "lessons/stats/assets"),
            withIntermediateDirectories: true
        )
        try validPNGHeader.write(
            to: source.appending(path: "lessons/stats/assets/example.png"),
            options: .atomic
        )

        let result = try ContentCompiler().compile(sourceDirectory: source)
        let catalog = result.catalog
        let lesson = try XCTUnwrap(catalog.lessons.first { $0.id == "stats-page-1" })

        XCTAssertTrue(lesson.blocks.contains { if case .heading = $0 { true } else { false } })
        XCTAssertTrue(lesson.blocks.contains { if case .paragraph = $0 { true } else { false } })
        XCTAssertTrue(lesson.blocks.contains { if case .list = $0 { true } else { false } })
        XCTAssertTrue(lesson.blocks.contains { if case .callout = $0 { true } else { false } })
        XCTAssertTrue(lesson.blocks.contains { if case .code = $0 { true } else { false } })
        XCTAssertTrue(lesson.blocks.contains { if case .image = $0 { true } else { false } })
        XCTAssertTrue(lesson.blocks.contains { if case .singleChoice = $0 { true } else { false } })
        XCTAssertEqual(
            Set(result.requiredCapabilities),
            [
                "callout",
                "code",
                "heading",
                "image",
                "inlineCode",
                "inlineEmphasis",
                "inlineStrong",
                "list",
                "paragraph",
                "singleChoice",
            ]
        )
    }

    func testUnknownDirectiveReportsFileAndLine() throws {
        let source = try copiedContentSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let lessonURL = source.appending(path: "lessons/stats/pages/mean.md")
        let original = try String(contentsOf: lessonURL, encoding: .utf8)
        try Data(original.replacingOccurrences(of: "@Callout", with: "@Mystery").utf8)
            .write(to: lessonURL, options: .atomic)

        let diagnostics = ContentCompiler().lint(sourceDirectory: source)
        let issue = try XCTUnwrap(diagnostics.first { $0.code == "directive.unknown" })
        XCTAssertEqual(issue.file, "lessons/stats/pages/mean.md")
        XCTAssertNotNil(issue.line)
    }

    func testMissingFeedbackFailsAtQuizLine() throws {
        let source = try copiedContentSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let lessonURL = source.appending(path: "lessons/stats/pages/mean.md")
        let broken = allBlocksLesson.replacingOccurrences(
            of: """

            @Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
            重新比较两个选项。
            }
            """,
            with: ""
        )
        try Data(broken.utf8).write(to: lessonURL, options: .atomic)
        try FileManager.default.createDirectory(
            at: source.appending(path: "lessons/stats/assets"),
            withIntermediateDirectories: true
        )
        try validPNGHeader.write(
            to: source.appending(path: "lessons/stats/assets/example.png"),
            options: .atomic
        )

        let diagnostics = ContentCompiler().lint(sourceDirectory: source)
        XCTAssertTrue(diagnostics.contains { $0.code == "quiz.missingFeedback" })
    }

    func testYAMLAnchorsAliasesAndTagsAreRejected() throws {
        let source = try copiedContentSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let catalogURL = source.appending(path: "learnnow.yml")
        var catalogText = try String(contentsOf: catalogURL, encoding: .utf8)
        catalogText += "\nunsafe: &shared value\n"
        try Data(catalogText.utf8).write(to: catalogURL, options: .atomic)

        let diagnostics = ContentCompiler().lint(sourceDirectory: source)
        XCTAssertTrue(diagnostics.contains { $0.code == "yaml.unsafeFeature" })
    }

    func testDuplicateLessonIDProducesDiagnosticInsteadOfTrap() throws {
        let source = try copiedContentSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let manifestURL = source.appending(path: "lessons/probability/lesson.yml")
        let manifest = try String(contentsOf: manifestURL, encoding: .utf8)
        try Data(
            manifest.replacingOccurrences(
                of: "\nid: probability\n",
                with: "\nid: stats\n"
            ).utf8
        )
        .write(to: manifestURL, options: .atomic)

        let diagnostics = ContentCompiler().lint(sourceDirectory: source)
        XCTAssertTrue(
            diagnostics.contains {
                $0.code == "id.duplicate" && $0.message.contains("stats")
            },
            diagnostics.map(\.description).joined(separator: "\n")
        )
    }

    func testDuplicateDirectiveArgumentProducesDiagnosticInsteadOfTrap() throws {
        let source = try copiedContentSource()
        defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
        let lessonURL = source.appending(path: "lessons/stats/pages/mean.md")
        let original = try String(contentsOf: lessonURL, encoding: .utf8)
        let broken = original.replacingOccurrences(
            of: #"@Callout(title: "核心认知""#,
            with: #"@Callout(title: "重复", title: "核心认知""#
        )
        try Data(broken.utf8).write(to: lessonURL, options: .atomic)

        let diagnostics = ContentCompiler().lint(sourceDirectory: source)
        XCTAssertTrue(
            diagnostics.contains {
                $0.code == "directive.duplicateArgument"
                    || $0.code == "directive.invalidArguments"
            }
        )
    }

    func testInvalidReleaseVersionsAreRejectedBeforeBuild() throws {
        for invalidVersion in ["1..2", "v1.2", "1.-2", "18446744073709551616"] {
            let source = try copiedContentSource()
            defer { try? FileManager.default.removeItem(at: source.deletingLastPathComponent()) }
            let catalogURL = source.appending(path: "learnnow.yml")
            let original = try String(contentsOf: catalogURL, encoding: .utf8)
            let broken = original.replacingOccurrences(
                of: #"releaseVersion: "2026.07.28.2""#,
                with: #"releaseVersion: "\#(invalidVersion)""#
            )
            try Data(broken.utf8).write(to: catalogURL, options: .atomic)

            XCTAssertTrue(
                ContentCompiler().lint(sourceDirectory: source)
                    .contains { $0.code == "release.invalid" },
                invalidVersion
            )
        }
    }

    func testImageExtensionSignatureAndSizeAreValidated() throws {
        let badExtensionSource = try sourceWithImage(
            path: "assets/example.svg",
            data: Data("<svg/>".utf8)
        )
        defer {
            try? FileManager.default.removeItem(
                at: badExtensionSource.deletingLastPathComponent()
            )
        }
        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: badExtensionSource)
                .contains { $0.code == "asset.invalidExtension" }
        )

        let badSignatureSource = try sourceWithImage(
            path: "assets/example.png",
            data: Data("not a png".utf8)
        )
        defer {
            try? FileManager.default.removeItem(
                at: badSignatureSource.deletingLastPathComponent()
            )
        }
        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: badSignatureSource)
                .contains { $0.code == "asset.invalidSignature" }
        )

        let oversizedSource = try sourceWithImage(
            path: "assets/example.png",
            data: Data(
                repeating: 0,
                count: ContentPolicy.maximumImageAssetSize + 1
            )
        )
        defer {
            try? FileManager.default.removeItem(
                at: oversizedSource.deletingLastPathComponent()
            )
        }
        XCTAssertTrue(
            ContentCompiler().lint(sourceDirectory: oversizedSource)
                .contains { $0.code == "asset.invalidSize" }
        )
    }

    private var repositoryRoot: URL {
        URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private var contentSourceURL: URL {
        repositoryRoot.appending(path: "ContentSource")
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appending(path: "learnnow-content-tests-\(UUID().uuidString)")
    }

    private func copiedContentSource() throws -> URL {
        let root = temporaryDirectory()
        let destination = root.appending(path: "ContentSource")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: contentSourceURL, to: destination)
        return destination
    }

    private func sourceWithImage(path: String, data: Data) throws -> URL {
        let source = try copiedContentSource()
        let lessonURL = source.appending(path: "lessons/stats/pages/mean.md")
        let original = try String(contentsOf: lessonURL, encoding: .utf8)
        let image = #"""

        @Image(path: "\#(path)", alt: "测试图片")
        """#
        try Data((original + image).utf8).write(to: lessonURL, options: .atomic)
        try FileManager.default.createDirectory(
            at: source.appending(path: "lessons/stats/\(path)")
                .deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(
            to: source.appending(path: "lessons/stats/\(path)"),
            options: .atomic
        )
        return source
    }

    private func dictionaries(_ value: Any?) throws -> [[String: Any]] {
        try XCTUnwrap(value as? [[String: Any]])
    }

    private func ids(_ dictionaries: [[String: Any]]) throws -> [String] {
        try dictionaries.map { try XCTUnwrap($0["id"] as? String) }
    }

    private let allBlocksLesson = """
    # 标题

    普通文本、**重点**、*强调*和 `inline code`。

    - 第一项
    - 第二项

    @Callout(title: "核心认知", tone: "warning", accent: "amber") {
    Callout 正文。
    }

    ```swift
    let mean = values.reduce(0, +) / values.count
    ```

    @Image(path: "assets/example.png", alt: "示例图", caption: "图注")

    @Quiz(id: "stats-page-1.quiz", kind: "singleChoice") {
    正确答案是哪一个？

    @Option(id: "mean-rises", correct: true) {
    第一项
    }

    @Option(id: "mean-fixed") {
    第二项
    }

    @Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
    第一项是正确答案。
    }

    @Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
    重新比较两个选项。
    }
    }
    """

    private let validPNGHeader = Data([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    ])
}
