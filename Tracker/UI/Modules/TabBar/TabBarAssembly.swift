//
//  TabBarAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit

final class TabBarAssembly {
    private let trackersAssembly: TrackersAssembly
    private let statisticAssembly: StatisticsAssembly
    
    init(
        trackersAssembly: TrackersAssembly,
        statisticAssembly: StatisticsAssembly
    ) {
        self.trackersAssembly = trackersAssembly
        self.statisticAssembly = statisticAssembly
    }
    
    @MainActor
    func assemble() -> UIViewController {
        let router = TabBarViewRouter(trackersAssembly: trackersAssembly)
        
        let viewModel = TabBarViewModel(router: router)
        
        let viewController = TabBarViewController(
            trackersAssembly: trackersAssembly,
            statisticAssembly: statisticAssembly,
            viewModel: viewModel
        )
        
        return viewController
    }
}
