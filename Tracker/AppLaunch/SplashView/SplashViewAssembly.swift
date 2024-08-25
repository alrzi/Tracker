//
//  SplashViewAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit
import Presentation

final class SplashViewAssembly: ViewControllerAssembly {
    typealias Context = UIWindow
    
    // MARK: - Assembly
    
    private let tabBarAssembly: TabBarAssembly
        
    // MARK: - Managers
    
    private let authService: AuthService
    
    init(
        tabBarAssembly: TabBarAssembly,
        authService: AuthService
    ) {
        self.tabBarAssembly = tabBarAssembly
        self.authService = authService
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let presentationContext = WindowPresentationContext(window: context)
        
        let router = SplashViewRouter(
            tabBarAssembly: tabBarAssembly,
            presentationContext: presentationContext
        )
        
        let viewModel = SplashViewModel(
            authService: authService,
            router: router
        )
        
        let viewController = SplashViewController(viewModel: viewModel)
        
        return viewController
    }
}
