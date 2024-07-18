//
//  DefaultModalPresenter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit

public final class DefaultModalPresenter: ModalPresenter {
    private let viewController: UIViewController
    private let presentationStyle: ModalPresentationStyle
    private let transitionStyle: ModalTransitionStyle
    
    public init(
        viewController: UIViewController,
        presentationStyle: ModalPresentationStyle,
        transitionStyle: ModalTransitionStyle
    ) {
        self.viewController = viewController
        self.presentationStyle = presentationStyle
        self.transitionStyle = transitionStyle
    }
    
    public func present(at: UIViewController, animated: Bool, completion: (() -> Void)?) {
        viewController.modalTransitionStyle = transitionStyle.toUI()
        viewController.modalPresentationStyle = presentationStyle.toUI()
        
        at.present(viewController, animated: animated, completion: completion)
    }
}

private extension ModalPresentationStyle {
    func toUI() -> UIModalPresentationStyle {
        switch self {
        case .fullScreen: return .fullScreen
        case .pageSheet: return .pageSheet
        case .formSheet: return .formSheet
        case .currentContext: return .currentContext
        case .custom: return .custom
        case .overFullScreen: return .overFullScreen
        case .overCurrentContext: return .overCurrentContext
        case .popover: return .popover
        case .none: return .none
        case .automatic: return .automatic
        case .sizeClassDependent: return .custom
        }
    }
}

private extension ModalTransitionStyle {
    func toUI() -> UIModalTransitionStyle {
        switch self {
        case .coverVertical: return .coverVertical
        case .flipHorizontal: return .flipHorizontal
        case .crossDissolve: return .crossDissolve
        case .partialCurl: return .partialCurl
        }
    }
}
