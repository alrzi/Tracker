//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2025.
//

import Foundation
import TrackerDomain

@MainActor
protocol StatisticsViewModelProtocol: ObservableObject {
    var statisticData: [StatisticTableData] { get }
    
    func onAppear()
}

final class StatisticsViewModel: StatisticsViewModelProtocol {
    private let recordRepository: RecordRepositoryProtocol
    private let trackerManager: any TrackerManaging
        
    @Published private(set) var statisticData: [StatisticTableData] = []
    
    init(
        recordRepository: RecordRepositoryProtocol,
        trackerManager: some TrackerManaging
    ) {
        self.recordRepository = recordRepository
        self.trackerManager = trackerManager
    }
    
    func onAppear() {
        Task {
            await updateStatisticData()
        }
    }
}

// MARK: - Private

private extension StatisticsViewModel {
    func updateStatisticData() async {
        do {
            let numberOfCompletedTrackers = try await recordRepository.numberOfCompletedTrackers
            
            statisticData = [
                .bestPeriod(.init()),
                .idealDays(.init()),
                .completedTrackers(.init(completedTrackersCount: numberOfCompletedTrackers)),
                .averageValue(.init())
            ]
        }
        catch {
            debugPrint(error)
        }
    }
}
