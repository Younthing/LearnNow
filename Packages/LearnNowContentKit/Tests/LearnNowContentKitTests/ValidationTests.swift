import CryptoKit
import Foundation
import LearnNowContentAuthoring
import LearnNowContentKit
import XCTest

final class ValidationTests: XCTestCase {
    func testDuplicateIDsMissingReferencesCyclesAndInvalidAnswersAreRejected() throws {
        let base = try compiledCatalog()

        let duplicate = replacing(base, routes: base.routes + [base.routes[0]])
        XCTAssertTrue(
            CatalogSemanticValidator.validate(duplicate).contains { $0.code == "id.duplicate" }
        )

        let duplicateModule = replacing(base, modules: base.modules + [base.modules[0]])
        XCTAssertTrue(
            CatalogSemanticValidator.validate(duplicateModule).contains {
                $0.code == "id.duplicate"
                    && $0.message.contains("module")
                    && $0.message.contains(base.modules[0].id)
            }
        )

        let route = RouteDefinition(
            id: base.routes[0].id,
            title: base.routes[0].title,
            subtitle: base.routes[0].subtitle,
            systemImage: base.routes[0].systemImage,
            accent: base.routes[0].accent,
            cta: base.routes[0].cta,
            interactive: base.routes[0].interactive,
            trackIDs: base.routes[0].trackIDs,
            moduleIDs: base.routes[0].moduleIDs + ["missing-module"]
        )
        let brokenReference = replacing(base, routes: [route] + base.routes.dropFirst())
        XCTAssertTrue(
            CatalogSemanticValidator.validate(brokenReference)
                .contains { $0.code == "reference.missing" }
        )

        let stats = replacing(base.modules[0], prerequisites: ["probability"])
        let cycle = replacing(base, modules: [stats] + base.modules.dropFirst())
        XCTAssertTrue(
            CatalogSemanticValidator.validate(cycle)
                .contains { $0.code == "prerequisite.cycle" }
        )

        let exercise = replacing(base.exercises[0], correctOptionID: "missing-option")
        let invalidAnswer = replacing(base, exercises: [exercise] + base.exercises.dropFirst())
        XCTAssertTrue(
            CatalogSemanticValidator.validate(invalidAnswer)
                .contains { $0.code == "answer.missing" }
        )
    }

    func testIllegalRemoteAndTraversalAssetsAreRejected() throws {
        let base = try compiledCatalog()
        let lesson = base.lessons[0]
        let traversal = replacing(
            lesson,
            blocks: lesson.blocks + [
                .image(path: "assets/../secret.png", alt: "secret", caption: nil),
                .image(path: "https://example.com/a.png", alt: "remote", caption: nil),
            ]
        )
        let catalog = replacing(base, lessons: [traversal] + base.lessons.dropFirst())
        XCTAssertEqual(
            CatalogSemanticValidator.validate(catalog)
                .filter { $0.code == "asset.invalidPath" }
                .count,
            2
        )
    }

    func testDiffFlagsCorrectAnswerAndMissingRetiredIDs() throws {
        let old = try compiledCatalog()
        let removedLessonID = old.lessons[0].id
        let removedCardID = old.reviewCards[0].id
        let changed = replacing(
            old.exercises[0],
            correctOptionID: old.exercises[0].options[1].id
        )
        let new = replacing(
            old,
            lessons: Array(old.lessons.dropFirst()),
            exercises: [changed] + old.exercises.dropFirst(),
            reviewCards: Array(old.reviewCards.dropFirst()),
            retiredIDs: []
        )

        let report = ContentDiffer.diff(old: old, new: new)
        XCTAssertEqual(report.changedCorrectAnswers, [changed.id])
        XCTAssertEqual(report.removedLessons, [removedLessonID])
        XCTAssertEqual(report.removedReviewCards, [removedCardID])
        XCTAssertTrue(report.riskNotes.contains { $0.contains("missing from retiredIDs") })
    }

