//
//  ModalPresentationConfiguration.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 08.05.2023.
//

import Foundation

public struct ModalPresentationConfiguration {
    public let presentationStyle: ModalPresentationStyle
    public let transitionStyle: ModalTransitionStyle
    public let animated: Bool
    
    public init(
        presentationStyle: ModalPresentationStyle = .automatic,
        transitionStyle: ModalTransitionStyle = .coverVertical,
        animated: Bool = true
    ) {
        self.presentationStyle = presentationStyle
        self.transitionStyle = transitionStyle
        self.animated = animated
    }
}
