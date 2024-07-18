//
//  ChooseTrackerRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Combine

final class ChooseTrackerRouter {
    private let createTrackerAssembly: CreateTrackerAssembly
    
    private let presentationContext: PresentationContextProtocol
    
    init(
        createTrackerAssembly: CreateTrackerAssembly,
        presentationContext: PresentationContextProtocol
    ) {
        self.createTrackerAssembly = createTrackerAssembly
        self.presentationContext = presentationContext
    }
    
    func showCreateTracker() -> AnyPublisher<(), Never> {
        let router = NavigationModuleRouter(
            assembly: createTrackerAssembly,
            presentationContext: presentationContext
        )
        
        return router.route()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
