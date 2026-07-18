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
    private let sharedModelContainer: Result<ModelContainer, Error> = {
        let processInfo = ProcessInfo.processInfo
        let isUITesting = processInfo.arguments.contains("-UITestingResetData")
        let isUnitTesting = processInfo.environment["LEARNNOW_TESTING"] == "YES"
        let usesEphemeralStore = isUITesting || isUnitTesting
        return Result {
            try LearnNowModelContainerFactory.make(
                cloudSyncEnabled: !usesEphemeralStore,
                inMemory: usesEphemeralStore
            )
        }
    }()

    var body: some Scene {
        WindowGroup {
            switch sharedModelContainer {
            case .success(let container):
                ContentView()
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
