//
//  PresentationContextProtocol.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit

public protocol PresentationContextProtocol {
    var viewController: UIViewController? { get }
    var navigationController: UINavigationController? { get }
}

public extension PresentationContextProtocol {
    var navigationController: UINavigationController? {
        viewController?.navigationController
    }
}
