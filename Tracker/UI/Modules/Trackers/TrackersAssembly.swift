//
//  TrackersAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import UIKit

final class TrackersAssembly: ViewControllerAssembly {
    typealias Context = ()
    
    private let trackerFiltersDataStorage: TrackerFiltersDataStorage
    private let analyticsService: AnalyticsService
    private let pinnedDataProvider: PinnedDataProvider
    private let dataProvider: DataProvider
    private let trackerManager: TrackerManaging
    
    private let trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly
    private let trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly
    private let filtersAssembly: FiltersAssembly
    
    init(
        trackerFiltersDataStorage: TrackerFiltersDataStorage,
        analyticsService: AnalyticsService,
        pinnedDataProvider: PinnedDataProvider,
        dataProvider: DataProvider,
        trackerManager: TrackerManaging,
        trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly,
        trackerUpdatingFlowCoordinatorAssembly: TrackerUpdatingFlowCoordinatorAssembly,
        filtersAssembly: FiltersAssembly
    ) {
        self.trackerFiltersDataStorage = trackerFiltersDataStorage
        self.analyticsService = analyticsService
        self.pinnedDataProvider = pinnedDataProvider
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
            trackerFiltersDataStorage: trackerFiltersDataStorage,
            analyticsService: analyticsService,
            pinnedDataProvider: pinnedDataProvider,
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
