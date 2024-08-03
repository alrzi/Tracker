//
//  TransitionNavigationControllerPresenter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit

/*
 Презентер для отображения контроллеров на UINavigationController с кастомной анимацией
 */

public protocol TrainsitionAnimationControllerProviderProtocol {
    func animationController(
        for operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning
}

public final class TransitionNavigationControllerPresenter: NavigationPresenter {
    private let viewController: UIViewController
    private let delegateWrapper: NavigationControllerDelegateWrapper
    
    /// - Parameters:
    ///  - animationControllerProvider: провайдер для контроллера анимации перехода
    ///  - viewController: контроллер, на который будет совершен переход
    public init(
        animationControllerProvider: TrainsitionAnimationControllerProviderProtocol,
        viewController: UIViewController
    ) {
        self.viewController = viewController
        
        delegateWrapper = NavigationControllerDelegateWrapper(
            animationControllerProvider: animationControllerProvider
        )
    }
    
    public func push(in navigationController: UINavigationController, animated: Bool) {
        delegateWrapper.delegate = navigationController.delegate
        navigationController.delegate = delegateWrapper
        
        navigationController.pushViewController(viewController, animated: true)
        
        navigationController.delegate = delegateWrapper.delegate
    }
    
    public func replaceCurrent(in navigationController: UINavigationController, animated: Bool) {
        delegateWrapper.delegate = navigationController.delegate
        navigationController.delegate = delegateWrapper
        
        var viewControllers = navigationController.viewControllers
        viewControllers.removeLast()
        viewControllers.append(viewController)
        
        navigationController.setViewControllers(viewControllers, animated: true)
        
        navigationController.delegate = delegateWrapper.delegate
    }
    
    public func replaceAll(in navigationController: UINavigationController, animated: Bool) {
        delegateWrapper.delegate = navigationController.delegate
        navigationController.delegate = delegateWrapper
        
        navigationController.setViewControllers([viewController], animated: true)
        
        navigationController.delegate = delegateWrapper.delegate
    }
}

private extension TransitionNavigationControllerPresenter {
    class NavigationControllerDelegateWrapper: NSObject, UINavigationControllerDelegate {
        private let animationControllerProvider: TrainsitionAnimationControllerProviderProtocol
        
        var delegate: UINavigationControllerDelegate?
        
        init(animationControllerProvider: TrainsitionAnimationControllerProviderProtocol) {
            self.animationControllerProvider = animationControllerProvider
        }
        
        func navigationController(
            _ navigationController: UINavigationController,
            willShow viewController: UIViewController,
            animated: Bool
        ) {
            delegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
        }

        func navigationController(
            _ navigationController: UINavigationController,
            didShow viewController: UIViewController,
            animated: Bool
        ) {
            delegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
        }
        
        func navigationController(
            _ navigationController: UINavigationController,
            interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
        ) -> UIViewControllerInteractiveTransitioning? {
            delegate?.navigationController?(navigationController, interactionControllerFor: animationController)
        }
        
        func navigationController(
            _ navigationController: UINavigationController,
            animationControllerFor operation: UINavigationController.Operation,
            from fromVC: UIViewController,
            to toVC: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            animationControllerProvider.animationController(
                for: operation,
                from: fromVC,
                to: toVC
            )
        }
    }
}
