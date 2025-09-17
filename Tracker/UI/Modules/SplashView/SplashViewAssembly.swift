//
//  SplashViewAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit
import TrackerDomain

final class SplashViewAssembly {
    typealias Context = UIWindow
    
    // MARK: - Assembly
    
    private let tabBarAssembly: TabBarAssembly
        
    // MARK: - Managers
    
    private let authService: AuthServiceProtocol
    
    init(
        tabBarAssembly: TabBarAssembly,
        authService: AuthServiceProtocol
    ) {
        self.tabBarAssembly = tabBarAssembly
        self.authService = authService
    }
        
    @MainActor
    func assemble(_ context: Context) -> UIViewController {
        let router = SplashViewRouter(
            tabBarAssembly: tabBarAssembly,
            window: context
        )
        
        let viewModel = SplashViewModel(
            authService: authService,
            router: router
        )
        
        let viewController = SplashViewController(viewModel: viewModel)
        
        return viewController
    }
}
