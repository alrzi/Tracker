//
//  TrackerCreationFlowCoordinatorAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine

final class TrackerCreationFlowCoordinatorAssembly {
    private let chooseTrackerAssembly: ChooseTrackerAssembly
    private let createTrackerAssembly: CreateTrackerAssembly
    private let chooseScheduleAssembly: ChooseScheduleAssembly
    private let categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly
 
    init(
        chooseTrackerAssembly: ChooseTrackerAssembly,
        createTrackerAssembly: CreateTrackerAssembly,
        chooseScheduleAssembly: ChooseScheduleAssembly,
        categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly
    ) {
        self.chooseTrackerAssembly = chooseTrackerAssembly
        self.createTrackerAssembly = createTrackerAssembly
        self.chooseScheduleAssembly = chooseScheduleAssembly
        self.categoryFlowCoordinatorAssembly = categoryFlowCoordinatorAssembly
    }
    
    func assemble(
        presentationContext: PresentationContextProtocol
    ) -> AnyPublisher<(), Never> {
        let router = TrackerCreationFlowCoordinatorRouter(
            chooseTrackerAssembly: chooseTrackerAssembly,
            createTrackerAssembly: createTrackerAssembly,
            chooseScheduleAssembly: chooseScheduleAssembly,
            categoryFlowCoordinatorAssembly: categoryFlowCoordinatorAssembly,
            presentationContext: presentationContext
        )
        
        return TrackerCreationFlowCoordinator(router: router)
            .makeFlow()
    }
}
