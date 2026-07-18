import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class LearnNowAppStore {
    enum LoadState: Equatable {
        case loading
        case ready
        case catalogError(String)
        case persistenceError(String)
    }

    var loadState: LoadState = .loading
    var flow: LearnNowFlowState
    var lastActionError: String?

    private let catalogRepository: any CatalogRepository
    private let scheduler: any ReviewScheduler
    private let clock: any LearnNowClock
    private let router = LearnNowRouter()
    private var learningRepository: (any LearningRepository)?

    init(
        catalogRepository: (any CatalogRepository)? = nil,
        scheduler: (any ReviewScheduler)? = nil,
        clock: (any LearnNowClock)? = nil
    ) {
        self.flow = LearnNowFlowState(catalog: .empty, snapshot: .empty)
        self.catalogRepository = catalogRepository ?? BundleCatalogRepository()
        self.scheduler = scheduler ?? FSRSReviewScheduler()
        self.clock = clock ?? SystemLearnNowClock()
    }

    func load(context: ModelContext, force: Bool = false) async {
        if !force, loadState == .ready { return }
        loadState = .loading

        let loadedCatalog: CourseCatalog
        do {
            loadedCatalog = try await catalogRepository.load()
        } catch {
            loadState = .catalogError(error.localizedDescription)
            return
        }

        let repository = SwiftDataLearningRepository(
            context: context,
            clock: clock,
            scheduler: scheduler
        )
        do {
            try LearnNowCloudKitSchemaInitializer.runIfRequested(context: context, now: clock.now)
            let snapshot = try await repository.loadSnapshot(catalog: loadedCatalog)
            learningRepository = repository
            flow = LearnNowFlowState(catalog: loadedCatalog, snapshot: snapshot, now: clock.now)
            prepareReviewPreviews()
            loadState = .ready
        } catch {
            loadState = .persistenceError(error.localizedDescription)
        }
    }

    func selectTab(_ tab: LearnNowTab) {
        router.selectTab(tab, flow: &flow)
        prepareReviewPreviews()
    }

    func showRoutes() { router.showRoutes(flow: &flow) }
    func openPath() { router.openPath(flow: &flow) }
    func openPathForLoadedLesson() { router.openPathForLoadedLesson(flow: &flow) }
    func selectRouteTrack(_ track: LearnNowRouteTrack) { router.selectRouteTrack(track, flow: &flow) }

    func openLesson() {
        router.openLesson(flow: &flow)
        persistCurrentPage()
    }

    func openLesson(moduleID: String) {
        router.openLesson(moduleID: moduleID, flow: &flow)
        persistCurrentPage()
    }

    func setCurrentLessonPageIndex(_ index: Int) {
        flow.setCurrentLessonPageIndex(index)
        persistCurrentPage()
    }

    func answerCurrentLesson(with optionID: String) {
        flow.answerCurrentLesson(with: optionID)
    }

    func handleLessonCallToAction(_ action: LearnNowLessonCallToAction) {
        switch action {
        case .completeLesson:
            completeCurrentLesson()
        case .nextPage, .retry:
            flow.handleLessonCallToAction(action)
            persistCurrentPage()
        }
    }

    func openNextLesson() {
        router.openNextLesson(flow: &flow)
        persistCurrentPage()
    }

    func finishLearning() { router.finishLearning(flow: &flow) }

    func openReviewBoard() {
        router.openReviewBoard(flow: &flow)
        prepareReviewPreviews()
    }

    func openFavoritedReviewBoard() {
        router.openFavoritedReviewBoard(flow: &flow)
        prepareReviewPreviews()
    }

    func openReviewCardPool() { flow.openReviewCardPool() }
    func dismissReviewSheet() { flow.dismissReviewSheet() }
    func resetDraftReviewFilters() { flow.resetDraftReviewFilters() }
    func toggleDraftTopic(_ topic: String) { flow.toggleDraftTopic(topic) }
    func toggleDraftModule(_ moduleID: String) { flow.toggleDraftModule(moduleID) }
    func setDraftTimeFilter(_ filter: LearnNowReviewTimeFilter) { flow.setDraftTimeFilter(filter) }
    func setDraftMasteryFilter(_ filter: LearnNowReviewMasteryFilter) { flow.setDraftMasteryFilter(filter) }
    func setDraftFavoriteFilter(_ filter: LearnNowReviewFavoriteFilter) { flow.setDraftFavoriteFilter(filter) }

    func applyReviewCardPoolFilters() {
        flow.applyReviewCardPoolFilters()
        prepareReviewPreviews()
    }

    func handleReviewEmptyPrimaryAction() { flow.handleReviewEmptyPrimaryAction() }

    func flipCurrentReviewCard() {
        flow.flipCurrentReviewCard()
        prepareReviewPreviews()
    }

    func toggleCurrentReviewCardMastered() {
        guard let cardID = flow.currentReviewCard?.id else { return }
        flow.toggleCurrentReviewCardMastered()
        persistPreference(for: cardID)
    }

    func toggleCurrentReviewCardFavorited() {
        guard let cardID = flow.currentReviewCard?.id else { return }
        flow.toggleCurrentReviewCardFavorited()
        persistPreference(for: cardID)
    }

    func toggleReviewCardMastered(id: String) {
        flow.toggleReviewCardMastered(id: id)
        persistPreference(for: id)
    }

    func toggleReviewCardFavorited(id: String) {
        flow.toggleReviewCardFavorited(id: id)
        persistPreference(for: id)
    }

    func rateCurrentReviewCard(_ rating: LearnNowReviewRating) {
        guard let repository = learningRepository,
              let cardID = flow.currentReviewCard?.id else { return }
        do {
            let outcome = try repository.recordReview(
                cardID: cardID,
                memory: flow.reviewMemoryByCardID[cardID],
                rating: rating
            )
            flow.applyReviewOutcome(outcome)
            prepareReviewPreviews()
        } catch {
            lastActionError = error.localizedDescription
        }
    }

    func setReminderTime(_ date: Date) { flow.setReminderTime(date) }
    func setRemindersEnabled(_ enabled: Bool) { flow.setRemindersEnabled(enabled) }
    func setNightModeEnabled(_ enabled: Bool) { flow.setNightModeEnabled(enabled) }

    private func completeCurrentLesson() {
        guard let repository = learningRepository,
              flow.modules.indices.contains(flow.loadedLessonModuleIndex),
              flow.lessonPages.indices.contains(flow.currentLessonPageIndex),
              flow.lessonPages[flow.currentLessonPageIndex].callToAction == .completeLesson else { return }
        let module = flow.modules[flow.loadedLessonModuleIndex]
        do {
            let awarded = try repository.completeLesson(lessonID: module.id, xp: module.completionXP)
            flow.completeLesson(awardXP: awarded)
        } catch {
            lastActionError = error.localizedDescription
        }
    }

    private func persistCurrentPage() {
        guard let repository = learningRepository,
              flow.modules.indices.contains(flow.loadedLessonModuleIndex),
              flow.lessonPages.indices.contains(flow.currentLessonPageIndex) else { return }
        do {
            try repository.recordPageVisit(
                lessonID: flow.modules[flow.loadedLessonModuleIndex].id,
                pageID: flow.lessonPages[flow.currentLessonPageIndex].id,
                pageOrder: flow.currentLessonPageIndex
            )
        } catch {
            lastActionError = error.localizedDescription
        }
    }

    private func persistPreference(for cardID: String) {
        guard let repository = learningRepository,
              let card = flow.reviewCards.first(where: { $0.id == cardID }) else { return }
        do {
            try repository.setCardPreference(
                cardID: cardID,
                isFavorited: card.isFavorited,
                isMastered: card.isMastered
            )
        } catch {
            lastActionError = error.localizedDescription
        }
    }

    private func prepareReviewPreviews() {
        guard let cardID = flow.currentReviewCard?.id else { return }
        do {
            let previews = try scheduler.preview(
                cardID: cardID,
                memory: flow.reviewMemoryByCardID[cardID],
                now: clock.now
            )
            flow.setReviewPreviews(previews)
        } catch {
            lastActionError = error.localizedDescription
        }
    }
}
