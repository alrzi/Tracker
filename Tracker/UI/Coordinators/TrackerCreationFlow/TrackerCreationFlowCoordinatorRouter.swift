//
//  TrackerCreationFlowCoordinatorRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine

final class TrackerCreationFlowCoordinatorRouter {
    private let chooseTrackerAssembly: ChooseTrackerAssembly
    private let createTrackerAssembly: CreateTrackerAssembly
    private let chooseScheduleAssembly: ChooseScheduleAssembly
    private let categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly
                    
    private let presentationContext: PresentationContextProtocol
    
    init(
        chooseTrackerAssembly: ChooseTrackerAssembly,
        createTrackerAssembly: CreateTrackerAssembly,
        chooseScheduleAssembly: ChooseScheduleAssembly,
        categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly,
        presentationContext: PresentationContextProtocol
    ) {
        self.chooseTrackerAssembly = chooseTrackerAssembly
        self.createTrackerAssembly = createTrackerAssembly
        self.chooseScheduleAssembly = chooseScheduleAssembly
        self.categoryFlowCoordinatorAssembly = categoryFlowCoordinatorAssembly
        self.presentationContext = presentationContext
    }
    
    func showChooseTracker() -> AnyPublisher<ChooseTrackerViewModel.Destination, Never> {
        NavigationModuleRouter(
            assembly: chooseTrackerAssembly,
            presentationContext: presentationContext
        )
        .route()
    }
    
    func showCreateTracker() -> AnyPublisher<CreateTrackerViewModelImpl.Destination, Never> {
        NavigationModuleRouter(
            assembly: createTrackerAssembly,
            presentationContext: presentationContext
        )
        .route()
    }
    
    func showChooseSchedule() -> AnyPublisher<(), Never> {
        NavigationModuleRouter(
            assembly: chooseScheduleAssembly,
            presentationContext: presentationContext
        )
        .route()
    }
    
    func showCategoryFlow() -> AnyPublisher<(), Never> {
        categoryFlowCoordinatorAssembly
            .assemble(presentationContext: presentationContext)
    }
}
