import SwiftUI
import TrackerDomain

struct StatisticsScreenFactory {
    private let statisticsManager: any StatisticsManaging
    private let insightViewModelFactory: StatisticsInsightViewModelFactory

    init(
        statisticsManager: some StatisticsManaging,
        insightViewModelFactory: StatisticsInsightViewModelFactory
    ) {
        self.statisticsManager = statisticsManager
        self.insightViewModelFactory = insightViewModelFactory
    }

    @MainActor
    func makeViewModel() -> StatisticsViewModel {
        StatisticsViewModel(
            statisticsManager: statisticsManager,
            insightViewModel: insightViewModelFactory.makeViewModel()
        )
    }

    @MainActor
    static func makeView(
        viewModel: StatisticsViewModel
    ) -> some View {
        StatisticsView(viewModel: viewModel)
    }
}
