//
//  TrackersViewRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Combine
import UIKit
import Presentation

final class TrackersViewRouter {
    private let trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly
    private let trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly
    private let filtersAssembly: FiltersAssembly
    
    private let presentationContext: PresentationContextProtocol
    
    init(
        trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly,
        trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly,
        filtersAssembly: FiltersAssembly,
        presentationContext: PresentationContextProtocol
    ) {
        self.trackerCreationFlowCoordinatorAssembly = trackerCreationFlowCoordinatorAssembly
        self.trackerUpdatingFlowCoordinatorAssembly = trackerUpdatingFlowCoordinatorAssembly
        self.filtersAssembly = filtersAssembly
        self.presentationContext = presentationContext
    }
    
    func showTrackerUpdatingFlow() -> AnyPublisher<(), Never> {
        ToNavigationFlowRouter
            .modal(
                presentationContext: ModalPresentationContext(viewController: presentationContext.viewController),
                presentationStyle: .overFullScreen,
                transitionStyle: .coverVertical,
                flowFactory: { [trackerCreationFlowCoordinatorAssembly] in
                    trackerCreationFlowCoordinatorAssembly.assemble(presentationContext: $0)
                }
            )
            .route()
    }
    
    func showTrackerUpdatingFlow(tracker: Tracker, date: Date) -> AnyPublisher<(), Never> {
        ToNavigationFlowRouter
            .modal(
                presentationContext: ModalPresentationContext(viewController: presentationContext.viewController),
                presentationStyle: .overFullScreen,
                transitionStyle: .coverVertical,
                flowFactory: { [trackerUpdatingFlowCoordinatorAssembly] in
                    trackerUpdatingFlowCoordinatorAssembly.assemble(
                        mode: .update(tracker, date),
                        presentationContext: $0
                    )
                }
            )
            .route()
    }
    
    func showFiltersAssembly(filter: TrackerFilters) -> AnyPublisher<TrackerFilters, Never> {
        ModalModuleRouter(
            assembly: filtersAssembly,
            presentationContext: presentationContext
        )
        .route(configuration: filter)
        .eraseToAnyPublisher()
    }
}
