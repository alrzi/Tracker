//
//  ToModuleRouting.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 08.06.2023.
//

import Foundation
import Combine

public protocol ToModuleRouting {
    associatedtype Configuration
    associatedtype PresentationConfiguration
    associatedtype Output
    associatedtype Failure: Error
    
    func route(
        configuration: Configuration,
        presentationConfiguration: PresentationConfiguration,
        shouldCompleteWithFirstValue: Bool
    ) -> AnyPublisher<Output, Failure>
}

public extension ToModuleRouting where Configuration == () {
    func route(
        presentationConfiguration: PresentationConfiguration,
        shouldCompleteWithFirstValue: Bool
    ) -> AnyPublisher<Output, Failure> {
        route(
            configuration: (),
            presentationConfiguration: presentationConfiguration,
            shouldCompleteWithFirstValue: shouldCompleteWithFirstValue
        )
    }
}

public extension ToModuleRouting where PresentationConfiguration == () {
    func route(
        configuration: Configuration,
        shouldCompleteWithFirstValue: Bool
    ) -> AnyPublisher<Output, Failure> {
        return route(
            configuration: configuration,
            presentationConfiguration: (),
            shouldCompleteWithFirstValue: shouldCompleteWithFirstValue
        )
    }
}

public extension ToModuleRouting where Configuration == (), PresentationConfiguration == () {
    func route(
        configuration: Configuration,
        shouldCompleteWithFirstValue: Bool
    ) -> AnyPublisher<Output, Failure> {
        return route(
            configuration: (),
            presentationConfiguration: (),
            shouldCompleteWithFirstValue: shouldCompleteWithFirstValue
        )
    }
}
