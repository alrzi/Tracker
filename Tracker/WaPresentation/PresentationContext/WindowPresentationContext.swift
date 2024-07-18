//
//  WindowPresentationContext.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit

public protocol WindowPresentationContextProtocol: PresentationContextProtocol {
    var window: UIWindow? { get }
}

public class WindowPresentationContext: WindowPresentationContextProtocol {
    public weak var window: UIWindow?
    
    public var viewController: UIViewController? {
        return window?.rootViewController
    }
    
    public init(window: UIWindow? = nil) {
        self.window = window
    }
}
