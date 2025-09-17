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
        let tabBarPresentationContext = TabBarPresentationContext()
        
        let router = TabBarViewRouter(
            trackersAssembly: trackersAssembly,
            statisticAssembly: statisticAssembly,
            tabBarPresentationContext: tabBarPresentationContext
        )
        
        let viewModel = TabBarViewModel(router: router)
        let tabBarController = TabBarController(viewModel: viewModel)
        
        tabBarPresentationContext.tabBarController = tabBarController
        
        return tabBarController
    }
}

final class TabBarPresentationContext {
    weak var tabBarController: UITabBarController?
    
    var viewController: UIViewController? { tabBarController }
    
    init(tabBarController: UITabBarController? = nil) {
        self.tabBarController = tabBarController
    }
}
