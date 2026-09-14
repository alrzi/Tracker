import Observation

@MainActor
@Observable
final class MainTabFlow {
    var selectedTab: TabBarSection = .trackers

    let statisticsViewModel: StatisticsViewModel

    init(statisticsScreenFactory: StatisticsScreenFactory) {
        self.statisticsViewModel = statisticsScreenFactory.makeViewModel()
    }
}
