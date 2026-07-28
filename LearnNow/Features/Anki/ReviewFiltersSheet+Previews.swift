import SwiftUI

private struct ReviewFiltersPreviewSurface: View {
    @State private var flow: LearnNowFlowState

    init(flow: LearnNowFlowState) {
        _flow = State(initialValue: flow)
    }

    var body: some View {
        ReviewFiltersSheet(
            model: flow.reviewFiltersSheetModel,
            onReset: { flow.resetDraftReviewFilters() },
            onSelectTime: { flow.setDraftTimeFilter($0) },
            onToggleTopic: { flow.toggleDraftTopic($0) },
            onToggleModule: { flow.toggleDraftModule($0) },
            onSelectMastery: { flow.setDraftMasteryFilter($0) },
            onSelectFavorite: { flow.setDraftFavoriteFilter($0) },
            onToggleFavorite: { flow.toggleFavorited(for: $0) },
            onToggleMastered: { flow.toggleMastered(for: $0) },
            onApply: { flow.applyReviewCardPoolFilters() }
        )
    }
}

#Preview("Card Pool · Default") {
    ReviewFiltersPreviewSurface(flow: .reviewBoardPreview)
}

#Preview("Card Pool · Filtered") {
    ReviewFiltersPreviewSurface(flow: .reviewBoardFilteredPreview)
}

#Preview("Card Pool · No Matches") {
    ReviewFiltersPreviewSurface(flow: .reviewBoardEmptyPreview)
}

#Preview("Card Pool · No Cards") {
    ReviewFiltersPreviewSurface(flow: LearnNowFlowState(snapshot: .empty))
}

#Preview("Card Pool · Dark") {
    ReviewFiltersPreviewSurface(flow: .reviewBoardPreview)
        .preferredColorScheme(.dark)
}

#Preview("Card Pool · Accessibility 3") {
    ReviewFiltersPreviewSurface(flow: .reviewBoardPreview)
        .environment(\.dynamicTypeSize, .accessibility3)
}
