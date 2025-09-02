//
//  SplashViewRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Foundation
import UIKit

@MainActor
struct SplashViewRouter {
    let tabBarAssembly: TabBarAssembly
    let window: UIWindow
        
    func showTabBar() {
        window.rootViewController = tabBarAssembly.assemble()
        window.makeKeyAndVisible()
    }
}
