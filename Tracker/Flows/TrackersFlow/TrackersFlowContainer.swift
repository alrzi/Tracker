import SwiftUI

@MainActor
struct TrackersFlowContainer: View {
    @State private var flow: TrackersFlow
    private let trackerFormDependencies: TrackerFormFlowContainer.Dependencies

    init(dependencies: Dependencies) {
        self._flow = State(
            initialValue: TrackersFlow(
                trackersScreenFactory: dependencies.trackersScreenFactory
            )
        )
        self.trackerFormDependencies = dependencies.trackerForm
    }

    var body: some View {
        @Bindable var flow = flow

        NavigationStack {
            TrackersScreenFactory.makeView(
                viewModel: flow.trackersViewModel,
                onCreate: { flow.presentForm(.createTracker) },
                onEdit: { flow.presentForm(.editTracker($0)) }
            )
        }
        .sheet(item: $flow.formPresentation) { presentation in
            TrackerFormFlowContainer(
                mode: presentation.mode,
                dependencies: trackerFormDependencies,
                onCompleted: { _ in flow.dismissForm() },
                onClose: flow.dismissForm
            )
        }
    }
}

extension TrackersFlowContainer {
    struct Dependencies {
        let trackersScreenFactory: TrackersScreenFactory
        let trackerForm: TrackerFormFlowContainer.Dependencies
    }
}
