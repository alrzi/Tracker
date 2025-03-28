//
//  TabBarAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit

final class TabBarAssembly {
    typealias Context = ()
    
    private let trackersAssembly: TrackersAssembly
    private let statisticAssembly: StatisticAssembly
    
    init(
        trackersAssembly: TrackersAssembly,
        statisticAssembly: StatisticAssembly
    ) {
        self.trackersAssembly = trackersAssembly
        self.statisticAssembly = statisticAssembly
    }
    
    func assemble(_ context: Context) -> UIViewController {
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
