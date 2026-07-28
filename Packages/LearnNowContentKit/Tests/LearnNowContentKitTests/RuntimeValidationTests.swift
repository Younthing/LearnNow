import LearnNowContentAuthoring
import LearnNowContentKit
import XCTest

final class RuntimeValidationTests: XCTestCase {
    func testOptionFeedbackCannotOverrideFallbackWithEmptyContent() throws {
        let repositoryRoot = URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let catalog = try ContentCompiler()
            .compile(sourceDirectory: repositoryRoot.appending(path: "ContentSource"))
            .catalog
        let originalExercise = try XCTUnwrap(catalog.exercises.first)
        let originalOption = try XCTUnwrap(originalExercise.options.first)
        let invalidOption = ExerciseOptionDefinition(
            id: originalOption.id,
            content: originalOption.content,
            feedback: FeedbackDefinition(
                title: "",
                body: [],
                tone: .warning,
                accent: .amber
            )
        )
        let invalidExercise = ExerciseDefinition(
            id: originalExercise.id,
            lessonID: originalExercise.lessonID,
            kind: originalExercise.kind,
            prompt: originalExercise.prompt,
            options: [invalidOption] + originalExercise.options.dropFirst(),
            correctOptionID: originalExercise.correctOptionID,
            correctFeedback: originalExercise.correctFeedback,
            incorrectFeedback: originalExercise.incorrectFeedback
        )
        let invalidCatalog = CatalogDocumentV2(
            schemaVersion: catalog.schemaVersion,
            releaseVersion: catalog.releaseVersion,
            locale: catalog.locale,
            primaryRouteID: catalog.primaryRouteID,
            tracks: catalog.tracks,
            routes: catalog.routes,
            modules: catalog.modules,
            lessons: catalog.lessons,
            exercises: [invalidExercise] + catalog.exercises.dropFirst(),
            reviewCards: catalog.reviewCards,
            knowledgeTips: catalog.knowledgeTips,
            retiredIDs: catalog.retiredIDs
        )

        XCTAssertTrue(
            CatalogSemanticValidator.validate(invalidCatalog).contains {
                $0.code == "feedback.empty"
                    && $0.message.contains(originalOption.id)
            }
        )
    }
}
