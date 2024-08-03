//
//  TrackerCreationAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import UIKit

final class TrackerCreationAssembly: ViewControllerAssembly {
    typealias Context = LifecycleManagingContext<TrackerCreationViewModel.Action, Never, CreateTrackerMode>
    
    private let trackerManager: any TrackerManaging
    private let userInputCollector: UserInputCollector
    
    private let categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly
    private let chooseScheduleAssembly: WeekDaysSelectionAssembly
    
    init(
        trackerManager: any TrackerManaging,
        userInputCollector: UserInputCollector,
        categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly,
        chooseScheduleAssembly: WeekDaysSelectionAssembly
    ) {
        self.trackerManager = trackerManager
        self.userInputCollector = userInputCollector
        self.categoryFlowCoordinatorAssembly = categoryFlowCoordinatorAssembly
        self.chooseScheduleAssembly = chooseScheduleAssembly
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = TrackerCreationViewModel(
            userInputCollector: userInputCollector,
            trackerManager: trackerManager,
            resultObserver: context.resultObserver, 
            mode: context.configuration
        )
        
        let viewController = TrackerCreationViewController(viewModel: viewModel)
        
        return viewController
    }
}
