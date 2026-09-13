//
//  StatisticsAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

final class StatisticsAssembly {
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
    func assemble() -> UIViewController {
        let viewModel = StatisticsViewModel(statisticsManager: statisticsManager)
        let insightViewModel = insightViewModelFactory.makeViewModel()
        
        let view = StatisticsView(
            viewModel: viewModel,
            insightViewModel: insightViewModel
        )
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
