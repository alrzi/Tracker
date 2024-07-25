//
//  TrackerCreationFlowCoordinatorRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine
import Foundation

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
    
    func showChooseTracker() -> AnyPublisher<TrackerKind, Never> {
        NavigationModuleRouter(
            assembly: chooseTrackerAssembly,
            presentationContext: presentationContext
        )
        .route()
    }
    
    func showCreateTracker() -> AnyPublisher<CreateTrackerViewModelImpl.Action, Never> {
        NavigationModuleRouter(
            assembly: createTrackerAssembly,
            presentationContext: presentationContext
        )
        .route()
    }
    
    func showChooseSchedule(weekDays: ChooseScheduleAssembly.WeekDays) -> AnyPublisher<Set<Int>, Never> {
        NavigationModuleRouter(
            assembly: chooseScheduleAssembly,
            presentationContext: presentationContext
        )
        .route(configuration: weekDays)
    }
    
    func showCategoryFlow() -> AnyPublisher<(), CategoriesListViewModelError> {
        categoryFlowCoordinatorAssembly
            .assemble(presentationContext: presentationContext)
    }
    
    func popToRoot() -> AnyPublisher<(), Never> {
        Future<(), Never> { [weak self] promise in
            guard let navigationController = self?.presentationContext.navigationController else {
                return
            }
            
            navigationController.popToRootViewController(animated: true)
            promise(.success(()))
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
