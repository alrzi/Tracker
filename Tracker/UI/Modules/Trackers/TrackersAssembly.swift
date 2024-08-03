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
    private let dataProvider: DataProviding
    private let trackerManager: TrackerManaging
    
    private let trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly
    private let trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly
    private let filtersAssembly: FiltersAssembly
    
    init(
        analyticsService: AnalyticsService,
        dataProvider: DataProviding,
        trackerManager: TrackerManaging,
        trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly,
        trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly,
        filtersAssembly: FiltersAssembly
    ) {
        self.analyticsService = analyticsService
        self.dataProvider = dataProvider
        self.trackerManager = trackerManager
        self.trackerCreationFlowCoordinatorAssembly = trackerCreationFlowCoordinatorAssembly
        self.trackerUpdatingFlowCoordinatorAssembly = trackerUpdatingFlowCoordinatorAssembly
        self.filtersAssembly = filtersAssembly
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let presentationContext = NavigationPresentationContext()
        
        let router = TrackersViewRouter(
            trackerCreationFlowCoordinatorAssembly: trackerCreationFlowCoordinatorAssembly, 
            trackerUpdatingFlowCoordinatorAssembly: trackerUpdatingFlowCoordinatorAssembly,
            filtersAssembly: filtersAssembly,
            presentationContext: presentationContext
        )
        
        let viewModel = TrackersViewModel(
            analyticsService: analyticsService,
            dataProvider: dataProvider,
            trackerManager: trackerManager,
            router: router
        )
        
        let viewController = TrackersViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        presentationContext.navigationController = navigationController
        
        return navigationController
    }
}
