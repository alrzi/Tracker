import Foundation
import Combine
import TrackerDomain

@MainActor
final class StatisticViewModel {
    private let recordRepository: RecordRepositoryProtocol
    private let trackerManager: any TrackerManaging
    
    @Published private(set) var isAnyTrackers = false
    private(set) var statisticData: [StatisticTableData] = []
    
    init(
        recordRepository: RecordRepositoryProtocol,
        trackerManager: some TrackerManaging
    ) {
        self.recordRepository = recordRepository
        self.trackerManager = trackerManager
        
        Task {
            let numberOfCompletedTrackers = try await recordRepository.numberOfCompletedTrackers
            
            statisticData = [
                .bestPeriod(.init()),
                .idealDays(.init()),
                .completedTrackers(.init(completedTrackersCount: numberOfCompletedTrackers)),
                .averageValue(.init())
            ]
        }
    }
}
