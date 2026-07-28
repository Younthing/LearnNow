import Foundation
import SwiftData
import Testing
@testable import LearnNow

@MainActor
struct SubscriptionGateTests {
    @Test
    func setCloudSyncEnabledTrueDoesNotWritePreferenceWithoutEntitlement() throws {
        let suiteName = "SubscriptionGateTests.pref.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let previous = UserDefaults.standard.object(forKey: LearnNowCloudSyncPreference.userDefaultsKey)
        defer {
            if let previous {
                UserDefaults.standard.set(previous, forKey: LearnNowCloudSyncPreference.userDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: LearnNowCloudSyncPreference.userDefaultsKey)
            }
        }

        UserDefaults.standard.set(false, forKey: LearnNowCloudSyncPreference.userDefaultsKey)

        let store = LearnNowAppStore(
            catalogRepository: StaticCatalogRepository(catalog: LearnNowFlowFixtures.catalog),
            activeCloudSyncEnabled: false,
            subscriptionStore: SubscriptionStore(
                testingEntitlementOverride: false,
                defaults: defaults
            )
        )

        store.setCloudSyncEnabled(true)

        #expect(!LearnNowCloudSyncPreference.isEnabled())
        #expect(!store.flow.desiredCloudSyncEnabled)
    }

    @Test
    func setCloudSyncEnabledTrueWritesPreferenceWhenEntitled() throws {
        let suiteName = "SubscriptionGateTests.entitled.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let previous = UserDefaults.standard.object(forKey: LearnNowCloudSyncPreference.userDefaultsKey)
        defer {
            if let previous {
                UserDefaults.standard.set(previous, forKey: LearnNowCloudSyncPreference.userDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: LearnNowCloudSyncPreference.userDefaultsKey)
            }
        }

        UserDefaults.standard.set(false, forKey: LearnNowCloudSyncPreference.userDefaultsKey)

        let store = LearnNowAppStore(
            catalogRepository: StaticCatalogRepository(catalog: LearnNowFlowFixtures.catalog),
            activeCloudSyncEnabled: false,
            subscriptionStore: SubscriptionStore(
                testingEntitlementOverride: true,
                defaults: defaults
            )
        )

        store.setCloudSyncEnabled(true)

        #expect(LearnNowCloudSyncPreference.isEnabled())
        #expect(store.flow.desiredCloudSyncEnabled)
    }
}

@MainActor
private struct StaticCatalogRepository: CatalogRepository {
    let catalog: CourseCatalog

    func load() async throws -> CourseCatalog {
        catalog
    }
}
