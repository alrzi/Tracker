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
    private let trackerTypeSelectionAssembly: TrackerTypeSelectionAssembly
    private let trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly
 
    init(
        trackerTypeSelectionAssembly: TrackerTypeSelectionAssembly,
        trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly
    ) {
        self.trackerTypeSelectionAssembly = trackerTypeSelectionAssembly
        self.trackerUpdatingFlowCoordinatorAssembly = trackerUpdatingFlowCoordinatorAssembly
    }
    
    func assemble(       
        presentationContext: PresentationContextProtocol
    ) -> AnyPublisher<(), Never> {
        let router = TrackerCreationFlowCoordinatorRouter(
            trackerTypeSelectionAssembly: trackerTypeSelectionAssembly,
            trackerUpdatingFlowCoordinatorAssembly: trackerUpdatingFlowCoordinatorAssembly,
            presentationContext: presentationContext
        )
        
        return TrackerCreationFlowCoordinator(
            router: router
        )
        .makeFlow()
    }
}
