//
//  CreateTrackerViewRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine

final class CreateTrackerViewRouter {
    private let categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly
    private let chooseScheduleAssembly: ChooseScheduleAssembly
    
    private let presentationContext: PresentationContextProtocol
    
    init(
        categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly,
        chooseScheduleAssembly: ChooseScheduleAssembly,
        presentationContext: PresentationContextProtocol
    ) {
        self.categoryFlowCoordinatorAssembly = categoryFlowCoordinatorAssembly
        self.chooseScheduleAssembly = chooseScheduleAssembly
        self.presentationContext = presentationContext
    }
    
    func showCategoryFlow() -> AnyPublisher<(), Never> {
        categoryFlowCoordinatorAssembly
            .assemble(presentationContext: presentationContext)
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
    
    func showChooseSchedule() -> AnyPublisher<Set<Int>, Never> {
        let router = NavigationModuleRouter(
            assembly: chooseScheduleAssembly,
            presentationContext: presentationContext
        )
        
        return router.route(configuration: .init())
    }
}
