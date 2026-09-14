import Observation
import SwiftUI
import TrackerDomain

@MainActor
@Observable
final class TrackersFlow {
    let trackersViewModel: TrackersViewModel
    var formPresentation: TrackerFormPresentation?

    init(trackersScreenFactory: TrackersScreenFactory) {
        self.trackersViewModel = trackersScreenFactory.makeViewModel()
    }

    func presentForm(_ mode: TrackerFormMode) {
        formPresentation = TrackerFormPresentation(mode: mode)
    }

    func dismissForm() {
        formPresentation = nil
    }
}

struct TrackerFormPresentation: Identifiable {
    let id = UUID()
    let mode: TrackerFormMode
}
