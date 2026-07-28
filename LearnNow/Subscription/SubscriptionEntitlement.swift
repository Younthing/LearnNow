import Foundation

/// Launch-time entitlement cache. StoreKit refreshes this after `Transaction` checks.
enum SubscriptionEntitlement {
    static let cacheKey = "learnnow.subscription.cloudSyncEntitled"
    static let uiTestingEntitledArgument = "-UITestingCloudSyncEntitled"

    static func isEntitled(
        in defaults: UserDefaults = .standard,
        processInfo: ProcessInfo = .processInfo
    ) -> Bool {
        if processInfo.arguments.contains(uiTestingEntitledArgument) {
            return true
        }
        return defaults.bool(forKey: cacheKey)
    }

    static func setEntitled(_ entitled: Bool, in defaults: UserDefaults = .standard) {
        defaults.set(entitled, forKey: cacheKey)
    }
}
