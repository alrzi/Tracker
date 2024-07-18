//
//  CreateTrackerAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import UIKit

final class CreateTrackerAssembly: ViewControllerAssembly {
    typealias Context =  LifecycleManagingContext<CreateTrackerViewModelImpl.Destination, Never, ()>
    
    private let trackerManager: any TrackerManagerProtocol
    
    private let categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly
    private let chooseScheduleAssembly: ChooseScheduleAssembly
    
    init(
        trackerManager: any TrackerManagerProtocol,
        categoryFlowCoordinatorAssembly: CategoryFlowCoordinatorAssembly,
        chooseScheduleAssembly: ChooseScheduleAssembly
    ) {
        self.trackerManager = trackerManager
        self.categoryFlowCoordinatorAssembly = categoryFlowCoordinatorAssembly
        self.chooseScheduleAssembly = chooseScheduleAssembly
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let presentationContext = NavigationPresentationContext()
        
        let router = CreateTrackerViewRouter(
            categoryFlowCoordinatorAssembly: categoryFlowCoordinatorAssembly,
            chooseScheduleAssembly: chooseScheduleAssembly,
            presentationContext: presentationContext
        )                
        
        let viewModel = CreateTrackerViewModelImpl(
            trackerKind: .habit,
            tracker: nil,
            date: "ds",
            trackerManager: trackerManager,
            resultObserver: context.resultObserver,
            router: router
        )
        
        let viewController = CreateTrackerViewController(viewModel: viewModel)             
        
        if let navigationController = UIApplication.topMostViewController()?.navigationController {
            presentationContext.navigationController = navigationController
        } else {
            assertionFailure()
        }
        
        return viewController
    }
}
