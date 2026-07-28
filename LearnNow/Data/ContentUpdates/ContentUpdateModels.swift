import Foundation

nonisolated struct ContentUpdateLimits: Equatable, Sendable {
    var maximumManifestBytes: Int = 128 * 1_024
    var maximumFileCount: Int = 256
    var maximumFileBytes: Int = 24 * 1_024 * 1_024
    var maximumTotalBytes: Int = 96 * 1_024 * 1_024

    static let `default` = ContentUpdateLimits()
}

nonisolated struct ContentUpdateConfiguration: Sendable {
    let manifestURL: URL?
    let filesBaseURL: URL?
    let trustedPublicKeys: [String: Data]
    let locale: String
    let appBuild: Int
    let supportedCapabilities: Set<String>
    let allowRollback: Bool
    let limits: ContentUpdateLimits

    init(
        manifestURL: URL?,
        filesBaseURL: URL? = nil,
        trustedPublicKeys: [String: Data],
        locale: String,
        appBuild: Int,
        supportedCapabilities: Set<String>,
        allowRollback: Bool = false,
        limits: ContentUpdateLimits = .default
    ) {
        self.manifestURL = manifestURL
        self.filesBaseURL = filesBaseURL
        self.trustedPublicKeys = trustedPublicKeys
        self.locale = locale
        self.appBuild = appBuild
        self.supportedCapabilities = supportedCapabilities
        self.allowRollback = allowRollback
        self.limits = limits
    }

    static func disabled(
        locale: String = "zh-Hans",
        appBuild: Int = 0,
        supportedCapabilities: Set<String> = []
    ) -> ContentUpdateConfiguration {
        ContentUpdateConfiguration(
            manifestURL: nil,
            trustedPublicKeys: [:],
            locale: locale,
            appBuild: appBuild,
            supportedCapabilities: supportedCapabilities
        )
    }

    var hasRemoteConfiguration: Bool {
        manifestURL != nil && !trustedPublicKeys.isEmpty
    }
}

nonisolated enum ContentRefreshOutcome: Equatable, Sendable {
    case disabled
    case alreadyRefreshing
    case notModified
    case unchanged(releaseVersion: String)
    case activated(releaseVersion: String)
    case rejected(ContentUpdateFailure)
    case transportFailure
}

nonisolated enum ContentUpdateCommitCheckpoint: Equatable, Sendable {
    case releaseInstalledBeforeStateActivation
}

nonisolated enum ContentUpdateFailure: String, Error, Equatable, LocalizedError, Sendable {
    case invalidEndpoint
    case invalidHTTPStatus
    case manifestTooLarge
    case malformedManifest
    case unsupportedManifestSchema
    case missingSignature
    case unknownSigningKey
    case invalidSignature
    case invalidReleaseVersion
    case releaseVersionCollision
    case rollbackRejected
    case incompatibleLocale
    case incompatibleAppBuild
    case unsupportedCapabilities
    case malformedPublishedAt
    case tooManyFiles
    case invalidFileSize
    case packageTooLarge
    case unsafeFilePath
    case duplicateFilePath
    case invalidFileDigest
    case missingCatalog
    case duplicateCatalog
    case downloadedSizeMismatch
    case downloadedDigestMismatch
    case invalidCatalog
    case catalogMetadataMismatch
    case missingImageAsset
    case stateWriteFailed

    var errorDescription: String? {
        switch self {
        case .invalidEndpoint: "课程更新地址必须是安全的 HTTPS URL。"
        case .invalidHTTPStatus: "课程更新服务器返回了无效状态。"
        case .manifestTooLarge: "课程更新清单超过大小限制。"
        case .malformedManifest: "课程更新清单无法解析。"
        case .unsupportedManifestSchema: "课程更新清单版本不受支持。"
        case .missingSignature: "课程更新清单缺少签名。"
        case .unknownSigningKey: "课程更新清单使用了未知签名密钥。"
        case .invalidSignature: "课程更新清单签名无效。"
        case .invalidReleaseVersion: "课程更新版本号格式无效。"
        case .releaseVersionCollision: "相同课程版本号对应了不同内容。"
        case .rollbackRejected: "课程更新版本低于设备已接受的最高版本。"
        case .incompatibleLocale: "课程更新语言与当前内容不匹配。"
        case .incompatibleAppBuild: "课程更新需要更高版本的 App。"
        case .unsupportedCapabilities: "课程更新使用了当前 App 不支持的能力。"
        case .malformedPublishedAt: "课程更新发布时间格式无效。"
        case .tooManyFiles: "课程更新文件数量超过限制。"
        case .invalidFileSize: "课程更新包含无效的文件大小。"
        case .packageTooLarge: "课程更新总大小超过限制。"
        case .unsafeFilePath: "课程更新包含不安全的文件路径。"
        case .duplicateFilePath: "课程更新包含重复文件路径。"
        case .invalidFileDigest: "课程更新包含无效的文件摘要。"
        case .missingCatalog: "课程更新缺少 CatalogV2.json。"
        case .duplicateCatalog: "课程更新包含多份 CatalogV2.json。"
        case .downloadedSizeMismatch: "课程更新文件大小与清单不一致。"
        case .downloadedDigestMismatch: "课程更新文件摘要与清单不一致。"
        case .invalidCatalog: "课程目录未通过结构或语义校验。"
        case .catalogMetadataMismatch: "课程目录与更新清单的版本元数据不一致。"
        case .missingImageAsset: "课程目录引用了更新包中不存在的图片。"
        case .stateWriteFailed: "课程更新无法安全激活。"
        }
    }
}

nonisolated struct ContentManifestTransportResponse: Sendable {
    let statusCode: Int
    let data: Data
    let etag: String?
    let finalURL: URL
}

nonisolated struct ContentFileTransportResponse: Sendable {
    let statusCode: Int
    let bytesWritten: Int
    let finalURL: URL
}

nonisolated protocol ContentUpdateTransport: Sendable {
    func fetchManifest(
        from url: URL,
        ifNoneMatch etag: String?,
        maximumBytes: Int
    ) async throws -> ContentManifestTransportResponse

    func downloadFile(
        from url: URL,
        to destinationURL: URL,
        maximumBytes: Int
    ) async throws -> ContentFileTransportResponse
}
