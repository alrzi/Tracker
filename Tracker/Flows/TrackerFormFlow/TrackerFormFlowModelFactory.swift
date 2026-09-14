import TrackerDomain

@MainActor
struct TrackerFormFlowModelFactory: FlowModelFactory {
    private let sectionsListFactory: SectionsListFactory
    private let sectionCreationFactory: SectionCreationFactory

    init(
        sectionsListFactory: SectionsListFactory,
        sectionCreationFactory: SectionCreationFactory
    ) {
        self.sectionsListFactory = sectionsListFactory
        self.sectionCreationFactory = sectionCreationFactory
    }

    func makeRouteModel(for route: TrackerFormFlowRoute) -> TrackerFormFlowRouteModel {
        switch route {
        case .sections(let selectedID, _):
            let viewModel = sectionsListFactory.makeViewModel(selectedSectionID: selectedID)
            return .sections(route: route, viewModel: viewModel)

        case .sectionEditor(let section, _):
            let viewModel = sectionCreationFactory.makeViewModel(section: section)
            return .sectionEditor(route: route, viewModel: viewModel)
        }
    }
}
