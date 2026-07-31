import StoreKit
import SwiftUI

struct ProfileSettingsScreen: View {
    private static let privacyPolicyURL = URL(string: "https://app.notion.com/p/3aeeeba16e66808790bdeca25f4daf93")!
    private static let supportURL = URL(string: "https://app.notion.com/p/3aeeeba16e66801481c6e20fb119855f")!

    let model: SettingsScreenModel
    @Binding var reminderTime: Date
    @Binding var remindersEnabled: Bool
    @Binding var isNightModeEnabled: Bool
    @Binding var selectedTheme: LearnNowTheme
    let onSetCloudSyncEnabled: (Bool) -> Void
    let onUpgradeCloudSync: () -> Void

    #if os(macOS)
    @Environment(\.openURL) private var openURL
    #endif
    @State private var cloudConfirmation: CloudSyncConfirmation?
    #if os(iOS)
    @State private var showingManageSubscriptions = false
    #endif

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
            .listRowBackground(LearnNowPalette.surfaceOpaque)

            Section("外观") {
                Toggle(isOn: $isNightModeEnabled) {
                    Label(
                        "夜间模式",
                        systemImage: isNightModeEnabled ? "moon.stars.fill" : "sun.max.fill"
                    )
                }
                .accessibilityIdentifier("settings.appearance.toggle")

                Picker(selection: $selectedTheme) {
                    ForEach(LearnNowTheme.allCases) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                } label: {
                    Label("主题", systemImage: "paintpalette.fill")
                }
                .accessibilityIdentifier("settings.appearance.theme")
            }
            .listRowBackground(LearnNowPalette.surfaceOpaque)

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
                        #if os(iOS)
                        showingManageSubscriptions = true
                        #else
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            openURL(url)
                        }
                        #endif
                    } label: {
                        Label("管理订阅", systemImage: "creditcard")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(LearnNowPalette.textPrimary)
                    .accessibilityIdentifier("settings.cloud.manage")
                } else {
                    Button {
                        onUpgradeCloudSync()
                    } label: {
                        Label("升级以开启云同步", systemImage: "icloud")
                    }
                    .buttonStyle(.plain)
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
            .listRowBackground(LearnNowPalette.surfaceOpaque)

            Section("支持与隐私") {
                Link(destination: Self.privacyPolicyURL) {
                    Label("隐私政策", systemImage: "hand.raised.fill")
                }
                .accessibilityIdentifier("settings.privacy.policy")

                Link(destination: Self.supportURL) {
                    Label("支持与联系", systemImage: "questionmark.circle")
                }
                .accessibilityIdentifier("settings.support")
            }
            .listRowBackground(LearnNowPalette.surfaceOpaque)
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(LearnNowPalette.canvas.ignoresSafeArea())
        .tint(LearnNowSemanticRole.brand.foreground)
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
        #if os(iOS)
        .manageSubscriptionsSheet(isPresented: $showingManageSubscriptions)
        #endif
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
            selectedTheme: .constant(.emerald),
            onSetCloudSyncEnabled: { _ in },
            onUpgradeCloudSync: {}
        )
    }
    .onAppear { LearnNowThemeStore.current = .emerald }
    .preferredColorScheme(.light)
    .tint(LearnNowSemanticRole.brand.foreground)
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
            selectedTheme: .constant(.sand),
            onSetCloudSyncEnabled: { _ in },
            onUpgradeCloudSync: {}
        )
    }
    .onAppear { LearnNowThemeStore.current = .sand }
    .preferredColorScheme(.light)
    .tint(LearnNowSemanticRole.brand.foreground)
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
            isNightModeEnabled: .constant(true),
            selectedTheme: .constant(.ink),
            onSetCloudSyncEnabled: { _ in },
            onUpgradeCloudSync: {}
        )
    }
    .onAppear { LearnNowThemeStore.current = .ink }
    .preferredColorScheme(.dark)
    .tint(LearnNowSemanticRole.brand.foreground)
}
