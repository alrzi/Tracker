//
//  NavigationPresentationConfiguration.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 08.05.2023.
//

import Foundation

public struct NavigationPresentationConfiguration {
    public let type: NavigationPresentationType
    public let animated: Bool
    
    public init(
        type: NavigationPresentationType = .push,
        animated: Bool = true
    ) {
        self.type = type
        self.animated = animated
    }
}
