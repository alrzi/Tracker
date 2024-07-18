//
//  TabBarAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit

final class TabBarAssembly: ViewControllerAssembly {
    typealias Context = ()
    
    private let trackersAssembly: TrackersAssembly
    
    init(trackersAssembly: TrackersAssembly) {
        self.trackersAssembly = trackersAssembly
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let router = TabBarViewRouter(trackersAssembly: trackersAssembly)
        
        let viewModel = TabBarViewModel(router: router)
        
        let viewController = TabBarViewController(trackersAssembly: trackersAssembly, viewModel: viewModel)
        
        return viewController
    }
}
