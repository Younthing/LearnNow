import StoreKit
import SwiftUI

struct ProfileSettingsScreen: View {
    let model: SettingsScreenModel
    @Binding var reminderTime: Date
    @Binding var remindersEnabled: Bool
    @Binding var isNightModeEnabled: Bool
    let onSetCloudSyncEnabled: (Bool) -> Void
    let onUpgradeCloudSync: () -> Void

    @State private var cloudConfirmation: CloudSyncConfirmation?
    @State private var showingManageSubscriptions = false

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $remindersEnabled) {
                    Label("每日学习提醒", systemImage: "bell.fill")
                }
                .accessibilityIdentifier("settings.reminders.toggle")

                if remindersEnabled {
                    DatePicker(
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    ) {
                        Label("提醒时间", systemImage: "clock")
                    }
                    .accessibilityIdentifier("settings.reminders.time")
                }
            } header: {
                Text("学习提醒")
            } footer: {
                Text("每天用一个轻提醒，把学习重新拉回日程。")
            }

            Section("外观") {
                Toggle(isOn: $isNightModeEnabled) {
                    Label(
                        "夜间模式",
                        systemImage: isNightModeEnabled ? "moon.stars.fill" : "sun.max.fill"
                    )
                }
                .accessibilityIdentifier("settings.appearance.toggle")
            }

            Section {
                if model.showsCloudSyncToggle {
                    Toggle(
                        isOn: Binding(
                            get: { model.desiredCloudSyncEnabled },
                            set: { cloudConfirmation = CloudSyncConfirmation(enabled: $0) }
                        )
                    ) {
                        Label("云同步", systemImage: "icloud")
                    }
                    .accessibilityIdentifier("settings.cloud.toggle")

                    Button {
                        showingManageSubscriptions = true
                    } label: {
                        Label("管理订阅", systemImage: "creditcard")
                    }
                    .foregroundStyle(LearnNowPalette.textPrimary)
                    .accessibilityIdentifier("settings.cloud.manage")
                } else {
                    Button {
                        onUpgradeCloudSync()
                    } label: {
                        Label("升级以开启云同步", systemImage: "icloud")
                    }
                    .foregroundStyle(LearnNowPalette.textPrimary)
                    .accessibilityIdentifier("settings.cloud.upgrade")
                }

                LabeledContent("状态") {
                    Text(model.syncStatusText)
                        .foregroundStyle(
                            model.requiresRestart
                                ? LearnNowSemanticRole.warning.foreground
                                : LearnNowPalette.textSecondary
                        )
                }
            } header: {
                Text("数据与同步")
            } footer: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(model.syncDetailText)

                    if model.requiresRestart {
                        Text("重新打开 App 后生效")
                            .fontWeight(.bold)
                            .foregroundStyle(LearnNowSemanticRole.warning.foreground)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(LearnNowPalette.canvas.ignoresSafeArea())
        .navigationTitle(model.title)
        .learnNowInlineNavigationTitle()
        .learnNowNavigationBarVisible()
        .alert(item: $cloudConfirmation) { confirmation in
            Alert(
                title: Text(confirmation.enabled ? "开启云同步？" : "关闭云同步？"),
                message: Text(
                    confirmation.enabled
                        ? "下次启动时会连接 iCloud，并与本机记录合并。"
                        : "下次启动后停止同步；本机和 iCloud 中已有记录都不会被删除。"
                ),
                primaryButton: .default(Text(confirmation.enabled ? "开启" : "关闭")) {
                    onSetCloudSyncEnabled(confirmation.enabled)
                },
                secondaryButton: .cancel()
            )
        }
        .manageSubscriptionsSheet(isPresented: $showingManageSubscriptions)
        .accessibilityIdentifier("screen.profile.settings")
    }
}

private struct CloudSyncConfirmation: Identifiable {
    let enabled: Bool

    var id: Bool { enabled }
}

#Preview("Settings · Upgrade entry") {
    NavigationStack {
        ProfileSettingsScreen(
            model: SettingsScreenModel(
                title: "设置",
                syncStatusText: "需要订阅",
                syncDetailText: "云同步需要订阅。本机学习、复习与路径不受影响。",
                desiredCloudSyncEnabled: false,
                requiresRestart: false,
                isCloudSyncEntitled: false,
                showsCloudSyncToggle: false
            ),
            reminderTime: .constant(Date()),
            remindersEnabled: .constant(true),
            isNightModeEnabled: .constant(false),
            onSetCloudSyncEnabled: { _ in },
            onUpgradeCloudSync: {}
        )
    }
}

#Preview("Settings · Sync on") {
    NavigationStack {
        ProfileSettingsScreen(
            model: SettingsScreenModel(
                title: "设置",
                syncStatusText: "iCloud 同步",
                syncDetailText: "学习进度、复习记录和个人资料正在通过 iCloud 同步。",
                desiredCloudSyncEnabled: true,
                requiresRestart: false,
                isCloudSyncEntitled: true,
                showsCloudSyncToggle: true
            ),
            reminderTime: .constant(Date()),
            remindersEnabled: .constant(true),
            isNightModeEnabled: .constant(false),
            onSetCloudSyncEnabled: { _ in },
            onUpgradeCloudSync: {}
        )
    }
}

#Preview("Settings · Restart pending") {
    NavigationStack {
        ProfileSettingsScreen(
            model: SettingsScreenModel(
                title: "设置",
                syncStatusText: "等待关闭",
                syncDetailText: "下次启动后停止同步，本机和云端已有记录都不会被删除。",
                desiredCloudSyncEnabled: false,
                requiresRestart: true,
                isCloudSyncEntitled: true,
                showsCloudSyncToggle: true
            ),
            reminderTime: .constant(Date()),
            remindersEnabled: .constant(true),
            isNightModeEnabled: .constant(false),
            onSetCloudSyncEnabled: { _ in },
            onUpgradeCloudSync: {}
        )
    }
}
