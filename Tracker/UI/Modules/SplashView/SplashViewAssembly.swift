//
//  SplashViewAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit
import Presentation
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
