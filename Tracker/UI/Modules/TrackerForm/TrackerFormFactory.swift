import SwiftUI
import TrackerDomain

struct TrackerFormFactory {
    private let trackerManager: any TrackerManaging
    private let notificationManager: any AppNotificationManaging
    private let sectionRepository: any SectionRepositoryProtocol

    init(
        trackerManager: some TrackerManaging,
        notificationManager: some AppNotificationManaging,
        sectionRepository: some SectionRepositoryProtocol
    ) {
        self.trackerManager = trackerManager
        self.notificationManager = notificationManager
        self.sectionRepository = sectionRepository
    }

    @MainActor
    func makeViewModel(mode: TrackerFormMode) -> TrackerFormViewModel {
        TrackerFormViewModel(
            trackerManager: trackerManager,
            notificationManager: notificationManager,
            sectionRepository: sectionRepository,
            mode: mode
        )
    }

    @MainActor
    static func makeView(
        viewModel: TrackerFormViewModel,
        onSectionSelection: @escaping (UUID?) -> Void,
        onCompleted: @escaping (TrackerFormOutput) -> Void,
        onClose: @escaping () -> Void
    ) -> some View {
        TrackerFormView(
            viewModel: viewModel,
            onSectionSelection: onSectionSelection,
            onCompleted: onCompleted,
            onClose: onClose
        )
    }
}
