//
//  TrackerUpdatingFlowCoordinatorRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine
import Foundation

final class TrackerUpdatingFlowCoordinatorRouter {
    private let createTrackerAssembly: TrackerCreationAssembly
    private let chooseScheduleAssembly: WeekDaysSelectionAssembly
    private let categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly
                    
    private let presentationContext: PresentationContextProtocol
    
    init(
        createTrackerAssembly: TrackerCreationAssembly,
        chooseScheduleAssembly: WeekDaysSelectionAssembly,
        categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly,
        presentationContext: PresentationContextProtocol
    ) {
        self.createTrackerAssembly = createTrackerAssembly
        self.chooseScheduleAssembly = chooseScheduleAssembly
        self.categoryFlowCoordinatorAssembly = categoryFlowCoordinatorAssembly
        self.presentationContext = presentationContext
    }
    
    func showTrackerCreator(mode: CreateTrackerMode) -> AnyPublisher<TrackerCreationViewModel.Action, Never> {
        NavigationModuleRouter(
            assembly: createTrackerAssembly,
            presentationContext: presentationContext
        )
        .route(configuration: mode, presentationConfiguration: mode.presentationConfiguration)
    }
    
    func showChooseSchedule(weekDays: WeekDaysSelectionAssembly.WeekDays) -> AnyPublisher<Set<Int>, Never> {
        NavigationModuleRouter(
            assembly: chooseScheduleAssembly,
            presentationContext: presentationContext
        )
        .route(configuration: weekDays)
    }
    
    func showCategoryFlow() -> AnyPublisher<(), CategoriesListViewModelError> {
        categoryFlowCoordinatorAssembly.assemble(presentationContext: presentationContext)
    }
}

private extension CreateTrackerMode {
    var presentationConfiguration: NavigationPresentationConfiguration {
        switch self {
        case .create: .init()
        case .update: .init(type: .replaceAll, animated: false)
        }
    }
}
