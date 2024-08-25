//
//  TrackerCreationFlowCoordinatorRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 03.08.2024.
//

import Combine
import Foundation
import Presentation

final class TrackerCreationFlowCoordinatorRouter {
    private let trackerTypeSelectionAssembly: TrackerTypeSelectionAssembly
    private let trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly
                    
    private let presentationContext: PresentationContextProtocol
    
    init(
        trackerTypeSelectionAssembly: TrackerTypeSelectionAssembly,
        trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly,
        presentationContext: PresentationContextProtocol
    ) {
        self.trackerTypeSelectionAssembly = trackerTypeSelectionAssembly
        self.trackerUpdatingFlowCoordinatorAssembly = trackerUpdatingFlowCoordinatorAssembly
        self.presentationContext = presentationContext
    }
    
    func showTrackerTypeSelection() -> AnyPublisher<TrackerKind, Never> {
        NavigationModuleRouter(
            assembly: trackerTypeSelectionAssembly,
            presentationContext: presentationContext
        )
        .route(presentationConfiguration: .init(type: .replaceAll, animated: false))
    }
    
    func showTrackerCreation(kind: TrackerKind) -> AnyPublisher<(), Never> {
        trackerUpdatingFlowCoordinatorAssembly.assemble(
            mode: .create(kind),
            presentationContext: presentationContext
        )
    }
}
