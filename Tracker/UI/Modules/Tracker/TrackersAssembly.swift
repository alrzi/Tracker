//
//  TrackersAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit

final class TrackersAssembly: ViewControllerAssembly {
    typealias Context = ()
    
    private let analyticsService: AnalyticsService
    private let dataProvider: DataProviderProtocol
    
    private let trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly
    private let createTrackerAssembly: CreateTrackerAssembly
    private let filtersAssembly: FiltersAssembly
    
    init(
        analyticsService: AnalyticsService,
        dataProvider: DataProviderProtocol,
        trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly,
        createTrackerAssembly: CreateTrackerAssembly,
        filtersAssembly: FiltersAssembly
    ) {
        self.analyticsService = analyticsService
        self.dataProvider = dataProvider
        self.trackerCreationFlowCoordinatorAssembly = trackerCreationFlowCoordinatorAssembly
        self.createTrackerAssembly = createTrackerAssembly
        self.filtersAssembly = filtersAssembly
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let presentationContext = NavigationPresentationContext()
        
        let router = TrackersViewRouter(
            trackerCreationFlowCoordinatorAssembly: trackerCreationFlowCoordinatorAssembly,
            createTrackerAssembly: createTrackerAssembly, 
            filtersAssembly: filtersAssembly,
            presentationContext: presentationContext
        )
        
        let viewModel = TrackersViewModel(
            analyticsService: analyticsService,
            dataProvider: dataProvider,
            router: router
        )
        
        let viewController = TrackersViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        navigationController.setNavigationBarHidden(true, animated: false)
        
        presentationContext.navigationController = navigationController
        
        return navigationController
    }
}