    func testStrictDiffRequiresVersionIncreaseForAnyContentChange() throws {
        let old = try compiledCatalog()
        let route = old.routes[0]
        let changedRoute = RouteDefinition(
            id: route.id,
            title: route.title + "（更新）",
            subtitle: route.subtitle,
            systemImage: route.systemImage,
            accent: route.accent,
            cta: route.cta,
            interactive: route.interactive,
            trackIDs: route.trackIDs,
            moduleIDs: route.moduleIDs
        )
        let unchangedVersion = replacing(
            old,
            routes: [changedRoute] + old.routes.dropFirst()
        )
        XCTAssertTrue(
            ContentDiffer.diff(old: old, new: unchangedVersion).strictViolations
                .contains { $0.code == "release.notIncremented" }
        )

        let incrementedVersion = replacing(
            unchangedVersion,
            releaseVersion: "2026.7.28.3"
        )
        XCTAssertTrue(
            ContentDiffer.diff(old: old, new: incrementedVersion)
                .passesStrictReleaseChecks
        )
    }

    func testStrictDiffAlwaysRejectsReleaseVersionDowngrade() throws {
        let old = try compiledCatalog()
        let downgraded = replacing(old, releaseVersion: "2026.7.27.99")
        let report = ContentDiffer.diff(old: old, new: downgraded)

        XCTAssertTrue(
            report.strictViolations
                .contains { $0.code == "release.downgrade" }
        )
        XCTAssertTrue(report.hasChanges)
    }

    func testStrictDiffRejectsEquivalentReleaseVersionSpellingChange() throws {
        let old = try compiledCatalog()
        let equivalent = replacing(old, releaseVersion: "\(old.releaseVersion).0")

        XCTAssertTrue(
            ContentDiffer.diff(old: old, new: equivalent).strictViolations
                .contains { $0.code == "release.notIncremented" }
        )
    }

    func testStrictDiffRequiresVersionIncreaseForFullPackageChanges() throws {
        let catalog = try compiledCatalog()
        let oldManifest = manifest(for: catalog)
        let changedManifests = [
            manifest(for: catalog, compilerVersion: "2.0.1"),
            manifest(for: catalog, minAppBuild: 2),
            manifest(
                for: catalog,
                requiredCapabilities: ["paragraph", "singleChoice"]
            ),
            manifest(for: catalog, publishedAt: "2026-07-29T00:00:00Z"),
            manifest(
                for: catalog,
                files: [
                    ContentManifestFile(
                        path: "CatalogV2.json",
                        size: 2,
                        sha256: "changed-catalog-hash"
                    ),
                    ContentManifestFile(
                        path: "assets/example.png",
                        size: 4,
                        sha256: "changed-asset-hash"
                    ),
                ]
            ),
        ]

        for changedManifest in changedManifests {
            let report = ContentDiffer.diff(
                old: catalog,
                new: catalog,
                oldManifest: oldManifest,
                newManifest: changedManifest
            )
            XCTAssertEqual(report.packagePayloadChanged, true)
            XCTAssertTrue(
                report.strictViolations.contains { $0.code == "release.notIncremented" }
            )
        }
    }

    func testStrictDiffAcceptsFullPackageChangeAfterVersionIncrease() throws {
        let old = try compiledCatalog()
        let new = replacing(old, releaseVersion: "2026.7.28.3")

        let report = ContentDiffer.diff(
            old: old,
            new: new,
            oldManifest: manifest(for: old),
            newManifest: manifest(
                for: new,
                minAppBuild: 2,
                publishedAt: "2026-07-29T00:00:00Z"
            )
        )

        XCTAssertEqual(report.packagePayloadChanged, true)
        XCTAssertTrue(report.passesStrictReleaseChecks)
    }

    func testStrictDiffSafelyFallsBackWhenManifestBaselineIsUnavailable() throws {
        let catalog = try compiledCatalog()
        let report = ContentDiffer.diff(old: catalog, new: catalog)

        XCTAssertNil(report.packagePayloadChanged)
        XCTAssertTrue(report.passesStrictReleaseChecks)
    }

