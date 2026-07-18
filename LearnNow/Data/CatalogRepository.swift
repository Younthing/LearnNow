import Foundation

protocol CatalogRepository: Sendable {
    func load() async throws -> CourseCatalog
}

struct BundleCatalogRepository: CatalogRepository, @unchecked Sendable {
    let bundle: Bundle
    let resourceName: String

    init(bundle: Bundle = .main, resourceName: String = "CatalogV1") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func load() async throws -> CourseCatalog {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile, userInfo: [
                NSFilePathErrorKey: "\(resourceName).json"
            ])
        }
        return try CatalogDecoder.decode(data: Data(contentsOf: url))
    }
}

struct DataCatalogRepository: CatalogRepository {
    let data: Data

    func load() async throws -> CourseCatalog {
        try CatalogDecoder.decode(data: data)
    }
}
