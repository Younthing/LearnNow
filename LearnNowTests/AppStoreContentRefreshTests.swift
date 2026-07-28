import SwiftData
import Testing
@testable import LearnNow

@MainActor
struct AppStoreContentRefreshTests {
    @Test
    func successfulInitialLoadStartsANonBlockingContentRefresh() async throws {
        let catalogRepository = RefreshableCatalogRepositorySpy(
            catalog: LearnNowFlowFixtures.catalog
        )
        let container = try LearnNowModelContainerFactory.make(
            cloudSyncEnabled: false,
            inMemory: true
        )
        let store = LearnNowAppStore(
            catalogRepository: catalogRepository,
            activeCloudSyncEnabled: false
        )

        await store.load(context: ModelContext(container))

        #expect(store.loadState == .ready)
        for _ in 0 ..< 100 {
            if catalogRepository.refreshCount > 0 {
                break
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(catalogRepository.refreshCount == 1)
        #expect(store.flow.catalog.releaseVersion == LearnNowFlowFixtures.catalog.releaseVersion)
    }
}

@MainActor
private final class RefreshableCatalogRepositorySpy: RefreshableCatalogRepository {
    let catalog: CourseCatalog
    private(set) var refreshCount = 0

    init(catalog: CourseCatalog) {
        self.catalog = catalog
    }

    func load() async throws -> CourseCatalog {
        catalog
    }

    func refresh() async -> ContentRefreshOutcome {
        refreshCount += 1
        return .notModified
    }
}