    func testStrictDiffRequiresEveryRemovedStableIDToBeRetired() throws {
        let old = try compiledCatalog()
        let removedTipID = try XCTUnwrap(old.knowledgeTips.first?.id)
        let new = replacing(
            old,
            releaseVersion: "2026.7.28.3",
            knowledgeTips: Array(old.knowledgeTips.dropFirst())
        )

        let report = ContentDiffer.diff(old: old, new: new)
        XCTAssertTrue(
            report.strictViolations.contains {
                $0.code == "retired.missing" && $0.message.contains(removedTipID)
            }
        )
    }

    func testStrictDiffPreventsDroppingOrReusingRetiredIDs() throws {
        let base = try compiledCatalog()
        let old = replacing(base, retiredIDs: ["legacy-content"])

        let dropped = replacing(
            old,
            releaseVersion: "2026.7.28.3",
            retiredIDs: []
        )
        XCTAssertTrue(
            ContentDiffer.diff(old: old, new: dropped).strictViolations
                .contains { $0.code == "retired.notAppendOnly" }
        )

        let reused = replacing(
            old,
            releaseVersion: "2026.7.28.3",
            tracks: old.tracks + [
                TrackDefinition(id: "legacy-content", title: "非法复用"),
            ],
            retiredIDs: ["legacy-content"]
        )
        XCTAssertTrue(
            ContentDiffer.diff(old: old, new: reused).strictViolations
                .contains { $0.code == "retired.reused" }
        )
    }

    func testLiveExerciseOptionCannotReuseARetiredID() throws {
        let base = try compiledCatalog()
        let optionID = try XCTUnwrap(base.exercises.first?.options.first?.id)
        let invalid = replacing(base, retiredIDs: [optionID])

        XCTAssertTrue(
            CatalogSemanticValidator.validate(invalid).contains {
                $0.code == "id.retiredAndLive" && $0.message.contains(optionID)
            }
        )
    }

    func testReleaseVersionUsesRemoteNumericDotOrdering() {
        XCTAssertLessThan(
            ContentReleaseVersion("1.2.9")!,
            ContentReleaseVersion("1.3")!
        )
        XCTAssertEqual(
            ContentReleaseVersion("1.2"),
            ContentReleaseVersion("1.2.0.0")
        )
        XCTAssertNil(ContentReleaseVersion("1..2"))
        XCTAssertNil(ContentReleaseVersion("v1"))
        XCTAssertNil(ContentReleaseVersion("18446744073709551616"))
    }

    func testManifestSignatureCoversKeyID() throws {
        let privateKey = Curve25519.Signing.PrivateKey()
        let manifest = ContentManifestV1(
            releaseVersion: "1",
            compilerVersion: "1",
            locale: "zh-Hans",
            minAppBuild: 1,
            requiredCapabilities: ["paragraph"],
            publishedAt: "2026-07-28T00:00:00Z",
            files: [
                ContentManifestFile(path: "CatalogV2.json", size: 2, sha256: "abcd"),
            ],
            retiredIDs: []
        )
        let signed = try ContentManifestSigner.sign(
            manifest,
            privateKeyRawRepresentation: privateKey.rawRepresentation,
            keyID: "content-2026"
        )
        XCTAssertTrue(
            try ContentManifestSigner.verify(
                signed,
                publicKeyRawRepresentation: privateKey.publicKey.rawRepresentation
            )
        )

        let tampered = ContentManifestV1(
            schemaVersion: signed.schemaVersion,
            releaseVersion: signed.releaseVersion,
            compilerVersion: signed.compilerVersion,
            locale: signed.locale,
            minAppBuild: signed.minAppBuild,
            requiredCapabilities: signed.requiredCapabilities,
            publishedAt: signed.publishedAt,
            files: signed.files,
            retiredIDs: signed.retiredIDs,
            keyID: "attacker-key",
            signature: signed.signature
        )
        XCTAssertFalse(
            try ContentManifestSigner.verify(
                tampered,
                publicKeyRawRepresentation: privateKey.publicKey.rawRepresentation
            )
        )
    }

