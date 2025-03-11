//
//  TrackersAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit
import Presentation
import TrackerDomain

final class TrackersAssembly: ViewControllerAssembly {
    typealias Context = ()
    
    private let trackerFiltersDataStorage: TrackerFiltersDataStorage
    private let analyticsTracker: AnalyticsTracking
    private let trackerManager: any TrackerManaging
    
    private let trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly
    private let trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly
    private let filtersAssembly: FiltersAssembly
    
    init(
        trackerFiltersDataStorage: TrackerFiltersDataStorage,
        analyticsTracker: AnalyticsTracking,
        trackerManager: some TrackerManaging,
        trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly,
        trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly,
        filtersAssembly: FiltersAssembly
    ) {
        self.trackerFiltersDataStorage = trackerFiltersDataStorage
        self.analyticsTracker = analyticsTracker
        self.trackerManager = trackerManager
        self.trackerCreationFlowCoordinatorAssembly = trackerCreationFlowCoordinatorAssembly
        self.trackerUpdatingFlowCoordinatorAssembly = trackerUpdatingFlowCoordinatorAssembly
        self.filtersAssembly = filtersAssembly
    }
    
    @MainActor
    func assemble(_ context: Context) -> UIViewController {
        let presentationContext = NavigationPresentationContext()
        
        let router = TrackersViewRouter(
            trackerCreationFlowCoordinatorAssembly: trackerCreationFlowCoordinatorAssembly, 
            trackerUpdatingFlowCoordinatorAssembly: trackerUpdatingFlowCoordinatorAssembly,
            filtersAssembly: filtersAssembly,
            presentationContext: presentationContext
        )
        
        let viewModel = TrackersViewModel(
            trackerFiltersDataStorage: trackerFiltersDataStorage,
            analyticsTracker: analyticsTracker,
            trackerManager: trackerManager,
            router: router
        )
        
        let viewController = TrackersViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        presentationContext.navigationController = navigationController
        
        return navigationController
    }
}
