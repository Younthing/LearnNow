import Foundation
import LearnNowContentKit

protocol RefreshableCatalogRepository: CatalogRepository {
    func refresh() async -> ContentRefreshOutcome
}

extension ContentUpdateCatalogRepository: RefreshableCatalogRepository {}

struct FileCatalogRepository: CatalogRepository {
    let catalogURL: URL

    func load() async throws -> CourseCatalog {
        try CatalogDecoder.decode(
            data: Data(contentsOf: catalogURL),
            contentRootURL: catalogURL.deletingLastPathComponent()
        )
    }
}

enum ContentCatalogRepositoryFactory {
    static func make(
        bundle: Bundle = .main,
        processInfo: ProcessInfo = .processInfo,
        fileManager: FileManager = .default
    ) -> any CatalogRepository {
#if DEBUG
        if let previewURL = previewCatalogURL(processInfo: processInfo, fileManager: fileManager) {
            return FileCatalogRepository(catalogURL: previewURL)
        }
#endif

        guard let bundleCatalogURL = bundle.url(
            forResource: "CatalogV2",
            withExtension: "json"
        ) else {
            return BundleCatalogRepository(bundle: bundle)
        }

        let disablesUpdates =
            processInfo.environment["LEARNNOW_DISABLE_CONTENT_UPDATES"] == "YES" ||
            processInfo.environment["LEARNNOW_TESTING"] == "YES" ||
            processInfo.arguments.contains("-UITestingResetData")

        let configuration = disablesUpdates
            ? ContentUpdateConfiguration.disabled(
                locale: bundleLocale(catalogURL: bundleCatalogURL),
                appBuild: appBuild(bundle: bundle),
                supportedCapabilities: ContentPolicy.supportedCapabilities
            )
            : makeConfiguration(
                bundle: bundle,
                bundleCatalogURL: bundleCatalogURL,
                processInfo: processInfo
            )

        guard let storageRootURL = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent(
            bundle.bundleIdentifier ?? "com.fanxi.learnnow",
            isDirectory: true
        )
        .appendingPathComponent("ContentUpdates", isDirectory: true)
        .appendingPathComponent("v1", isDirectory: true)
        else {
            return BundleCatalogRepository(bundle: bundle)
        }

        return ContentUpdateCatalogRepository(
            bundleCatalogURL: bundleCatalogURL,
            storageRootURL: storageRootURL,
            configuration: configuration
        )
    }

    private static func makeConfiguration(
        bundle: Bundle,
        bundleCatalogURL: URL,
        processInfo: ProcessInfo
    ) -> ContentUpdateConfiguration {
        let environment = processInfo.environment
        let manifestValue = environment["LEARNNOW_CONTENT_MANIFEST_URL"]
            ?? bundle.object(forInfoDictionaryKey: "LearnNowContentManifestURL") as? String
        let filesBaseValue = environment["LEARNNOW_CONTENT_FILES_BASE_URL"]
            ?? bundle.object(forInfoDictionaryKey: "LearnNowContentFilesBaseURL") as? String

        var keys = infoDictionaryPublicKeys(bundle: bundle)
        if let keyID = environment["LEARNNOW_CONTENT_PUBLIC_KEY_ID"],
           let encodedKey = environment["LEARNNOW_CONTENT_PUBLIC_KEY"],
           let key = decodePublicKey(encodedKey)
        {
            keys[keyID] = key
        }

        return ContentUpdateConfiguration(
            manifestURL: normalizedURL(manifestValue),
            filesBaseURL: normalizedURL(filesBaseValue),
            trustedPublicKeys: keys,
            locale: bundleLocale(catalogURL: bundleCatalogURL),
            appBuild: appBuild(bundle: bundle),
            supportedCapabilities: ContentPolicy.supportedCapabilities,
            allowRollback: false
        )
    }

    private static func infoDictionaryPublicKeys(bundle: Bundle) -> [String: Data] {
        guard let values = bundle.object(
            forInfoDictionaryKey: "LearnNowContentPublicKeys"
        ) as? [String: String] else {
            return [:]
        }
        return values.reduce(into: [:]) { result, pair in
            if let data = decodePublicKey(pair.value) {
                result[pair.key] = data
            }
        }
    }

    private static func normalizedURL(_ value: String?) -> URL? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty,
              !value.hasPrefix("$(")
        else {
            return nil
        }
        return URL(string: value)
    }

    private static func decodePublicKey(_ value: String) -> Data? {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if let data = Data(base64Encoded: normalized), data.count == 32 {
            return data
        }
        guard normalized.count == 64,
              normalized.allSatisfy(\.isHexDigit)
        else {
            return nil
        }

        var data = Data()
        var index = normalized.startIndex
        while index < normalized.endIndex {
            let next = normalized.index(index, offsetBy: 2)
            guard let byte = UInt8(normalized[index ..< next], radix: 16) else {
                return nil
            }
            data.append(byte)
            index = next
        }
        return data.count == 32 ? data : nil
    }

    private static func appBuild(bundle: Bundle) -> Int {
        let value = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return value.flatMap(Int.init) ?? 0
    }

    private static func bundleLocale(catalogURL: URL) -> String {
        guard let data = try? Data(contentsOf: catalogURL),
              let document = try? DeterministicJSON.decode(CatalogDocumentV2.self, from: data)
        else {
            return "zh-Hans"
        }
        return document.locale
    }

#if DEBUG
    private static func previewCatalogURL(
        processInfo: ProcessInfo,
        fileManager: FileManager
    ) -> URL? {
        guard let value = processInfo.environment["LEARNNOW_CONTENT_PREVIEW_CATALOG"],
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }
        let expanded = NSString(string: value).expandingTildeInPath
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: expanded, isDirectory: &isDirectory) else {
            return nil
        }
        if isDirectory.boolValue {
            let candidate = URL(filePath: expanded, directoryHint: .isDirectory)
                .appendingPathComponent("CatalogV2.json")
            return fileManager.fileExists(atPath: candidate.path) ? candidate : nil
        }
        return URL(filePath: expanded)
    }
#endif
}
