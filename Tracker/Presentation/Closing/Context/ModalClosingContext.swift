//
//  ModalClosingContext.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import Foundation
import Combine

/// Контекст закрытия, завершающий работу модуля, открытого модально
public final class ModalClosingContext: ClosingContextProtocol {
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
        presentationContext.viewController?.dismiss(
            animated: animated,
            completion: completion
        )
    }
}
