//
//  SplashViewRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Foundation
import Presentation

final class SplashViewRouter {
    private let tabBarAssembly: TabBarAssembly
    
    private let presentationContext: WindowPresentationContext
    
    init(
        tabBarAssembly: TabBarAssembly,
        presentationContext: WindowPresentationContext
    ) {
        self.tabBarAssembly = tabBarAssembly
        self.presentationContext = presentationContext
    }
    
    func showTabBar() {
        guard let window = presentationContext.window else {
            assertionFailure()
            return
        }
        
        let presenter = DefaultWindowPresenter(tabBarAssembly.assemble(()))
        
        presenter.present(at: window)
    }
}
