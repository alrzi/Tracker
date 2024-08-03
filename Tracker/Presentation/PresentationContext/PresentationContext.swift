//
//  PresentationContext.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit

public class ModalPresentationContext: PresentationContextProtocol {
    public weak var viewController: UIViewController?
    
    public init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
}

public class NavigationPresentationContext: PresentationContextProtocol {
    public weak var navigationController: UINavigationController?
    
    public var viewController: UIViewController? {
        navigationController
    }
    
    public init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
}