    private func compiledCatalog() throws -> CatalogDocumentV2 {
        let repositoryRoot = URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try ContentCompiler()
            .compile(sourceDirectory: repositoryRoot.appending(path: "ContentSource"))
            .catalog
    }

    private func manifest(
        for catalog: CatalogDocumentV2,
        compilerVersion: String = ContentCompiler.compilerVersion,
        minAppBuild: Int = 1,
        requiredCapabilities: [String] = ["paragraph"],
        publishedAt: String = "2026-07-28T00:00:00Z",
        files: [ContentManifestFile] = [
            ContentManifestFile(
                path: "CatalogV2.json",
                size: 2,
                sha256: "catalog-hash"
            ),
        ]
    ) -> ContentManifestV1 {
        ContentManifestV1(
            releaseVersion: catalog.releaseVersion,
            compilerVersion: compilerVersion,
            locale: catalog.locale,
            minAppBuild: minAppBuild,
            requiredCapabilities: requiredCapabilities,
            publishedAt: publishedAt,
            files: files,
            retiredIDs: catalog.retiredIDs
        )
    }

    private func replacing(
        _ catalog: CatalogDocumentV2,
        releaseVersion: String? = nil,
        tracks: [TrackDefinition]? = nil,
        routes: [RouteDefinition]? = nil,
        modules: [ModuleDefinition]? = nil,
        lessons: [LessonDefinition]? = nil,
        exercises: [ExerciseDefinition]? = nil,
        reviewCards: [ReviewCardDefinition]? = nil,
        knowledgeTips: [KnowledgeTipDefinition]? = nil,
        retiredIDs: [String]? = nil
    ) -> CatalogDocumentV2 {
        CatalogDocumentV2(
            schemaVersion: catalog.schemaVersion,
            releaseVersion: releaseVersion ?? catalog.releaseVersion,
            locale: catalog.locale,
            primaryRouteID: catalog.primaryRouteID,
            tracks: tracks ?? catalog.tracks,
            routes: routes ?? catalog.routes,
            modules: modules ?? catalog.modules,
            lessons: lessons ?? catalog.lessons,
            exercises: exercises ?? catalog.exercises,
            reviewCards: reviewCards ?? catalog.reviewCards,
            knowledgeTips: knowledgeTips ?? catalog.knowledgeTips,
            retiredIDs: retiredIDs ?? catalog.retiredIDs
        )
    }

    private func replacing(
        _ module: ModuleDefinition,
        prerequisites: [String]
    ) -> ModuleDefinition {
        ModuleDefinition(
            id: module.id,
            trackID: module.trackID,
            title: module.title,
            subtitle: module.subtitle,
            lessonTitle: module.lessonTitle,
            prerequisiteModuleIDs: prerequisites,
            completionXP: module.completionXP,
            reviewMessage: module.reviewMessage
        )
    }

    private func replacing(
        _ exercise: ExerciseDefinition,
        correctOptionID: String
    ) -> ExerciseDefinition {
        ExerciseDefinition(
            id: exercise.id,
            lessonID: exercise.lessonID,
            kind: exercise.kind,
            prompt: exercise.prompt,
            options: exercise.options,
            correctOptionID: correctOptionID,
            correctFeedback: exercise.correctFeedback,
            incorrectFeedback: exercise.incorrectFeedback
        )
    }

    private func replacing(
        _ lesson: LessonDefinition,
        blocks: [LessonContentBlock]
    ) -> LessonDefinition {
        LessonDefinition(
            id: lesson.id,
            moduleID: lesson.moduleID,
            order: lesson.order,
            title: lesson.title,
            accent: lesson.accent,
            revision: lesson.revision,
            locale: lesson.locale,
            objectives: lesson.objectives,
            blocks: blocks
        )
    }
}
