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
    private let trackerRepository: TrackerRepository
    private let categoryRepository: CategoryRepository
    
    private let trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly
    private let createTrackerAssembly: CreateTrackerAssembly
    private let filtersAssembly: FiltersAssembly
    
    init(
        analyticsService: AnalyticsService,
        dataProvider: DataProviderProtocol,
        trackerRepository: TrackerRepository,
        categoryRepository: CategoryRepository,
        trackerCreationFlowCoordinatorAssembly: TrackerCreationFlowCoordinatorAssembly,
        createTrackerAssembly: CreateTrackerAssembly,
        filtersAssembly: FiltersAssembly
    ) {
        self.analyticsService = analyticsService
        self.dataProvider = dataProvider
        self.trackerRepository = trackerRepository
        self.categoryRepository = categoryRepository
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
            trackerRepository: trackerRepository,
            categoryRepository: categoryRepository,
            router: router
        )
        
        let viewController = TrackersViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        presentationContext.navigationController = navigationController
        
        return navigationController
    }
}
