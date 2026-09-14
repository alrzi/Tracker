import SwiftUI
import TrackerDomain

struct SectionsListFactory {
    private let sectionRepository: any SectionRepositoryProtocol

    init(sectionRepository: some SectionRepositoryProtocol) {
        self.sectionRepository = sectionRepository
    }

    @MainActor
    func makeViewModel(selectedSectionID: UUID?) -> SectionsListViewModel {
        SectionsListViewModel(
            sectionRepository: sectionRepository,
            sectionID: selectedSectionID
        )
    }

    @MainActor
    static func makeView(
        viewModel: SectionsListViewModel,
        onCreate: @escaping () -> Void,
        onUpdate: @escaping (TrackerSection) -> Void,
        onSelected: @escaping (TrackerSection) -> Void,
        onClose: @escaping () -> Void
    ) -> some View {
        SectionsListView(
            viewModel: viewModel,
            onCreate: onCreate,
            onUpdate: onUpdate,
            onSelected: onSelected,
            onClose: onClose
        )
    }
}
