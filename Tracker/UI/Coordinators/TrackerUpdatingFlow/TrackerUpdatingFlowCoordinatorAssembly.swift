//
//  TrackerUpdatingFlowCoordinatorAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Foundation
import Combine
import Presentation

final class TrackerUpdatingFlowCoordinatorAssembly {
    private let userInputCollector: UserInputCollector
        
    private let createTrackerAssembly: TrackerCreationAssembly
    private let chooseScheduleAssembly: WeekDaysSelectionAssembly
    private let categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly
 
    init(
        userInputCollector: UserInputCollector,
        createTrackerAssembly: TrackerCreationAssembly,
        chooseScheduleAssembly: WeekDaysSelectionAssembly,
        categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly
    ) {
        self.userInputCollector = userInputCollector
        self.createTrackerAssembly = createTrackerAssembly
        self.chooseScheduleAssembly = chooseScheduleAssembly
        self.categoryFlowCoordinatorAssembly = categoryFlowCoordinatorAssembly
    }
    
    func assemble(
        mode: CreateTrackerMode,
        presentationContext: PresentationContextProtocol
    ) -> AnyPublisher<(), Never> {
        let router = TrackerUpdatingFlowCoordinatorRouter(
            createTrackerAssembly: createTrackerAssembly,
            chooseScheduleAssembly: chooseScheduleAssembly,
            categoryFlowCoordinatorAssembly: categoryFlowCoordinatorAssembly,
            presentationContext: presentationContext
        )
        
        return TrackerUpdatingFlowCoordinator(
            userInputCollector: userInputCollector,
            router: router,
            mode: mode
        )
        .makeFlow()
    }
}
