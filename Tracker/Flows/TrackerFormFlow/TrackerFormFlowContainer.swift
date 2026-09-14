import SwiftUI
import TrackerDomain

@MainActor
struct TrackerFormFlowContainer: View {
    @State private var flow: TrackerFormFlow
    let onCompleted: (TrackerFormOutput) -> Void
    let onClose: () -> Void

    init(
        mode: TrackerFormMode,
        dependencies: Dependencies,
        onCompleted: @escaping (TrackerFormOutput) -> Void,
        onClose: @escaping () -> Void
    ) {
        self._flow = State(
            initialValue: TrackerFormFlow(
                mode: mode,
                trackerFormFactory: dependencies.trackerFormFactory,
                modelFactory: dependencies.modelFactory
            )
        )
        self.onCompleted = onCompleted
        self.onClose = onClose
    }

    var body: some View {
        @Bindable var flow = flow

        NavigationStack(path: $flow.navigationPath) {
            TrackerFormFactory.makeView(
                viewModel: flow.trackerFormViewModel,
                onSectionSelection: flow.openSections,
                onCompleted: onCompleted,
                onClose: onClose
            )
            .navigationDestination(for: TrackerFormFlowRoute.self) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: TrackerFormFlowRoute) -> some View {
        switch flow.model(for: route) {
        case .sections(_, let viewModel):
            SectionsListFactory.makeView(
                viewModel: viewModel,
                onCreate: { flow.openSectionEditor(nil) },
                onUpdate: flow.openSectionEditor,
                onSelected: flow.selectSection,
                onClose: flow.resetNavigation
            )

        case .sectionEditor(_, let viewModel):
            SectionCreationFactory.makeView(
                viewModel: viewModel,
                onCompleted: { _ in flow.popLastRoute() },
                onClose: flow.popLastRoute
            )

        case nil:
            EmptyView()
        }
    }

}

extension TrackerFormFlowContainer {
    struct Dependencies {
        let trackerFormFactory: TrackerFormFactory
        let modelFactory: TrackerFormFlowModelFactory
    }
}
