//
//  LifecycleManagingContext.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 10.05.2023.
//

import Foundation
import Combine

public struct LifecycleManagingContext<Output, Failure: Error, Configuration>: LifecycleManagingContextProtocol {
    public let resultObserver: PassthroughSubject<Output, Failure>
    public let closingContext: ClosingContextProtocol

    public let configuration: Configuration
    
    public init(
        resultObserver: PassthroughSubject<Output, Failure>,
        closingContext: ClosingContextProtocol,
        configuration: Configuration
    ) {
        self.resultObserver = resultObserver
        self.closingContext = closingContext
        self.configuration = configuration
    }
}
