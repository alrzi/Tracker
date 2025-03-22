//
//  TrackerCreationFlowCoordinatorRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 03.08.2024.
//

import Combine
import Foundation
import Presentation
import TrackerDomain

final class TrackerCreationFlowCoordinatorRouter {
    private let trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly
                    
    private let presentationContext: PresentationContextProtocol
    
    init(
        trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly,
        presentationContext: PresentationContextProtocol
    ) {
        self.trackerUpdatingFlowCoordinatorAssembly = trackerUpdatingFlowCoordinatorAssembly
        self.presentationContext = presentationContext
    }
    
    func showTrackerCreation(kind: Tracker.Kind) -> AnyPublisher<(), Never> {
        trackerUpdatingFlowCoordinatorAssembly.assemble(
            mode: .create(kind),
            presentationContext: presentationContext
        )
    }
}
