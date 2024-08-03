//
//  ModuleAssembly.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 07.05.2023.
//

import Foundation
import Combine

public protocol ModuleAssembly {
    associatedtype Context
    
    associatedtype Output
    associatedtype Failure: Error
    
    func assemble(_ context: Context) -> PassthroughSubject<Output, Failure>
}
