//
//  CreateTrackerAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import UIKit

final class CreateTrackerAssembly: ViewControllerAssembly {
    typealias Context = LifecycleManagingContext<CreateTrackerViewModelImpl.Action, Never, ()>
    
    private let trackerManager: any TrackerManaging
    private let userInputCollector: UserInputCollector
    
    private let categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly
    private let chooseScheduleAssembly: ChooseScheduleAssembly
    
    init(
        trackerManager: any TrackerManaging,
        userInputCollector: UserInputCollector,
        categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly,
        chooseScheduleAssembly: ChooseScheduleAssembly
    ) {
        self.trackerManager = trackerManager
        self.userInputCollector = userInputCollector
        self.categoryFlowCoordinatorAssembly = categoryFlowCoordinatorAssembly
        self.chooseScheduleAssembly = chooseScheduleAssembly
    }
    
    func assemble(_ context: Context) -> UIViewController {        
//        let router = CreateTrackerViewRouter(
//            categoryFlowCoordinatorAssembly: categoryFlowCoordinatorAssembly,
//            chooseScheduleAssembly: chooseScheduleAssembly,
//            presentationContext: presentationContext
//        )
        
        let viewModel = CreateTrackerViewModelImpl(
            userInputCollector: userInputCollector,
            trackerManager: trackerManager,
            resultObserver: context.resultObserver, 
            mode: .create(.habit)
//            router: router
        )
        
        let viewController = CreateTrackerViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        return navigationController
    }
}
