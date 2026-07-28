import SwiftUI

struct ProfileContainer: View {
    @Bindable var store: LearnNowAppStore
    let resetRequest: Int

    @State private var path: [ProfileRoute] = []
    @State private var presentedSheet: ProfileSheet?

    var body: some View {
        NavigationStack(path: $path) {
            ProfileScreen(
                model: store.flow.profileScreenModel,
                onEditProfile: { presentedSheet = .editProfile },
                onOpenCareer: {
                    path.removeAll()
                    store.openPath()
                },
                onOpenFavorites: { path.append(.favorites) },
                onOpenSettings: { path.append(.settings) }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ProfileRoute.self) { route in
                destination(for: route)
            }
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .editProfile:
                ProfileEditSheet(
                    initialDisplayName: store.flow.profileScreenModel.identity.displayName,
                    initialAvatarID: store.flow.profileScreenModel.identity.avatarID,
                    onSave: { displayName, avatarID in
                        store.saveProfile(displayName: displayName, avatarID: avatarID)
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        .onChange(of: resetRequest) {
            path.removeAll()
            presentedSheet = nil
        }
    }

    @ViewBuilder
    private func destination(for route: ProfileRoute) -> some View {
        switch route {
        case .favorites:
            FavoritesScreen(
                model: store.flow.favoritesScreenModel,
                onToggleFavorite: { store.toggleReviewCardFavorited(id: $0) },
                onToggleMastered: { store.toggleReviewCardMastered(id: $0) },
                onStartReview: {
                    path.removeAll()
                    store.openFavoritedReviewBoard()
                }
            )
        case .settings:
            ProfileSettingsScreen(
                model: store.flow.settingsScreenModel,
                reminderTime: Binding(
                    get: { store.flow.reminderTime },
                    set: { store.setReminderTime($0) }
                ),
                remindersEnabled: Binding(
                    get: { store.flow.remindersEnabled },
                    set: { store.setRemindersEnabled($0) }
                ),
                isNightModeEnabled: Binding(
                    get: { store.flow.isNightModeEnabled },
                    set: { store.setNightModeEnabled($0) }
                ),
                onSetCloudSyncEnabled: { store.setCloudSyncEnabled($0) }
            )
        }
    }
}
