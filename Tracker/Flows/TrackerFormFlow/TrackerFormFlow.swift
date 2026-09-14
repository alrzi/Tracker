import Foundation
import Observation
import SwiftUI
import TrackerDomain

@MainActor
@Observable
final class TrackerFormFlow: Identifiable, FlowNavigating {
    private let modelFactory: TrackerFormFlowModelFactory

    let id = UUID()
    let navigationStore = NavigationModelStore<TrackerFormFlowRouteModel>()

    let trackerFormViewModel: TrackerFormViewModel

    init(
        mode: TrackerFormMode,
        trackerFormFactory: TrackerFormFactory,
        modelFactory: TrackerFormFlowModelFactory
    ) {
        self.modelFactory = modelFactory
        self.trackerFormViewModel = trackerFormFactory.makeViewModel(mode: mode)
    }

    func openSectionEditor(_ section: TrackerSection?) {
        push(modelFactory.makeRouteModel(for: .sectionEditor(section: section, token: UUID())))
    }

    func selectSection(_ section: TrackerSection) {
        trackerFormViewModel.selectSection(section)
        resetNavigation()
    }

    func openSections(selectedID: UUID?) {
        push(modelFactory.makeRouteModel(for: .sections(selectedID: selectedID, token: UUID())))
    }
}
