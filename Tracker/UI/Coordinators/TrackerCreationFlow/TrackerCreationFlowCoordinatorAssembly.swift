//
//  TrackerCreationFlowCoordinatorAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 03.08.2024.
//

import Foundation
import Combine
import Presentation

final class TrackerCreationFlowCoordinatorAssembly {    
    private let trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly
 
    init(
        trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly
    ) {
        self.trackerUpdatingFlowCoordinatorAssembly = trackerUpdatingFlowCoordinatorAssembly
    }
    
    func assemble(       
        presentationContext: PresentationContextProtocol
    ) -> AnyPublisher<(), Never> {
        let router = TrackerCreationFlowCoordinatorRouter(
            trackerUpdatingFlowCoordinatorAssembly: trackerUpdatingFlowCoordinatorAssembly,
            presentationContext: presentationContext
        )
        
        return TrackerCreationFlowCoordinator(
            router: router
        )
        .makeFlow()
    }
}
