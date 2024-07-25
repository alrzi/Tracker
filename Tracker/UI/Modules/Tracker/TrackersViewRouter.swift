//
//  TrackersViewRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Combine
import UIKit

final class TrackersViewRouter {
    private let trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly
    private let createTrackerAssembly: CreateTrackerAssembly
    private let filtersAssembly: FiltersAssembly
    
    private let presentationContext: PresentationContextProtocol
    
    init(
        trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly,
        createTrackerAssembly: CreateTrackerAssembly,
        filtersAssembly: FiltersAssembly,
        presentationContext: PresentationContextProtocol
    ) {
        self.trackerCreationFlowCoordinatorAssembly = trackerCreationFlowCoordinatorAssembly
        self.createTrackerAssembly = createTrackerAssembly
        self.filtersAssembly = filtersAssembly
        self.presentationContext = presentationContext
    }
    
    func showCreateTracker() -> AnyPublisher<(), Never> {
        ModalModuleRouter(
            assembly: createTrackerAssembly,
            presentationContext: presentationContext
        )
        .route()
        .map { _ in () }
        .eraseToAnyPublisher()
    }
    
    func showTrackerCreationFlow() -> AnyPublisher<(), Never> {
        trackerCreationFlowCoordinatorAssembly.assemble(presentationContext: presentationContext)
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
