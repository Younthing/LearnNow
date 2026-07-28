import Foundation

enum LearnNowProductID {
    static let cloudSyncMonthly = "fanxi.LearnNow.cloudsync.monthly"
    static let cloudSyncYearly = "fanxi.LearnNow.cloudsync.yearly"

    static let cloudSyncAll: Set<String> = [
        cloudSyncMonthly,
        cloudSyncYearly,
    ]

    static func periodLabel(for productID: String) -> String {
        switch productID {
        case cloudSyncMonthly:
            "每月"
        case cloudSyncYearly:
            "每年"
        default:
            "订阅"
        }
    }
}
