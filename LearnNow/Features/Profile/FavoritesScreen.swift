import SwiftUI

struct FavoritesScreen: View {
    let model: FavoritesScreenModel
    let onToggleFavorite: (String) -> Void
    let onToggleMastered: (String) -> Void
    let onStartReview: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(model.countText)
                            .font(LearnNowTypography.body)
                            .foregroundStyle(LearnNowPalette.textSecondary)

                        Spacer()
                    }

                    if model.items.isEmpty {
                        FavoritesEmptyState()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(model.items) { item in
                                FavoriteCardRow(
                                    item: item,
                                    onToggleFavorite: { onToggleFavorite(item.id) },
                                    onToggleMastered: { onToggleMastered(item.id) }
                                )
                            }
                        }
                    }
                }
                .padding(
                    .horizontal,
                    LearnNowSpacing.screenHorizontal(for: geometry.size.width)
                )
                .padding(.top, 16)
                .padding(.bottom, 20)
                .frame(maxWidth: LearnNowSpacing.maximumContentWidth)
                .frame(maxWidth: .infinity)
            }
        }
        .background(LearnNowPalette.canvas.ignoresSafeArea())
        .navigationTitle(model.title)
        .learnNowInlineNavigationTitle()
        .learnNowNavigationBarVisible()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if model.canStartReview {
                FullWidthButton(
                    title: "开始收藏复习",
                    role: .brand,
                    systemImage: "play.fill",
                    action: onStartReview
                )
                .padding(.horizontal, LearnNowSpacing.screenHorizontal)
                .padding(.vertical, 10)
                .learnNowBarBackground()
                .padding(.bottom, LearnNowSpacing.floatingTabBarClearance)
                .accessibilityIdentifier("favorites.startReview")
            }
        }
        .accessibilityIdentifier("screen.favorites")
    }
}

private struct FavoritesEmptyState: View {
    var body: some View {
        SoftCard(contentPadding: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "bookmark")
                    .font(.title.weight(.bold))
                    .foregroundStyle(LearnNowPalette.color(for: .pink))

                Text("还没有收藏卡片")
                    .font(LearnNowTypography.cardHeadline)
                    .foregroundStyle(LearnNowPalette.textPrimary)

                Text("在复习卡片中点亮书签，值得反复看的知识会集中出现在这里。")
                    .font(LearnNowTypography.body)
                    .foregroundStyle(LearnNowPalette.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct FavoriteCardRow: View {
    let item: FavoritesScreenModel.Item
    let onToggleFavorite: () -> Void
    let onToggleMastered: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        SoftCard(contentPadding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LearnNowPalette.base)
                            .frame(width: 42, height: 42)
                            .modifier(InsetSurface(cornerRadius: 21))

                        Image(systemName: "bookmark.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(LearnNowPalette.color(for: item.accent))
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.title)
                            .font(LearnNowTypography.cardTitle)
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(item.subtitle)
                            .font(LearnNowTypography.screenSubtitle)
                            .foregroundStyle(LearnNowPalette.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 8) {
                        topicChip
                        dueChip
                    }
                } else {
                    HStack(spacing: 8) {
                        topicChip
                        dueChip
                        Spacer()
                    }
                }

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: 10) {
                        masteryButton
                        removeButton
                    }
                } else {
                    HStack(spacing: 10) {
                        masteryButton
                        removeButton
                    }
                }
            }
        }
    }

    private var topicChip: some View {
        MetadataChip(text: item.topic, accent: item.accent, prominence: .subtle)
    }

    private var dueChip: some View {
        MetadataChip(
            text: item.dueText,
            accent: .blue,
            prominence: .subtle
        )
    }

    private var masteryButton: some View {
        Button(action: onToggleMastered) {
            Label(
                item.isMastered ? "已掌握" : "标为掌握",
                systemImage: item.isMastered ? "checkmark.seal.fill" : "checkmark.seal"
            )
            .font(LearnNowTypography.label)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
        .foregroundStyle(
            item.isMastered
                ? LearnNowSemanticRole.brand.foreground
                : LearnNowPalette.textSecondary
        )
        .background(LearnNowPalette.base, in: Capsule())
        .modifier(InsetSurface(cornerRadius: 22))
        .accessibilityIdentifier("favorites.mastered.\(item.id)")
    }

    private var removeButton: some View {
        Button(action: onToggleFavorite) {
            Label("取消收藏", systemImage: "bookmark.slash")
                .font(LearnNowTypography.label)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
        .foregroundStyle(LearnNowPalette.color(for: .pink))
        .background(LearnNowPalette.base, in: Capsule())
        .modifier(InsetSurface(cornerRadius: 22))
        .accessibilityIdentifier("favorites.remove.\(item.id)")
    }
}

#Preview("Favorites · Populated") {
    NavigationStack {
        FavoritesScreen(
            model: LearnNowFlowState.profilePreview.favoritesScreenModel,
            onToggleFavorite: { _ in },
            onToggleMastered: { _ in },
            onStartReview: {}
        )
    }
}

#Preview("Favorites · Empty") {
    NavigationStack {
        FavoritesScreen(
            model: LearnNowFlowState.profileEmptyPreview.favoritesScreenModel,
            onToggleFavorite: { _ in },
            onToggleMastered: { _ in },
            onStartReview: {}
        )
    }
}
