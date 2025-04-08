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
            let numberOfCompletedTrackers = try await statisticsManager.getCompletedTrackersCount()
            let bestPeriod = try await statisticsManager.getMaxDaysWithoutBreakCount()
            
            statisticData = [
                .bestPeriod(.init(count: bestPeriod, title: R.string.localizable.statisticBestPeriod())),
                .idealDays(.init(count: 0, title: R.string.localizable.statisticIdealDays())),
                .completedTrackers(.init(count: numberOfCompletedTrackers, title: R.string.localizable.statisticCompleted())),
                .averageValue(.init(count: 0, title: R.string.localizable.statisticAvarageValue()))
            ]
        }
        catch {
            debugPrint(error)
        }
    }
}
