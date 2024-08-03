//
//  DefaultNavigationPresenter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit

public final class DefaultNavigationPresenter: NavigationPresenter {
    private let viewController: UIViewController
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public func push(in navigationController: UINavigationController, animated: Bool) {
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    public func replaceCurrent(in navigationController: UINavigationController, animated: Bool) {
        var viewControllers = navigationController.viewControllers
        viewControllers.removeLast()
        viewControllers.append(viewController)
        
        navigationController.setViewControllers(viewControllers, animated: animated)
    }
    
    public func replaceAll(in navigationController: UINavigationController, animated: Bool) {
        navigationController.setViewControllers([viewController], animated: animated)
    }
}
