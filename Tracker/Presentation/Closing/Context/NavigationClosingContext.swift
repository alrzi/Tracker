//
//  NavigationClosingContext.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import Foundation
import Combine

/// Контекст закрытия, завершающий работу модуля, открытого в навигационном стеке
public final class NavigationClosingContext: ClosingContextProtocol {
    private let presentationContext: PresentationContextProtocol
    
    private let animated: Bool
    
    public init(
        presentationContext: PresentationContextProtocol,
        animated: Bool
    ) {
        self.presentationContext = presentationContext
        self.animated = animated
    }
    
    public func close(completion: (() -> Void)?) {
        presentationContext.navigationController?.popViewController(animated: animated)
        completion?()
    }
}
