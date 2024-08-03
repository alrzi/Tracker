//
//  ReactiveFlowCoordinator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 10.07.2024.
//

import Foundation
import Combine

public protocol ReactiveFlowCoordinator<Output, Failure> {
    associatedtype Output
    associatedtype Failure: Error
    
    func makeFlow() -> AnyPublisher<Output, Failure>
}
