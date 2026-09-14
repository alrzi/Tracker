import SwiftUI
import TrackerDomain
import HapticFeedback

struct TrackersScreenFactory {
    private let trackerManager: any TrackerManaging
    private let hapticManager: any VibrationFeedbackManaging
    private let notificationDeepLinkService: any NotificationDeepLinkServiceProtocol
    private let viewModelsFactory: TrackersViewModelsFactory

    init(
        trackerManager: some TrackerManaging,
        hapticManager: some VibrationFeedbackManaging,
        notificationDeepLinkService: some NotificationDeepLinkServiceProtocol,
        viewModelsFactory: TrackersViewModelsFactory
    ) {
        self.trackerManager = trackerManager
        self.hapticManager = hapticManager
        self.notificationDeepLinkService = notificationDeepLinkService
        self.viewModelsFactory = viewModelsFactory
    }

    @MainActor
    func makeViewModel() -> TrackersViewModel {
        TrackersViewModel(
            trackerManager: trackerManager,
            hapticManager: hapticManager,
            notificationDeepLinkService: notificationDeepLinkService,
            trackersViewModelsFactory: viewModelsFactory
        )
    }

    @MainActor
    static func makeView(
        viewModel: TrackersViewModel,
        onCreate: @escaping () -> Void,
        onEdit: @escaping (Tracker) -> Void
    ) -> some View {
        TrackersView(viewModel: viewModel, onCreate: onCreate, onEdit: onEdit)
    }
}
