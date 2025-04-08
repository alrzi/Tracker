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
    
    init(statisticsManager: some StatisticsManaging) {
        self.statisticsManager = statisticsManager
    }
    
    @MainActor
    func assemble() -> UIViewController {
        let viewModel = StatisticsViewModel(statisticsManager: statisticsManager)
        
        let view = StatisticsView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        
        return viewController
    }
}
