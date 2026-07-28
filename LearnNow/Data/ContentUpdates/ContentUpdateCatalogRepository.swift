import CryptoKit
import Foundation
import LearnNowContentKit

actor ContentUpdateCatalogRepository: CatalogRepository {
    private struct StoreState: Codable, Equatable, Sendable {
        static let currentSchemaVersion = 1

        var schemaVersion = currentSchemaVersion
        var activeManifestDigest: String?
        var previousManifestDigest: String?
        var highestAcceptedReleaseVersion: String?
        var endpointIdentifier: String?
        var etag: String?

        static let empty = StoreState()
    }

    private typealias ReleaseVersion = ContentReleaseVersion

    private struct ValidatedManifest: Sendable {
        let manifest: ContentManifestV1
        let canonicalData: Data
        let digest: String
        let releaseVersion: ReleaseVersion
        let catalogFile: ContentManifestFile
    }

    private let bundleCatalogURL: URL
    private let storageRootURL: URL
    private let configuration: ContentUpdateConfiguration
    private let transport: any ContentUpdateTransport
    private let checkCommitCheckpoint:
        @Sendable (ContentUpdateCommitCheckpoint) throws -> Void
    private var refreshInProgress = false

    init(
        bundleCatalogURL: URL,
        storageRootURL: URL,
        configuration: ContentUpdateConfiguration,
        transport: (any ContentUpdateTransport)? = nil,
        checkCommitCheckpoint:
            @escaping @Sendable (ContentUpdateCommitCheckpoint) throws -> Void = { _ in }
    ) {
        self.bundleCatalogURL = bundleCatalogURL
        self.storageRootURL = storageRootURL
        self.configuration = configuration
        self.transport = transport ?? URLSessionContentUpdateTransport()
        self.checkCommitCheckpoint = checkCommitCheckpoint
    }

    func load() async throws -> CourseCatalog {
        let state = readState()
        if !configuration.trustedPublicKeys.isEmpty {
            if let activeDigest = state.activeManifestDigest,
               let catalog = try? await validateStoredPackage(manifestDigest: activeDigest)
            {
                return catalog
            }
            if let previousDigest = state.previousManifestDigest,
               let catalog = try? await validateStoredPackage(manifestDigest: previousDigest)
            {
                var repaired = state
                repaired.activeManifestDigest = previousDigest
                repaired.previousManifestDigest = nil
                repaired.endpointIdentifier = nil
                repaired.etag = nil
                if (try? writeState(repaired)) != nil {
                    garbageCollect(using: repaired)
                }
                return catalog
            }
        }
        let data = try Data(contentsOf: bundleCatalogURL)
        let contentRootURL = bundleCatalogURL.deletingLastPathComponent()
        return try await MainActor.run {
            try CatalogDecoder.decode(
                data: data,
                contentRootURL: contentRootURL
            )
        }
    }

    func refresh() async -> ContentRefreshOutcome {
        guard configuration.hasRemoteConfiguration else { return .disabled }
        guard !refreshInProgress else { return .alreadyRefreshing }
        refreshInProgress = true
        defer { refreshInProgress = false }

        do {
            return try await performRefresh()
        } catch let failure as ContentUpdateFailure {
            return .rejected(failure)
        } catch {
            return .transportFailure
        }
    }

    func activeAssetURL(for path: String) -> URL? {
        guard isSafeRelativePath(path) else { return nil }
        let state = readState()
        guard let activeDigest = state.activeManifestDigest,
              let manifest = try? readAndValidateStoredManifest(digest: activeDigest),
              manifest.manifest.files.contains(where: { $0.path == path })
        else {
            return nil
        }
        let url = appending(
            relativePath: path,
            to: releaseURL(for: activeDigest)
        )
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    private func performRefresh() async throws -> ContentRefreshOutcome {
        guard let manifestURL = configuration.manifestURL,
              isSafeHTTPSURL(manifestURL)
        else {
            throw ContentUpdateFailure.invalidEndpoint
        }
        if let filesBaseURL = configuration.filesBaseURL,
           !isSafeHTTPSURL(filesBaseURL)
        {
            throw ContentUpdateFailure.invalidEndpoint
        }

        try prepareStoreDirectories()
        cleanStagingDirectory()
        var state = readState()
        let endpointIdentifier = ContentDigest.sha256Hex(
            of: Data(manifestURL.absoluteString.utf8)
        )
        let activePackageIsValid: Bool
        if let digest = state.activeManifestDigest {
            activePackageIsValid =
                (try? await validateStoredPackage(manifestDigest: digest)) != nil
        } else {
            activePackageIsValid = false
        }
        let conditionalETag = activePackageIsValid &&
            state.endpointIdentifier == endpointIdentifier
            ? state.etag
            : nil

        let response = try await transport.fetchManifest(
            from: manifestURL,
            ifNoneMatch: conditionalETag,
            maximumBytes: configuration.limits.maximumManifestBytes
        )
        guard isSafeHTTPSURL(response.finalURL) else {
            throw ContentUpdateFailure.invalidEndpoint
        }
        if response.statusCode == 304 {
            guard conditionalETag != nil else {
                throw ContentUpdateFailure.invalidHTTPStatus
            }
            return .notModified
        }
        guard response.statusCode == 200 else {
            throw ContentUpdateFailure.invalidHTTPStatus
        }

        let validated = try validateManifestData(response.data)
        let knownDigests = [state.activeManifestDigest, state.previousManifestDigest].compactMap { $0 }
        for digest in knownDigests {
            guard let known = try? readAndValidateStoredManifest(digest: digest),
                  known.releaseVersion == validated.releaseVersion
            else {
                continue
            }
            guard known.digest == validated.digest else {
                throw ContentUpdateFailure.releaseVersionCollision
            }
        }
        if let highest = highestAcceptedVersion(state: state) {
            if validated.releaseVersion < highest, !configuration.allowRollback {
                throw ContentUpdateFailure.rollbackRejected
            }
            let storedManifestExists =
                (try? readAndValidateStoredManifest(digest: validated.digest)) != nil
            if validated.releaseVersion == highest,
               !knownDigests.contains(validated.digest),
               !storedManifestExists
            {
                throw ContentUpdateFailure.releaseVersionCollision
            }
        }

        for digest in knownDigests {
            guard digest == validated.digest,
                  (try? await validateStoredPackage(manifestDigest: digest)) != nil
            else {
                continue
            }
            if state.activeManifestDigest == validated.digest {
                state.endpointIdentifier = endpointIdentifier
                state.etag = response.etag
                try writeState(state)
                return .unchanged(releaseVersion: validated.manifest.releaseVersion)
            }
            state.previousManifestDigest = state.activeManifestDigest
            state.activeManifestDigest = validated.digest
            state.endpointIdentifier = endpointIdentifier
            state.etag = response.etag
            try writeState(state)
            return .activated(releaseVersion: validated.manifest.releaseVersion)
        }

        let filesBaseURL = configuration.filesBaseURL ??
            response.finalURL.deletingLastPathComponent()
        guard isSafeHTTPSURL(filesBaseURL) else {
            throw ContentUpdateFailure.invalidEndpoint
        }

        let stagingURL = stagingRootURL.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        do {
            try FileManager.default.createDirectory(
                at: stagingURL,
                withIntermediateDirectories: true
            )
        } catch {
            throw ContentUpdateFailure.stateWriteFailed
        }
        defer { try? FileManager.default.removeItem(at: stagingURL) }

        for file in validated.manifest.files {
            let localURL = appending(relativePath: file.path, to: stagingURL)
            let blobURL = blobURL(for: file.sha256)
            if fileSize(at: blobURL) == file.size,
               (try? sha256Hex(ofFileAt: blobURL)) == file.sha256
            {
                try materializeBlob(at: blobURL, to: localURL)
                continue
            }

            let remoteURL = appending(relativePath: file.path, to: filesBaseURL)
            let downloadResponse = try await transport.downloadFile(
                from: remoteURL,
                to: localURL,
                maximumBytes: file.size
            )
            guard downloadResponse.statusCode == 200 else {
                throw ContentUpdateFailure.invalidHTTPStatus
            }
            guard isSafeHTTPSURL(downloadResponse.finalURL) else {
                throw ContentUpdateFailure.invalidEndpoint
            }
            guard downloadResponse.bytesWritten == file.size,
                  fileSize(at: localURL) == file.size
            else {
                throw ContentUpdateFailure.downloadedSizeMismatch
            }
            guard try sha256Hex(ofFileAt: localURL) == file.sha256 else {
                throw ContentUpdateFailure.downloadedDigestMismatch
            }
        }

        let stagedCatalogURL = appending(
            relativePath: validated.catalogFile.path,
            to: stagingURL
        )
        _ = try await validateCatalog(
            at: stagedCatalogURL,
            contentRootURL: stagingURL,
            against: validated.manifest
        )
        try commit(
            validated: validated,
            stagingURL: stagingURL,
            state: &state,
            endpointIdentifier: endpointIdentifier,
            etag: response.etag
        )
        return .activated(releaseVersion: validated.manifest.releaseVersion)
    }

    private func validateManifestData(_ data: Data) throws -> ValidatedManifest {
        guard data.count <= configuration.limits.maximumManifestBytes else {
            throw ContentUpdateFailure.manifestTooLarge
        }
        let manifest: ContentManifestV1
        do {
            manifest = try DeterministicJSON.decode(ContentManifestV1.self, from: data)
        } catch {
            throw ContentUpdateFailure.malformedManifest
        }
        guard manifest.schemaVersion == ContentManifestV1.currentSchemaVersion else {
            throw ContentUpdateFailure.unsupportedManifestSchema
        }
        guard let keyID = manifest.keyID,
              !keyID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let signature = manifest.signature,
              !signature.isEmpty
        else {
            throw ContentUpdateFailure.missingSignature
        }
        guard let publicKey = configuration.trustedPublicKeys[keyID] else {
            throw ContentUpdateFailure.unknownSigningKey
        }
        do {
            guard try ContentManifestSigner.verify(
                manifest,
                publicKeyRawRepresentation: publicKey
            ) else {
                throw ContentUpdateFailure.invalidSignature
            }
        } catch let failure as ContentUpdateFailure {
            throw failure
        } catch {
            throw ContentUpdateFailure.invalidSignature
        }

        guard let releaseVersion = ReleaseVersion(manifest.releaseVersion) else {
            throw ContentUpdateFailure.invalidReleaseVersion
        }
        guard manifest.locale == configuration.locale else {
            throw ContentUpdateFailure.incompatibleLocale
        }
        guard manifest.minAppBuild >= 0,
              manifest.minAppBuild <= configuration.appBuild
        else {
            throw ContentUpdateFailure.incompatibleAppBuild
        }
        let capabilities = Set(manifest.requiredCapabilities)
        guard capabilities.count == manifest.requiredCapabilities.count,
              capabilities.isSubset(of: configuration.supportedCapabilities)
        else {
            throw ContentUpdateFailure.unsupportedCapabilities
        }
        guard isRFC3339(manifest.publishedAt) else {
            throw ContentUpdateFailure.malformedPublishedAt
        }
        guard !manifest.files.isEmpty else {
            throw ContentUpdateFailure.missingCatalog
        }
        guard manifest.files.count <= configuration.limits.maximumFileCount else {
            throw ContentUpdateFailure.tooManyFiles
        }

        var paths: Set<String> = []
        var totalBytes = 0
        var catalogFiles: [ContentManifestFile] = []
        for file in manifest.files {
            guard isSafeRelativePath(file.path) else {
                throw ContentUpdateFailure.unsafeFilePath
            }
            if file.path.hasPrefix("assets/") {
                guard CatalogSemanticValidator.isSafeImageAssetPath(file.path),
                      file.size <= ContentPolicy.maximumImageAssetSize
                else {
                    throw ContentUpdateFailure.unsafeFilePath
                }
            }
            guard paths.insert(file.path).inserted else {
                throw ContentUpdateFailure.duplicateFilePath
            }
            guard file.size > 0,
                  file.size <= configuration.limits.maximumFileBytes
            else {
                throw ContentUpdateFailure.invalidFileSize
            }
            let (newTotal, overflow) = totalBytes.addingReportingOverflow(file.size)
            guard !overflow, newTotal <= configuration.limits.maximumTotalBytes else {
                throw ContentUpdateFailure.packageTooLarge
            }
            totalBytes = newTotal
            guard file.sha256.range(
                of: #"^[0-9a-f]{64}$"#,
                options: .regularExpression
            ) != nil else {
                throw ContentUpdateFailure.invalidFileDigest
            }
            if file.path == "CatalogV2.json" {
                catalogFiles.append(file)
            }
        }
        guard !catalogFiles.isEmpty else {
            throw ContentUpdateFailure.missingCatalog
        }
        guard catalogFiles.count == 1 else {
            throw ContentUpdateFailure.duplicateCatalog
        }
        guard Set(manifest.retiredIDs).count == manifest.retiredIDs.count else {
            throw ContentUpdateFailure.catalogMetadataMismatch
        }

        let canonicalData: Data
        do {
            canonicalData = try DeterministicJSON.encode(manifest, prettyPrinted: false)
        } catch {
            throw ContentUpdateFailure.malformedManifest
        }
        return ValidatedManifest(
            manifest: manifest,
            canonicalData: canonicalData,
            digest: ContentDigest.sha256Hex(of: canonicalData),
            releaseVersion: releaseVersion,
            catalogFile: catalogFiles[0]
        )
    }

    private func validateCatalog(
        at url: URL,
        contentRootURL: URL,
        against manifest: ContentManifestV1
    ) async throws -> CourseCatalog {
        let data: Data
        let document: CatalogDocumentV2
        do {
            data = try Data(contentsOf: url)
            document = try DeterministicJSON.decode(CatalogDocumentV2.self, from: data)
        } catch {
            throw ContentUpdateFailure.invalidCatalog
        }
        let errors = CatalogSemanticValidator.validate(document)
            .filter { $0.severity == .error }
        guard errors.isEmpty else {
            throw ContentUpdateFailure.invalidCatalog
        }
        guard document.releaseVersion == manifest.releaseVersion,
              document.locale == manifest.locale,
              Set(document.retiredIDs) == Set(manifest.retiredIDs)
        else {
            throw ContentUpdateFailure.catalogMetadataMismatch
        }

        let manifestPaths = Set(manifest.files.map(\.path))
        let referencedImagePaths = Set(
            document.lessons.flatMap { collectImagePaths(in: $0.blocks) }
        )
        guard referencedImagePaths.isSubset(of: manifestPaths) else {
            throw ContentUpdateFailure.missingImageAsset
        }
        let usedCapabilities = capabilitiesUsed(by: document)
        guard usedCapabilities.isSubset(of: Set(manifest.requiredCapabilities)) else {
            throw ContentUpdateFailure.unsupportedCapabilities
        }

        do {
            return try await MainActor.run {
                try CatalogDecoder.validateAndMap(
                    document,
                    contentRootURL: contentRootURL
                )
            }
        } catch {
            throw ContentUpdateFailure.invalidCatalog
        }
    }

    private func validateStoredPackage(
        manifestDigest: String
    ) async throws -> CourseCatalog {
        let validated = try readAndValidateStoredManifest(digest: manifestDigest)
        let releaseRootURL = releaseURL(for: manifestDigest)
        for file in validated.manifest.files {
            let url = appending(relativePath: file.path, to: releaseRootURL)
            guard fileSize(at: url) == file.size else {
                throw ContentUpdateFailure.downloadedSizeMismatch
            }
            guard try sha256Hex(ofFileAt: url) == file.sha256 else {
                throw ContentUpdateFailure.downloadedDigestMismatch
            }
        }
        return try await validateCatalog(
            at: appending(
                relativePath: validated.catalogFile.path,
                to: releaseURL(for: manifestDigest)
            ),
            contentRootURL: releaseURL(for: manifestDigest),
            against: validated.manifest
        )
    }

    private func readAndValidateStoredManifest(
        digest: String
    ) throws -> ValidatedManifest {
        guard digest.range(
            of: #"^[0-9a-f]{64}$"#,
            options: .regularExpression
        ) != nil else {
            throw ContentUpdateFailure.invalidFileDigest
        }
        let url = manifestURL(for: digest)
        guard let manifestSize = fileSize(at: url),
              manifestSize <= configuration.limits.maximumManifestBytes
        else {
            throw ContentUpdateFailure.manifestTooLarge
        }
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ContentUpdateFailure.malformedManifest
        }
        let validated = try validateManifestData(data)
        guard validated.digest == digest else {
            throw ContentUpdateFailure.invalidSignature
        }
        return validated
    }

    private func commit(
        validated: ValidatedManifest,
        stagingURL: URL,
        state: inout StoreState,
        endpointIdentifier: String,
        etag: String?
    ) throws {
        do {
            try prepareStoreDirectories()
            for file in validated.manifest.files {
                let sourceURL = appending(relativePath: file.path, to: stagingURL)
                let destinationURL = blobURL(for: file.sha256)
                if fileSize(at: destinationURL) == file.size,
                   (try? sha256Hex(ofFileAt: destinationURL)) == file.sha256
                {
                    continue
                }
                let temporaryURL = blobsRootURL.appendingPathComponent(
                    ".\(file.sha256).\(UUID().uuidString).tmp"
                )
                try? FileManager.default.removeItem(at: temporaryURL)
                try FileManager.default.copyItem(at: sourceURL, to: temporaryURL)
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    _ = try FileManager.default.replaceItemAt(
                        destinationURL,
                        withItemAt: temporaryURL
                    )
                } else {
                    try FileManager.default.moveItem(
                        at: temporaryURL,
                        to: destinationURL
                    )
                }
                try FileManager.default.removeItem(at: sourceURL)
                try materializeBlob(
                    at: destinationURL,
                    to: sourceURL
                )
            }

            try validated.canonicalData.write(
                to: stagingURL.appendingPathComponent(".content-manifest.json"),
                options: .atomic
            )
            let destinationReleaseURL = releaseURL(for: validated.digest)
            if FileManager.default.fileExists(atPath: destinationReleaseURL.path) {
                _ = try FileManager.default.replaceItemAt(
                    destinationReleaseURL,
                    withItemAt: stagingURL
                )
            } else {
                try FileManager.default.moveItem(
                    at: stagingURL,
                    to: destinationReleaseURL
                )
            }

            var nextState = state
            nextState.activeManifestDigest = validated.digest
            nextState.previousManifestDigest = state.activeManifestDigest
            nextState.endpointIdentifier = endpointIdentifier
            nextState.etag = etag

            let previousHighest = nextState.highestAcceptedReleaseVersion
                .flatMap(ReleaseVersion.init)
            if previousHighest == nil || previousHighest! < validated.releaseVersion {
                nextState.highestAcceptedReleaseVersion = validated.manifest.releaseVersion
            }
            if let bundleVersion = bundleReleaseVersion(),
               let currentHighest = nextState.highestAcceptedReleaseVersion
                .flatMap(ReleaseVersion.init),
               currentHighest < bundleVersion
            {
                nextState.highestAcceptedReleaseVersion = bundleVersion.source
            }
            try checkCommitCheckpoint(.releaseInstalledBeforeStateActivation)
            try writeState(nextState)
            state = nextState
            garbageCollect(using: nextState)
        } catch let failure as ContentUpdateFailure {
            throw failure
        } catch {
            throw ContentUpdateFailure.stateWriteFailed
        }
    }

    private func highestAcceptedVersion(state: StoreState) -> ReleaseVersion? {
        let stored = state.highestAcceptedReleaseVersion.flatMap(ReleaseVersion.init)
        let bundled = bundleReleaseVersion()
        switch (stored, bundled) {
        case let (stored?, bundled?): return max(stored, bundled)
        case let (stored?, nil): return stored
        case let (nil, bundled?): return bundled
        case (nil, nil): return nil
        }
    }

    private func bundleReleaseVersion() -> ReleaseVersion? {
        guard let data = try? Data(contentsOf: bundleCatalogURL),
              let document = try? DeterministicJSON.decode(
                CatalogDocumentV2.self,
                from: data
              )
        else {
            return nil
        }
        return ReleaseVersion(document.releaseVersion)
    }

    private func prepareStoreDirectories() throws {
        do {
            for url in [storageRootURL, releasesRootURL, blobsRootURL, stagingRootURL] {
                try FileManager.default.createDirectory(
                    at: url,
                    withIntermediateDirectories: true
                )
            }
            var root = storageRootURL
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try? root.setResourceValues(values)
        } catch {
            throw ContentUpdateFailure.stateWriteFailed
        }
    }

    private func cleanStagingDirectory() {
        guard let children = try? FileManager.default.contentsOfDirectory(
            at: stagingRootURL,
            includingPropertiesForKeys: nil
        ) else {
            return
        }
        for child in children {
            try? FileManager.default.removeItem(at: child)
        }
    }

    /// Keep exactly the active and previous immutable releases. Blob files are
    /// retained only while one of those releases references their digest.
    /// Cleanup is deliberately best-effort and runs after the atomic state write,
    /// so a filesystem cleanup failure can never roll back an activated package.
    private func garbageCollect(using state: StoreState) {
        let retainedDigests = Set(
            [state.activeManifestDigest, state.previousManifestDigest].compactMap { $0 }
        )

        if let releases = try? FileManager.default.contentsOfDirectory(
            at: releasesRootURL,
            includingPropertiesForKeys: nil
        ) {
            for release in releases where !retainedDigests.contains(release.lastPathComponent) {
                try? FileManager.default.removeItem(at: release)
            }
        }

        var retainedBlobDigests: Set<String> = []
        for digest in retainedDigests {
            guard let manifest = try? readAndValidateStoredManifest(digest: digest) else {
                continue
            }
            retainedBlobDigests.formUnion(manifest.manifest.files.map(\.sha256))
        }

        if let blobs = try? FileManager.default.contentsOfDirectory(
            at: blobsRootURL,
            includingPropertiesForKeys: nil
        ) {
            for blob in blobs where !retainedBlobDigests.contains(blob.lastPathComponent) {
                try? FileManager.default.removeItem(at: blob)
            }
        }
    }

    private func readState() -> StoreState {
        guard let data = try? Data(contentsOf: stateURL),
              let state = try? JSONDecoder().decode(StoreState.self, from: data),
              state.schemaVersion == StoreState.currentSchemaVersion
        else {
            return .empty
        }
        return state
    }

    private func writeState(_ state: StoreState) throws {
        do {
            try prepareStoreDirectories()
            let data = try DeterministicJSON.encode(state, prettyPrinted: false)
            try data.write(to: stateURL, options: .atomic)
        } catch {
            throw ContentUpdateFailure.stateWriteFailed
        }
    }

    private var stateURL: URL {
        storageRootURL.appendingPathComponent("state.json")
    }

    private var releasesRootURL: URL {
        storageRootURL.appendingPathComponent("releases", isDirectory: true)
    }

    private var blobsRootURL: URL {
        storageRootURL.appendingPathComponent("blobs", isDirectory: true)
    }

    private var stagingRootURL: URL {
        storageRootURL.appendingPathComponent("staging", isDirectory: true)
    }

    private func manifestURL(for digest: String) -> URL {
        releaseURL(for: digest).appendingPathComponent(".content-manifest.json")
    }

    private func releaseURL(for digest: String) -> URL {
        releasesRootURL.appendingPathComponent(digest, isDirectory: true)
    }

    private func blobURL(for digest: String) -> URL {
        blobsRootURL.appendingPathComponent(digest)
    }

    private func fileSize(at url: URL) -> Int? {
        guard let attributes = try? FileManager.default.attributesOfItem(
            atPath: url.path
        ), let number = attributes[.size] as? NSNumber else {
            return nil
        }
        return number.intValue
    }

    private func sha256Hex(ofFileAt url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            let data = try handle.read(upToCount: 64 * 1_024) ?? Data()
            if data.isEmpty { break }
            hasher.update(data: data)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private func isSafeHTTPSURL(_ url: URL) -> Bool {
        url.scheme?.lowercased() == "https" &&
            url.host?.isEmpty == false &&
            url.user == nil &&
            url.password == nil &&
            url.fragment == nil
    }

    private func isSafeRelativePath(_ path: String) -> Bool {
        guard !path.isEmpty,
              path != ".content-manifest.json",
              !path.hasPrefix("/"),
              !path.contains("\\"),
              !path.contains("://"),
              !path.contains("?"),
              !path.contains("#"),
              path.range(
                  of: #"^[A-Za-z0-9][A-Za-z0-9._/-]*$"#,
                  options: .regularExpression
              ) != nil,
              !path.unicodeScalars.contains(where: {
                  CharacterSet.controlCharacters.contains($0)
              })
        else {
            return false
        }
        let components = path.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        return components.allSatisfy { !$0.isEmpty && $0 != "." && $0 != ".." }
    }

    private func appending(relativePath path: String, to baseURL: URL) -> URL {
        path.split(separator: "/").reduce(baseURL) { partial, component in
            partial.appendingPathComponent(String(component))
        }
    }

    private func materializeBlob(at blobURL: URL, to destinationURL: URL) throws {
        do {
            try FileManager.default.createDirectory(
                at: destinationURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            do {
                try FileManager.default.linkItem(
                    at: blobURL,
                    to: destinationURL
                )
            } catch {
                try FileManager.default.copyItem(
                    at: blobURL,
                    to: destinationURL
                )
            }
        } catch {
            throw ContentUpdateFailure.stateWriteFailed
        }
    }

    private func isRFC3339(_ value: String) -> Bool {
        let withFractionalSeconds = ISO8601DateFormatter()
        withFractionalSeconds.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
        ]
        if withFractionalSeconds.date(from: value) != nil { return true }
        let standard = ISO8601DateFormatter()
        standard.formatOptions = [.withInternetDateTime]
        return standard.date(from: value) != nil
    }

    private func collectImagePaths(in blocks: [LessonContentBlock]) -> [String] {
        blocks.flatMap { block -> [String] in
            switch block {
            case let .image(path, _, _):
                return [path]
            case let .callout(_, _, _, body):
                return collectImagePaths(in: body)
            case .paragraph, .heading, .list, .code, .singleChoice:
                return []
            }
        }
    }

    private func capabilitiesUsed(by document: CatalogDocumentV2) -> Set<String> {
        var capabilities: Set<String> = []
        for lesson in document.lessons {
            collectCapabilities(in: lesson.blocks, into: &capabilities)
        }
        for exercise in document.exercises {
            capabilities.insert("singleChoice")
            collectInlineCapabilities(in: exercise.prompt, into: &capabilities)
            for option in exercise.options {
                collectInlineCapabilities(in: option.content, into: &capabilities)
                if let feedback = option.feedback {
                    collectInlineCapabilities(
                        in: feedback.body,
                        into: &capabilities
                    )
                }
            }
            collectInlineCapabilities(in: exercise.correctFeedback.body, into: &capabilities)
            collectInlineCapabilities(in: exercise.incorrectFeedback.body, into: &capabilities)
        }
        for card in document.reviewCards {
            collectInlineCapabilities(in: card.backBody, into: &capabilities)
            collectInlineCapabilities(in: card.backHighlight, into: &capabilities)
        }
        for tip in document.knowledgeTips {
            collectInlineCapabilities(in: tip.body, into: &capabilities)
        }
        return capabilities
    }

    private func collectCapabilities(
        in blocks: [LessonContentBlock],
        into capabilities: inout Set<String>
    ) {
        for block in blocks {
            switch block {
            case let .paragraph(content):
                capabilities.insert("paragraph")
                collectInlineCapabilities(in: content, into: &capabilities)
            case let .heading(_, content):
                capabilities.insert("heading")
                collectInlineCapabilities(in: content, into: &capabilities)
            case let .list(_, items):
                capabilities.insert("list")
                for item in items {
                    collectInlineCapabilities(in: item.content, into: &capabilities)
                }
            case let .callout(_, _, _, body):
                capabilities.insert("callout")
                collectCapabilities(in: body, into: &capabilities)
            case .code:
                capabilities.insert("code")
            case let .image(_, _, caption):
                capabilities.insert("image")
                if let caption {
                    collectInlineCapabilities(in: caption, into: &capabilities)
                }
            case .singleChoice:
                capabilities.insert("singleChoice")
            }
        }
    }

    private func collectInlineCapabilities(
        in content: [InlineContent],
        into capabilities: inout Set<String>
    ) {
        for inline in content {
            switch inline {
            case let .emphasis(children):
                capabilities.insert("inlineEmphasis")
                collectInlineCapabilities(in: children, into: &capabilities)
            case let .strong(children):
                capabilities.insert("inlineStrong")
                collectInlineCapabilities(in: children, into: &capabilities)
            case .code:
                capabilities.insert("inlineCode")
            case .text, .lineBreak:
                break
            }
        }
    }
}
