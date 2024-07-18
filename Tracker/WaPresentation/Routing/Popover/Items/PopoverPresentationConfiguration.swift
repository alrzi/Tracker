//
//  PopoverPresentationConfiguration.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 18.05.2023.
//

import UIKit

public struct PopoverPresentationConfiguration {
    public let source: Source
    public let arrowDirections: UIPopoverArrowDirection
    public let passthroughViews: [UIView]?
    public let backgroundColor: UIColor?
    public let animated: Bool
    
    public init(
        source: Source,
        arrowDirections: UIPopoverArrowDirection = .up,
        passthroughViews: [UIView]? = nil,
        backgroundColor: UIColor? = nil,
        animated: Bool = true
    ) {
        self.source = source
        self.arrowDirections = arrowDirections
        self.passthroughViews = passthroughViews
        self.backgroundColor = backgroundColor
        self.animated = animated
    }
    
    public enum Source {
        case barButton(UIBarButtonItem)
        case source(Source)
        
        public struct Source {
            public let view: UIView
            public let rect: CGRect
            
            public init(view: UIView, rect: CGRect) {
                self.view = view
                self.rect = rect
            }
            
            public init(view: UIView) {
                self.view = view
                rect = view.frame
            }
        }
    }
}
