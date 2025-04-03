//
//  SplashViewRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Foundation
import UIKit

@MainActor
final class SplashViewRouter {
    private let tabBarAssembly: TabBarAssembly
    
    private let window: UIWindow
    
    init(
        tabBarAssembly: TabBarAssembly,
        window: UIWindow
    ) {
        self.tabBarAssembly = tabBarAssembly
        self.window = window
    }
        
    func showTabBar() {
        window.rootViewController = tabBarAssembly.assemble()
        window.makeKeyAndVisible()
    }
}
