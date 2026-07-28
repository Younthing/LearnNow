import Foundation

enum ProfileRoute: Hashable {
    case favorites
    case settings
}

enum ProfileSheet: String, Identifiable {
    case editProfile

    var id: String { rawValue }
}

enum ProfileInsightMode: String, CaseIterable, Identifiable {
    case overview
    case memoryTrend

    var id: Self { self }

    var title: String {
        switch self {
        case .overview:
            "概览"
        case .memoryTrend:
            "记忆趋势"
        }
    }
}

enum ProfileShortcutKind: String, Identifiable, Equatable {
    case career
    case favorites
    case settings

    var id: Self { self }
}

struct AvatarOption: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let assetName: String

    static let all: [Self] = [
        .init(id: "cat", name: "小猫", assetName: "avatar_cat"),
        .init(id: "dog", name: "小狗", assetName: "avatar_dog"),
        .init(id: "rabbit", name: "小兔", assetName: "avatar_rabbit"),
        .init(id: "fox", name: "小狐狸", assetName: "avatar_fox"),
        .init(id: "panda", name: "熊猫", assetName: "avatar_panda"),
        .init(id: "otter", name: "小水獭", assetName: "avatar_otter"),
        .init(id: "chick", name: "小鸡", assetName: "avatar_chick"),
        .init(id: "seal", name: "小海豹", assetName: "avatar_seal"),
    ]

    static let defaultID = "fox"

    static func option(for id: String) -> Self {
        all.first(where: { $0.id == id })
            ?? all.first(where: { $0.id == defaultID })
            ?? all[0]
    }
}

struct ProfileScreenModel: Equatable {
    struct Identity: Equatable {
        let displayName: String
        let avatarID: String
        let activityText: String
    }

    struct OverviewMetric: Identifiable, Equatable {
        let id: String
        let title: String
        let value: String
        let accent: LearnNowAccent
    }

    struct Overview: Equatable {
        let metrics: [OverviewMetric]
        let heatmap: [LearnNowHeatCell]
    }

    struct MemoryTrend: Equatable {
        let values: [Double]
        let currentText: String?
        let seventhDayText: String?

        var isEmpty: Bool { values.isEmpty }
    }

    struct Shortcut: Identifiable, Equatable {
        let kind: ProfileShortcutKind
        let title: String
        let subtitle: String
        let systemImage: String
        let accent: LearnNowAccent

        var id: ProfileShortcutKind { kind }
    }

    let title: String
    let identity: Identity
    let overview: Overview
    let memoryTrend: MemoryTrend
    let shortcuts: [Shortcut]
}

struct FavoritesScreenModel: Equatable {
    struct Item: Identifiable, Equatable {
        let id: String
        let title: String
        let subtitle: String
        let topic: String
        let dueText: String
        let accent: LearnNowAccent
        let isMastered: Bool
    }

    let title: String
    let countText: String
    let items: [Item]

    var canStartReview: Bool { !items.isEmpty }
}

struct SettingsScreenModel: Equatable {
    let title: String
    let syncStatusText: String
    let syncDetailText: String
    let desiredCloudSyncEnabled: Bool
    let requiresRestart: Bool
}
