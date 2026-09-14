import SwiftUI
import TrackerDomain

@MainActor
struct AppFlowContainer: View {
    @State private var flow: AppFlow
    private let mainTabDependencies: MainTabFlowContainer.Dependencies

    init(dependencies: Dependencies) {
        self._flow = State(
            initialValue: AppFlow(authService: dependencies.authService)
        )
        self.mainTabDependencies = dependencies.mainTab
    }

    var body: some View {
        switch flow.state {
        case .launching:
            LaunchScreenFactory.makeView(onAppear: flow.start)

        case .main:
            MainTabFlowContainer(dependencies: mainTabDependencies)
        }
    }
}

extension AppFlowContainer {
    struct Dependencies {
        let authService: any AuthServiceProtocol
        let mainTab: MainTabFlowContainer.Dependencies
    }
}
