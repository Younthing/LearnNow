import SwiftUI

struct ProfileSettingsScreen: View {
    let model: SettingsScreenModel
    @Binding var reminderTime: Date
    @Binding var remindersEnabled: Bool
    @Binding var isNightModeEnabled: Bool
    let onSetCloudSyncEnabled: (Bool) -> Void

    @State private var cloudConfirmation: CloudSyncConfirmation?

    var body: some View {
        Form {
            Section {
                Toggle("每日学习提醒", isOn: $remindersEnabled)
                    .accessibilityIdentifier("settings.reminders.toggle")

                if remindersEnabled {
                    DatePicker(
                        "提醒时间",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
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
                Toggle(
                    "云同步",
                    isOn: Binding(
                        get: { model.desiredCloudSyncEnabled },
                        set: { cloudConfirmation = CloudSyncConfirmation(enabled: $0) }
                    )
                )
                .accessibilityIdentifier("settings.cloud.toggle")

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
        .accessibilityIdentifier("screen.profile.settings")
    }
}

private struct CloudSyncConfirmation: Identifiable {
    let enabled: Bool

    var id: Bool { enabled }
}

#Preview("Settings · Sync on") {
    NavigationStack {
        ProfileSettingsScreen(
            model: SettingsScreenModel(
                title: "设置",
                syncStatusText: "iCloud 同步",
                syncDetailText: "学习进度、复习记录和个人资料正在通过 iCloud 同步。",
                desiredCloudSyncEnabled: true,
                requiresRestart: false
            ),
            reminderTime: .constant(Date()),
            remindersEnabled: .constant(true),
            isNightModeEnabled: .constant(false),
            onSetCloudSyncEnabled: { _ in }
        )
    }
}

#Preview("Settings · Sync off") {
    NavigationStack {
        ProfileSettingsScreen(
            model: SettingsScreenModel(
                title: "设置",
                syncStatusText: "同步已关闭",
                syncDetailText: "所有数据仅保存在本机；重新开启后可恢复合并。",
                desiredCloudSyncEnabled: false,
                requiresRestart: false
            ),
            reminderTime: .constant(Date()),
            remindersEnabled: .constant(false),
            isNightModeEnabled: .constant(true),
            onSetCloudSyncEnabled: { _ in }
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
                requiresRestart: true
            ),
            reminderTime: .constant(Date()),
            remindersEnabled: .constant(true),
            isNightModeEnabled: .constant(false),
            onSetCloudSyncEnabled: { _ in }
        )
    }
}
