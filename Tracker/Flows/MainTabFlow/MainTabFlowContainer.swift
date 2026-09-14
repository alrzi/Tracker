import SwiftUI

@MainActor
struct MainTabFlowContainer: View {
    @State private var flow: MainTabFlow
    private let trackersDependencies: TrackersFlowContainer.Dependencies

    init(dependencies: Dependencies) {
        self._flow = State(
            initialValue: MainTabFlow(
                statisticsScreenFactory: dependencies.statisticsScreenFactory
            )
        )
        self.trackersDependencies = dependencies.trackers
    }

    var body: some View {
        @Bindable var flow = flow

        TabView(selection: $flow.selectedTab) {
            TrackersFlowContainer(dependencies: trackersDependencies)
                .tabItem {
                    Label {
                        Text(String(localized: .tabBarTrackers))
                    } icon: {
                        Image("01leftTabBar")
                    }
                }
                .accessibilityIdentifier("Tab_trackers")
                .tag(TabBarSection.trackers)

            NavigationStack {
                StatisticsScreenFactory.makeView(
                    viewModel: flow.statisticsViewModel
                )
            }
            .tabItem {
                Label {
                    Text(String(localized: .tabBarStatistics))
                } icon: {
                    Image("02rightTabBar")
                }
            }
            .accessibilityIdentifier("Tab_statistics")
            .tag(TabBarSection.statistics)
        }
    }
}

extension MainTabFlowContainer {
    struct Dependencies {
        let statisticsScreenFactory: StatisticsScreenFactory
        let trackers: TrackersFlowContainer.Dependencies
    }
}
