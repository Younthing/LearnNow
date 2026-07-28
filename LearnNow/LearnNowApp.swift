//
//  LearnNowApp.swift
//  LearnNow
//
//  Created by fanxi on 3/31/26.
//

import SwiftUI
import SwiftData

@main
struct LearnNowApp: App {
    private let activeCloudSyncEnabled: Bool
    private let sharedModelContainer: Result<ModelContainer, Error>

    init() {
        let processInfo = ProcessInfo.processInfo
        let isUITesting = processInfo.arguments.contains("-UITestingResetData")
        let isUnitTesting = processInfo.environment["LEARNNOW_TESTING"] == "YES"
        let usesEphemeralStore = isUITesting || isUnitTesting
        let simulatesActiveCloudSync = isUITesting &&
            processInfo.arguments.contains("-UITestingActiveCloudSyncEnabled")

        let preference = LearnNowCloudSyncPreference.isEnabled()
        let entitled = SubscriptionEntitlement.isEntitled(processInfo: processInfo)
        // Avoid a “waiting to enable” state when preference is on but entitlement is missing.
        if preference, !entitled, !usesEphemeralStore {
            LearnNowCloudSyncPreference.setEnabled(false)
        }
        let gatedCloudSync = LearnNowCloudSyncPreference.effectiveEnabled(
            preference: LearnNowCloudSyncPreference.isEnabled(),
            entitled: entitled
        )
        let activeCloudSyncEnabled = simulatesActiveCloudSync ||
            (!usesEphemeralStore && gatedCloudSync)

        self.activeCloudSyncEnabled = activeCloudSyncEnabled
        self.sharedModelContainer = Result {
            try LearnNowModelContainerFactory.make(
                cloudSyncEnabled: activeCloudSyncEnabled,
                inMemory: usesEphemeralStore
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            switch sharedModelContainer {
            case .success(let container):
                ContentView(activeCloudSyncEnabled: activeCloudSyncEnabled)
                    .modelContainer(container)
            case .failure(let error):
                ContentUnavailableView(
                    "学习记录无法打开",
                    systemImage: "externaldrive.badge.exclamationmark",
                    description: Text(error.localizedDescription)
                )
            }
        }
    }
}
