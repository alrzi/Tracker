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
    private let statisticsManager: any StatisticsManaging
        
    @Published private(set) var statisticData: [StatisticTableData] = []
    
    init(
        statisticsManager: some StatisticsManaging
    ) {
        self.statisticsManager = statisticsManager
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
            async let numberOfCompletedTrackers = statisticsManager.getCompletedTrackersCount()
            async let bestPeriod = statisticsManager.getMaxDaysWithoutBreakCount()
            async let idealDays = statisticsManager.getDaysCountWhenAllTrackersAreCompleted()
            async let averageDays = statisticsManager.getAverageCompletedTrackersPerDayCount()
            
            statisticData = [
                .bestPeriod(.init(count: try await bestPeriod, title: R.string.localizable.statisticBestPeriod())),
                .idealDays(.init(count: try await idealDays, title: R.string.localizable.statisticIdealDays())),
                .completedTrackers(.init(count: try await numberOfCompletedTrackers, title: R.string.localizable.statisticCompleted())),
                .averageValue(.init(count: try await averageDays, title: R.string.localizable.statisticAvarageValue()))
            ]
        }
        catch {
            debugPrint(error)
        }
    }
}
