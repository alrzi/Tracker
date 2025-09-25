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
            async let bestPeriod = statisticsManager.getMaxDaysWithoutBreakCount()
            async let idealDays = statisticsManager.getDaysCountWhenAllTrackersAreCompleted()
            async let completedTrackers = statisticsManager.getCompletedTrackersCount()
            async let averageDays = statisticsManager.getAverageCompletedTrackersPerDayCount()
            
            statisticData = [
                .bestPeriod(
                    .init(
                        count: (try? await bestPeriod) ?? .zero,
                        title: String(localized: .statisticBestPeriod),
                        subtitle: String(localized: .statisticBestPeriodExplanation)
                    )
                ),
                .idealDays(
                    .init(
                        count: (try? await idealDays) ?? .zero,
                        title: String(localized: .statisticIdealDays),
                        subtitle: String(localized: .statisticIdealDaysExplanation)
                    )
                ),
                .completedTrackers(
                    .init(
                        count: (try? await completedTrackers) ?? .zero,
                        title: String(localized: .statisticCompleted),
                        subtitle: String(localized: .statisticCompletedExplanation)
                    )
                ),
                .averageValue(
                    .init(
                        count: (try? await averageDays) ?? .zero,
                        title: String(localized: .statisticAverageValue),
                        subtitle: String(localized: .statisticAverageValueExplanation)
                    )
                )
            ]
        }
        catch {
            debugPrint(error)
        }
    }
}
