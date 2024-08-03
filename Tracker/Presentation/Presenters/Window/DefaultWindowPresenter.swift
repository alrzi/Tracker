//
//  DefaultWindowPresenter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit

public final class DefaultWindowPresenter: WindowPresenter {
    private var viewController: UIViewController?
    
    public init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public func present(at window: UIWindow) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
