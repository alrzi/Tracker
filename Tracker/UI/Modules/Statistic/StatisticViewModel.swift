import Foundation
import Combine

final class StatisticViewModel {
    private let recordRepository: RecordRepository
    private let trackerManager: TrackerManaging
    
    @Published private(set) var isAnyTrackers = false
    private(set) var statisticData: [StatisticTableData] = []
    
    init(
        recordRepository: RecordRepository,
        trackerManager: TrackerManaging
    ) {
        self.recordRepository = recordRepository
        self.trackerManager = trackerManager
        
        let numberOfCompletedTrackers = recordRepository.numberOfCompletedTrackers
        
        statisticData = [
            .bestPeriod(.init()),
            .idealDays(.init()),
            .completedTrackers(.init(completedTrackersCount: numberOfCompletedTrackers)),
            .averageValue(.init())
        ]
    }
}
