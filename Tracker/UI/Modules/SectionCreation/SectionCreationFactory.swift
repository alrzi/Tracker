import SwiftUI
import TrackerDomain

struct SectionCreationFactory {
    private let sectionRepository: any SectionRepositoryProtocol

    init(sectionRepository: some SectionRepositoryProtocol) {
        self.sectionRepository = sectionRepository
    }

    @MainActor
    func makeViewModel(section: TrackerSection?) -> SectionCreationViewModel {
        SectionCreationViewModel(
            sectionRepository: sectionRepository,
            section: section
        )
    }

    @MainActor
    static func makeView(
        viewModel: SectionCreationViewModel,
        onCompleted: @escaping (TrackerSection) -> Void,
        onClose: @escaping () -> Void
    ) -> some View {
        SectionCreationView(
            viewModel: viewModel,
            onCompleted: onCompleted,
            onClose: onClose
        )
    }
}
