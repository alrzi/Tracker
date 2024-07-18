import Combine

final class StatisticViewModel {
    // MARK: - Public
    @Published var isAnyTrackers = false
    var statisticData: [StatisticTableData] = []

    func viewWillAppear() {
        let isAnyTrackers = trackerStore.isAnyTrackers

        if isAnyTrackers {
            handleTrackersExistence()
        } else {
            handleNoTrackersExistence()
        }
    }

    // MARK: - Private
    private let trackerRecordStore: TrackerRecordStoreProtocol
    private let trackerStore: TrackerStoreDataProviderProtocol

    // MARK: - Init
    init(
        trackerRecordStore: TrackerRecordStoreProtocol,
        trackerStore: TrackerStoreDataProviderProtocol
    ) {
        self.trackerRecordStore = trackerRecordStore
        self.trackerStore = trackerStore
    }

    private func handleTrackersExistence() {
        let completedTrackersCount = trackerRecordStore.getNumberOfCompletedTrackers()

        if statisticData.isEmpty {
            setInitialStatisticData(completedTrackersCount: completedTrackersCount)
            self.isAnyTrackers = true
        } else {
            updateCompletedTrackersCell(value: completedTrackersCount)
        }
    }

    private func handleNoTrackersExistence() {
        resetStatisticData()
        self.isAnyTrackers = false
    }


    private func setInitialStatisticData(completedTrackersCount: Int) {
        // Set up initial statistic data for each cell
        statisticData = [
            .bestPeriod(StatisticCellViewModel()),
            .idealDays(StatisticCellViewModel()),
            .completedTrackers(StatisticCellViewModel(value: "\(completedTrackersCount)")),
            .averageValue(StatisticCellViewModel())
        ]
    }

    private func updateCompletedTrackersCell(value: Int) {
        // Find the completed trackers cell and update its value
        statisticData.forEach { data in
            switch data {
            case .completedTrackers(let viewModel):
                viewModel.value = "\(value)"
            default: break
            }
        }
    }

    private func resetStatisticData() {
        // Reset the statistic data when there are no trackers
        statisticData = []
    }
}

final class StatisticCellViewModel {
    @Published var value: String

    init(value: String = "-") {
        self.value = value
    }
}

enum StatisticTableData {
    case bestPeriod(StatisticCellViewModel)
    case idealDays(StatisticCellViewModel)
    case completedTrackers(StatisticCellViewModel)
    case averageValue(StatisticCellViewModel)

    var title: String {
        switch self {
        case .bestPeriod: Strings.Localizable.Statistic.bestPeriod
        case .idealDays: Strings.Localizable.Statistic.idealDays
        case .completedTrackers: Strings.Localizable.Statistic.completed
        case .averageValue: Strings.Localizable.Statistic.avarageValue
        }
    }
    
    var viewModel: StatisticCellViewModel {
        switch self {
        case .bestPeriod(let viewModel): viewModel
        case .idealDays(let viewModel): viewModel
        case .completedTrackers(let viewModel): viewModel
        case .averageValue(let viewModel): viewModel
        }
    }
}
