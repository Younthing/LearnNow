import CryptoKit
import Foundation
import LearnNowContentKit
import Testing
@testable import LearnNow

@MainActor
struct ContentUpdateTests {
    @Test
    func missingRemoteConfigurationUsesBundleAndDisablesRefresh() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let repository = ContentUpdateCatalogRepository(
            bundleCatalogURL: fixture.bundleURL,
            storageRootURL: fixture.storeURL,
            configuration: .disabled(
                appBuild: 1,
                supportedCapabilities: ContentPolicy.supportedCapabilities
            )
        )

        #expect(try await repository.load().releaseVersion == "1")
        #expect(await repository.refresh() == .disabled)
    }

    @Test
    func validPackageActivatesAndThenUsesETag304() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let package = try fixture.package(releaseVersion: "2")
        let transport = TestContentTransport(steps: [
            .response(package.response(etag: #""release-2""#), files: package.files),
            .response(
                ContentManifestTransportResponse(
                    statusCode: 304,
                    data: Data(),
                    etag: #""release-2""#,
                    finalURL: fixture.manifestURL
                ),
                files: [:]
            ),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(await repository.refresh() == .activated(releaseVersion: "2"))
        let loaded = try await repository.load()
        #expect(loaded.releaseVersion == "2")
        #expect(loaded.contentRootURL?.lastPathComponent == package.manifestDigest)
        #expect(await repository.refresh() == .notModified)
        #expect(await transport.requestedETags() == [nil, #""release-2""#])
    }

    @Test
    func transportFailureDoesNotReplaceCurrentCatalog() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let transport = TestContentTransport(steps: [.failure])
        let repository = fixture.repository(transport: transport)

        #expect(await repository.refresh() == .transportFailure)
        #expect(try await repository.load().releaseVersion == "1")
    }

    @Test
    func invalidSignatureDoesNotReplaceCurrentCatalog() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let wrongKey = Curve25519.Signing.PrivateKey()
        let package = try fixture.package(
            releaseVersion: "2",
            signingKey: wrongKey
        )
        let transport = TestContentTransport(steps: [
            .response(package.response(), files: package.files),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(
            await repository.refresh() ==
                .rejected(.invalidSignature)
        )
        #expect(try await repository.load().releaseVersion == "1")
        #expect(await transport.downloadedPaths().isEmpty)
    }

    @Test
    func digestMismatchLeavesLastKnownGoodActive() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let release2 = try fixture.package(releaseVersion: "2")
        let release3 = try fixture.package(releaseVersion: "3")
        var corruptedFiles = release3.files
        var corruptedCatalog = try #require(corruptedFiles["CatalogV2.json"])
        corruptedCatalog[corruptedCatalog.startIndex] ^= 0x01
        corruptedFiles["CatalogV2.json"] = corruptedCatalog
        let transport = TestContentTransport(steps: [
            .response(release2.response(), files: release2.files),
            .response(release3.response(), files: corruptedFiles),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(await repository.refresh() == .activated(releaseVersion: "2"))
        #expect(
            await repository.refresh() ==
                .rejected(.downloadedDigestMismatch)
        )
        #expect(try await repository.load().releaseVersion == "2")
    }

    @Test
    func interruptedDownloadLeavesLastKnownGoodAndCleansStaging() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let release2 = try fixture.package(releaseVersion: "2")
        let release3 = try fixture.package(releaseVersion: "3")
        let transport = TestContentTransport(steps: [
            .response(release2.response(), files: release2.files),
            .responseWithInterruptedDownload(
                release3.response(),
                files: release3.files,
                path: "CatalogV2.json"
            ),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(await repository.refresh() == .activated(releaseVersion: "2"))
        #expect(await repository.refresh() == .transportFailure)
        let loaded = try await repository.load()
        #expect(loaded.releaseVersion == "2")
        #expect(loaded.contentRootURL?.lastPathComponent == release2.manifestDigest)

        let stagingURL = fixture.storeURL.appendingPathComponent("staging")
        let stagingItems = try FileManager.default.contentsOfDirectory(
            at: stagingURL,
            includingPropertiesForKeys: nil
        )
        #expect(stagingItems.isEmpty)
    }

    @Test
    func unsupportedManifestSchemaIsRejectedBeforeDownloads() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let package = try fixture.package(
            releaseVersion: "2",
            manifestSchemaVersion: 99
        )
        let transport = TestContentTransport(steps: [
            .response(package.response(), files: package.files),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(
            await repository.refresh() ==
                .rejected(.unsupportedManifestSchema)
        )
        #expect(await transport.downloadedPaths().isEmpty)
        #expect(try await repository.load().releaseVersion == "1")
    }

    @Test
    func buildAndCapabilityIncompatibilitiesAreRejectedBeforeDownloads() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let tooNew = try fixture.package(
            releaseVersion: "2",
            minimumAppBuild: 2
        )
        let futureCapability = try fixture.package(
            releaseVersion: "3",
            requiredCapabilities: ["paragraph", "futureBlock"]
        )
        let transport = TestContentTransport(steps: [
            .response(tooNew.response(), files: tooNew.files),
            .response(futureCapability.response(), files: futureCapability.files),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(
            await repository.refresh() ==
                .rejected(.incompatibleAppBuild)
        )
        #expect(
            await repository.refresh() ==
                .rejected(.unsupportedCapabilities)
        )
        #expect(await transport.downloadedPaths().isEmpty)
    }

    @Test
    func optionFeedbackInlineCapabilitiesMustBeDeclared() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let package = try fixture.package(
            releaseVersion: "2",
            requiredCapabilities: [
                "paragraph",
                "singleChoice",
                "inlineStrong",
                "inlineEmphasis",
            ],
            catalogTransform: { document in
                document.addingExerciseWithNestedOptionFeedback()
            }
        )
        let transport = TestContentTransport(steps: [
            .response(package.response(), files: package.files),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(
            await repository.refresh() ==
                .rejected(.unsupportedCapabilities)
        )
        #expect(await transport.downloadedPaths() == ["CatalogV2.json"])
        #expect(try await repository.load().releaseVersion == "1")
    }

    @Test
    func unsafePathAndPackageLimitsAreRejected() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let unsafe = try fixture.package(
            releaseVersion: "2",
            manifestFileTransform: { files in
                var files = files
                let catalog = files.removeFirst()
                files.insert(
                    ContentManifestFile(
                        path: "../CatalogV2.json",
                        size: catalog.size,
                        sha256: catalog.sha256
                    ),
                    at: 0
                )
                return files
            }
        )
        let imagePackage = try fixture.package(
            releaseVersion: "3",
            imageData: Data("shared-image".utf8)
        )
        let transport = TestContentTransport(steps: [
            .response(unsafe.response(), files: unsafe.files),
            .response(imagePackage.response(), files: imagePackage.files),
        ])
        let strictLimits = ContentUpdateLimits(
            maximumManifestBytes: 128 * 1_024,
            maximumFileCount: 1,
            maximumFileBytes: 24 * 1_024 * 1_024,
            maximumTotalBytes: 96 * 1_024 * 1_024
        )
        let repository = fixture.repository(
            transport: transport,
            limits: strictLimits
        )

        #expect(await repository.refresh() == .rejected(.unsafeFilePath))
        #expect(await repository.refresh() == .rejected(.tooManyFiles))
        #expect(await transport.downloadedPaths().isEmpty)
    }

    @Test
    func manifestRejectsQueryCharactersAndUnsupportedImageExtensions() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let queryPath = try fixture.package(
            releaseVersion: "2",
            manifestFileTransform: { files in
                files.map { file in
                    guard file.path == "CatalogV2.json" else { return file }
                    return ContentManifestFile(
                        path: "CatalogV2.json?download=1",
                        size: file.size,
                        sha256: file.sha256
                    )
                }
            }
        )
        let unsupportedImage = try fixture.package(
            releaseVersion: "3",
            imageData: Data("not-a-supported-image".utf8),
            manifestFileTransform: { files in
                files.map { file in
                    guard file.path == "assets/shared.png" else { return file }
                    return ContentManifestFile(
                        path: "assets/shared.svg",
                        size: file.size,
                        sha256: file.sha256
                    )
                }
            }
        )
        let transport = TestContentTransport(steps: [
            .response(queryPath.response(), files: queryPath.files),
            .response(unsupportedImage.response(), files: unsupportedImage.files),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(await repository.refresh() == .rejected(.unsafeFilePath))
        #expect(await repository.refresh() == .rejected(.unsafeFilePath))
        #expect(await transport.downloadedPaths().isEmpty)
    }

    @Test
    func catalogImageMustBePresentInManifest() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let package = try fixture.package(
            releaseVersion: "2",
            imageData: Data("image".utf8),
            manifestFileTransform: { files in
                files.filter { $0.path == "CatalogV2.json" }
            }
        )
        let transport = TestContentTransport(steps: [
            .response(package.response(), files: package.files),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(await repository.refresh() == .rejected(.missingImageAsset))
        #expect(try await repository.load().releaseVersion == "1")
    }

    @Test
    func corruptActiveReleaseFallsBackToPreviousRelease() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let release2 = try fixture.package(releaseVersion: "2")
        let release3 = try fixture.package(releaseVersion: "3")
        let transport = TestContentTransport(steps: [
            .response(release2.response(), files: release2.files),
            .response(release3.response(), files: release3.files),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(await repository.refresh() == .activated(releaseVersion: "2"))
        #expect(await repository.refresh() == .activated(releaseVersion: "3"))
        let corruptURL = fixture.storeURL
            .appendingPathComponent("releases")
            .appendingPathComponent(release3.manifestDigest)
            .appendingPathComponent("CatalogV2.json")
        try Data("corrupt".utf8).write(to: corruptURL, options: .atomic)

        let loaded = try await repository.load()
        #expect(loaded.releaseVersion == "2")
        #expect(loaded.contentRootURL?.lastPathComponent == release2.manifestDigest)
    }

    @Test
    func corruptActiveAndPreviousReleasesFallBackToBundle() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let release2 = try fixture.package(releaseVersion: "2")
        let release3 = try fixture.package(releaseVersion: "3")
        let transport = TestContentTransport(steps: [
            .response(release2.response(), files: release2.files),
            .response(release3.response(), files: release3.files),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(await repository.refresh() == .activated(releaseVersion: "2"))
        #expect(await repository.refresh() == .activated(releaseVersion: "3"))
        for digest in [release2.manifestDigest, release3.manifestDigest] {
            let catalogURL = fixture.storeURL
                .appendingPathComponent("releases")
                .appendingPathComponent(digest)
                .appendingPathComponent("CatalogV2.json")
            try Data("corrupt".utf8).write(to: catalogURL, options: .atomic)
        }

        let loaded = try await repository.load()
        #expect(loaded.releaseVersion == "1")
        #expect(loaded.contentRootURL == fixture.bundleURL.deletingLastPathComponent())
    }

    @Test
    func interruptedCommitAfterReleaseInstallDoesNotActivateIt() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let release2 = try fixture.package(releaseVersion: "2")
        let firstTransport = TestContentTransport(steps: [
            .response(release2.response(), files: release2.files),
        ])
        let repository = fixture.repository(transport: firstTransport)
        #expect(await repository.refresh() == .activated(releaseVersion: "2"))

        let release3 = try fixture.package(releaseVersion: "3")
        let interruptedTransport = TestContentTransport(steps: [
            .response(release3.response(), files: release3.files),
        ])
        let interruptedRepository = fixture.repository(
            transport: interruptedTransport,
            checkCommitCheckpoint: { checkpoint in
                if checkpoint == .releaseInstalledBeforeStateActivation {
                    throw TestTransportError.interrupted
                }
            }
        )

        #expect(
            await interruptedRepository.refresh() ==
                .rejected(.stateWriteFailed)
        )
        let installedReleaseURL = fixture.storeURL
            .appendingPathComponent("releases")
            .appendingPathComponent(release3.manifestDigest)
        #expect(
            FileManager.default.fileExists(
                atPath: installedReleaseURL.path
            )
        )
        let loaded = try await interruptedRepository.load()
        #expect(loaded.releaseVersion == "2")
        #expect(loaded.contentRootURL?.lastPathComponent == release2.manifestDigest)
    }

    @Test
    func rollbackRequiresExplicitConfiguration() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let release2 = try fixture.package(releaseVersion: "2")
        let rollback = try fixture.package(releaseVersion: "1")
        let guardedTransport = TestContentTransport(steps: [
            .response(release2.response(), files: release2.files),
            .response(rollback.response(), files: rollback.files),
        ])
        let guardedRepository = fixture.repository(transport: guardedTransport)

        #expect(
            await guardedRepository.refresh() ==
                .activated(releaseVersion: "2")
        )
        #expect(
            await guardedRepository.refresh() ==
                .rejected(.rollbackRejected)
        )
        #expect(try await guardedRepository.load().releaseVersion == "2")

        let rollbackTransport = TestContentTransport(steps: [
            .response(rollback.response(), files: rollback.files),
        ])
        let rollbackRepository = fixture.repository(
            transport: rollbackTransport,
            allowRollback: true
        )
        #expect(
            await rollbackRepository.refresh() ==
                .activated(releaseVersion: "1")
        )
        #expect(try await rollbackRepository.load().releaseVersion == "1")
    }

    @Test
    func unchangedAssetBlobIsNotDownloadedAgain() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let sharedImage = Data("same-image-across-releases".utf8)
        let release2 = try fixture.package(
            releaseVersion: "2",
            imageData: sharedImage
        )
        let release3 = try fixture.package(
            releaseVersion: "3",
            imageData: sharedImage
        )
        let transport = TestContentTransport(steps: [
            .response(release2.response(), files: release2.files),
            .response(release3.response(), files: release3.files),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(await repository.refresh() == .activated(releaseVersion: "2"))
        #expect(await repository.refresh() == .activated(releaseVersion: "3"))
        let downloaded = await transport.downloadedPaths()
        #expect(downloaded.filter { $0 == "assets/shared.png" }.count == 1)
        #expect(downloaded.filter { $0 == "CatalogV2.json" }.count == 2)
        let assetURL = await repository.activeAssetURL(for: "assets/shared.png")
        #expect(assetURL != nil)
        #expect(try assetURL.map { try Data(contentsOf: $0) } == sharedImage)
    }

    @Test
    func successfulActivationCollectsReleasesAndBlobsOlderThanPrevious() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let sharedImage = Data("shared-image".utf8)
        let release2 = try fixture.package(releaseVersion: "2", imageData: sharedImage)
        let release3 = try fixture.package(releaseVersion: "3", imageData: sharedImage)
        let release4 = try fixture.package(releaseVersion: "4", imageData: sharedImage)
        let transport = TestContentTransport(steps: [
            .response(release2.response(), files: release2.files),
            .response(release3.response(), files: release3.files),
            .response(release4.response(), files: release4.files),
        ])
        let repository = fixture.repository(transport: transport)

        #expect(await repository.refresh() == .activated(releaseVersion: "2"))
        #expect(await repository.refresh() == .activated(releaseVersion: "3"))
        #expect(await repository.refresh() == .activated(releaseVersion: "4"))

        let releaseNames = try FileManager.default.contentsOfDirectory(
            atPath: fixture.storeURL.appendingPathComponent("releases").path
        )
        #expect(Set(releaseNames) == [release3.manifestDigest, release4.manifestDigest])

        let retainedCatalogDigests = try Set(
            [release3, release4].map {
                ContentDigest.sha256Hex(of: try #require($0.files["CatalogV2.json"]))
            }
        )
        let retainedAssetDigest = ContentDigest.sha256Hex(of: sharedImage)
        let blobNames = try FileManager.default.contentsOfDirectory(
            atPath: fixture.storeURL.appendingPathComponent("blobs").path
        )
        #expect(Set(blobNames) == retainedCatalogDigests.union([retainedAssetDigest]))
        #expect(try await repository.load().releaseVersion == "4")
    }
}

private extension ContentUpdateTests {
    struct Fixture {
        let rootURL: URL
        let storeURL: URL
        let bundleURL: URL
        let manifestURL = URL(
            string: "https://content.example.test/releases/ContentManifest.json"
        )!
        let signingKey = Curve25519.Signing.PrivateKey()

        init() throws {
            rootURL = FileManager.default.temporaryDirectory.appendingPathComponent(
                "LearnNowContentUpdateTests-\(UUID().uuidString)",
                isDirectory: true
            )
            storeURL = rootURL.appendingPathComponent("store", isDirectory: true)
            let bundleRoot = rootURL.appendingPathComponent("bundle", isDirectory: true)
            bundleURL = bundleRoot.appendingPathComponent("CatalogV2.json")
            try FileManager.default.createDirectory(
                at: bundleRoot,
                withIntermediateDirectories: true
            )
            let document = catalog(releaseVersion: "1")
            try DeterministicJSON.encode(document).write(
                to: bundleURL,
                options: .atomic
            )
        }

        func remove() {
            try? FileManager.default.removeItem(at: rootURL)
        }

        @MainActor
        func repository(
            transport: any ContentUpdateTransport,
            allowRollback: Bool = false,
            limits: ContentUpdateLimits = .default,
            checkCommitCheckpoint:
                @escaping @Sendable (ContentUpdateCommitCheckpoint) throws -> Void = { _ in }
        ) -> ContentUpdateCatalogRepository {
            ContentUpdateCatalogRepository(
                bundleCatalogURL: bundleURL,
                storageRootURL: storeURL,
                configuration: ContentUpdateConfiguration(
                    manifestURL: manifestURL,
                    trustedPublicKeys: [
                        "test-key": signingKey.publicKey.rawRepresentation,
                    ],
                    locale: "zh-Hans",
                    appBuild: 1,
                    supportedCapabilities: ContentPolicy.supportedCapabilities,
                    allowRollback: allowRollback,
                    limits: limits
                ),
                transport: transport,
                checkCommitCheckpoint: checkCommitCheckpoint
            )
        }

        func package(
            releaseVersion: String,
            manifestSchemaVersion: Int = ContentManifestV1.currentSchemaVersion,
            minimumAppBuild: Int = 1,
            requiredCapabilities: [String]? = nil,
            imageData: Data? = nil,
            signingKey: Curve25519.Signing.PrivateKey? = nil,
            manifestFileTransform: ([ContentManifestFile]) -> [ContentManifestFile] = { $0 },
            catalogTransform: (CatalogDocumentV2) -> CatalogDocumentV2 = { $0 }
        ) throws -> TestPackage {
            let document = catalogTransform(
                catalog(
                    releaseVersion: releaseVersion,
                    includesImage: imageData != nil
                )
            )
            let catalogData = try DeterministicJSON.encode(document)
            var filesByPath = ["CatalogV2.json": catalogData]
            if let imageData {
                filesByPath["assets/shared.png"] = imageData
            }
            var manifestFiles = filesByPath.map { path, data in
                ContentManifestFile(
                    path: path,
                    size: data.count,
                    sha256: ContentDigest.sha256Hex(of: data)
                )
            }
            manifestFiles.sort { $0.path < $1.path }
            manifestFiles = manifestFileTransform(manifestFiles)
            let unsigned = ContentManifestV1(
                schemaVersion: manifestSchemaVersion,
                releaseVersion: releaseVersion,
                compilerVersion: "tests",
                locale: "zh-Hans",
                minAppBuild: minimumAppBuild,
                requiredCapabilities: requiredCapabilities ??
                    (imageData == nil ? ["paragraph"] : ["image", "paragraph"]),
                publishedAt: "2026-07-28T12:00:00Z",
                files: manifestFiles,
                retiredIDs: []
            )
            let signed = try ContentManifestSigner.sign(
                unsigned,
                privateKeyRawRepresentation:
                    (signingKey ?? self.signingKey).rawRepresentation,
                keyID: "test-key"
            )
            let manifestData = try DeterministicJSON.encode(
                signed,
                prettyPrinted: false
            )
            return TestPackage(
                manifestData: manifestData,
                files: filesByPath,
                manifestDigest: ContentDigest.sha256Hex(of: manifestData)
            )
        }

        private func catalog(
            releaseVersion: String,
            includesImage: Bool = false
        ) -> CatalogDocumentV2 {
            var blocks: [LessonContentBlock] = [
                .paragraph([.text("Release \(releaseVersion)")]),
            ]
            if includesImage {
                blocks.append(
                    .image(
                        path: "assets/shared.png",
                        alt: "测试图片",
                        caption: nil
                    )
                )
            }
            return CatalogDocumentV2(
                releaseVersion: releaseVersion,
                locale: "zh-Hans",
                primaryRouteID: "route",
                tracks: [
                    TrackDefinition(id: "track", title: "Track"),
                ],
                routes: [
                    RouteDefinition(
                        id: "route",
                        title: "Route",
                        subtitle: "Subtitle",
                        systemImage: "cpu",
                        accent: .blue,
                        cta: "开始",
                        interactive: true,
                        trackIDs: ["track"],
                        moduleIDs: ["module"]
                    ),
                ],
                modules: [
                    ModuleDefinition(
                        id: "module",
                        trackID: "track",
                        title: "Module",
                        subtitle: "Subtitle",
                        lessonTitle: "Lesson",
                        prerequisiteModuleIDs: [],
                        completionXP: 10,
                        reviewMessage: "完成"
                    ),
                ],
                lessons: [
                    LessonDefinition(
                        id: "lesson",
                        moduleID: "module",
                        order: 1,
                        title: "Lesson",
                        accent: .blue,
                        revision: 1,
                        locale: "zh-Hans",
                        objectives: ["objective"],
                        blocks: blocks
                    ),
                ],
                exercises: [],
                reviewCards: [],
                knowledgeTips: [],
                retiredIDs: []
            )
        }
    }

    struct TestPackage {
        let manifestData: Data
        let files: [String: Data]
        let manifestDigest: String

        func response(etag: String? = nil) -> ContentManifestTransportResponse {
            ContentManifestTransportResponse(
                statusCode: 200,
                data: manifestData,
                etag: etag,
                finalURL: URL(
                    string: "https://content.example.test/releases/ContentManifest.json"
                )!
            )
        }
    }
}

private actor TestContentTransport: ContentUpdateTransport {
    enum Step: Sendable {
        case response(
            ContentManifestTransportResponse,
            files: [String: Data]
        )
        case responseWithInterruptedDownload(
            ContentManifestTransportResponse,
            files: [String: Data],
            path: String
        )
        case failure
    }

    private var steps: [Step]
    private var currentFiles: [String: Data] = [:]
    private var etags: [String?] = []
    private var paths: [String] = []
    private var interruptedPath: String?

    init(steps: [Step]) {
        self.steps = steps
    }

    func fetchManifest(
        from url: URL,
        ifNoneMatch etag: String?,
        maximumBytes: Int
    ) async throws -> ContentManifestTransportResponse {
        etags.append(etag)
        guard !steps.isEmpty else { throw TestTransportError.noResponse }
        switch steps.removeFirst() {
        case let .response(response, files):
            currentFiles = files
            interruptedPath = nil
            return response
        case let .responseWithInterruptedDownload(response, files, path):
            currentFiles = files
            interruptedPath = path
            return response
        case .failure:
            throw TestTransportError.offline
        }
    }

    func downloadFile(
        from url: URL,
        to destinationURL: URL,
        maximumBytes: Int
    ) async throws -> ContentFileTransportResponse {
        let path = matchingPath(for: url)
        guard let data = currentFiles[path] else {
            throw TestTransportError.missingFile
        }
        paths.append(path)
        try FileManager.default.createDirectory(
            at: destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        if interruptedPath == path {
            let partialCount = max(1, data.count / 2)
            try Data(data.prefix(partialCount)).write(
                to: destinationURL,
                options: .atomic
            )
            throw TestTransportError.interrupted
        }
        try data.write(to: destinationURL, options: .atomic)
        return ContentFileTransportResponse(
            statusCode: 200,
            bytesWritten: data.count,
            finalURL: url
        )
    }

    func requestedETags() -> [String?] {
        etags
    }

    func downloadedPaths() -> [String] {
        paths
    }

    private func matchingPath(for url: URL) -> String {
        currentFiles.keys
            .sorted { $0.count > $1.count }
            .first { url.path.hasSuffix("/\($0)") } ?? url.lastPathComponent
    }
}

private enum TestTransportError: Error {
    case offline
    case interrupted
    case noResponse
    case missingFile
}

private extension CatalogDocumentV2 {
    func addingExerciseWithNestedOptionFeedback() -> CatalogDocumentV2 {
        let exerciseID = "lesson.exercise"
        let optionFeedback = FeedbackDefinition(
            title: "选项反馈",
            body: [
                .strong([
                    .emphasis([
                        .code("deep-inline"),
                    ]),
                ]),
            ],
            tone: .information,
            accent: .blue
        )
        let exercise = ExerciseDefinition(
            id: exerciseID,
            lessonID: "lesson",
            prompt: [.text("请选择")],
            options: [
                ExerciseOptionDefinition(
                    id: "correct",
                    content: [.text("正确")],
                    feedback: optionFeedback
                ),
                ExerciseOptionDefinition(
                    id: "incorrect",
                    content: [.text("错误")]
                ),
            ],
            correctOptionID: "correct",
            correctFeedback: FeedbackDefinition(
                title: "正确",
                body: [.text("回答正确")],
                tone: .success,
                accent: .mint
            ),
            incorrectFeedback: FeedbackDefinition(
                title: "再想想",
                body: [.text("回答错误")],
                tone: .warning,
                accent: .amber
            )
        )
        let lessons = lessons.map { lesson in
            guard lesson.id == "lesson" else { return lesson }
            return LessonDefinition(
                id: lesson.id,
                moduleID: lesson.moduleID,
                order: lesson.order,
                title: lesson.title,
                accent: lesson.accent,
                revision: lesson.revision,
                locale: lesson.locale,
                objectives: lesson.objectives,
                blocks: lesson.blocks + [.singleChoice(exerciseID: exerciseID)]
            )
        }
        return CatalogDocumentV2(
            schemaVersion: schemaVersion,
            releaseVersion: releaseVersion,
            locale: locale,
            primaryRouteID: primaryRouteID,
            tracks: tracks,
            routes: routes,
            modules: modules,
            lessons: lessons,
            exercises: exercises + [exercise],
            reviewCards: reviewCards,
            knowledgeTips: knowledgeTips,
            retiredIDs: retiredIDs
        )
    }
}
