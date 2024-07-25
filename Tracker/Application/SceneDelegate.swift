//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.03.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        let windowFromScene = UIWindow(windowScene: windowScene)
        
        // MARK: - Servises
        
        let persistencyService = PersistencyService()
                
        let trackerStore = TrackerStore(context: persistencyService.managedObjectContext)
        let trackerRecordStore = TrackerRecordStore(context: persistencyService.managedObjectContext)
        
        let trackerRepository = TrackerRepository(
            persistencyService: persistencyService,
            predicateBuilder: .init()
        )
        
        let trackerManager = TrackerManager(trackerRepository: trackerRepository)
        
        let dataProvider = DataProvider(
            context: persistencyService.managedObjectContext,
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore
        )
        
        let authService = AuthService()
        let analyticsService = AnalyticsService()
        
        let categoryRepository = CategoryRepository(
            persistencyService: persistencyService,
            predicateBuilder: .init()
        )
        
        let userInputCollector: UserInputCollector = .init()
        
        // MARK: - Assembly
        
        let statistic = StatisticViewController(
            viewModel: .init(
                trackerRecordStore: <#T##any TrackerRecordStoreProtocol#>,
                trackerStore: <#T##any TrackerStoreDataProviderProtocol#>
            )
        )
        
        let filtersAssembly = FiltersAssembly()
        let chooseScheduleAssembly = ChooseScheduleAssembly()
        let createNewCategoryAssembly = CreateNewCategoryAssembly(categoryRepository: categoryRepository)
        let categoryListAssembly = CategoryListAssembly(categoryRepository: categoryRepository)
        
        let categoryFlowCoordinatorAssembly = CategoryFlowCoordinatorAssembly(
            categoryListAssembly: categoryListAssembly,
            createCategory: createNewCategoryAssembly
        )
        
        let createTrackerAssembly = CreateTrackerAssembly(
            trackerManager: trackerManager, 
            userInputCollector: userInputCollector,
            categoryFlowCoordinatorAssembly: categoryFlowCoordinatorAssembly,
            chooseScheduleAssembly: chooseScheduleAssembly
        )
        
        let chooseTrackerAssembly = ChooseTrackerAssembly(
            createTrackerAssembly: createTrackerAssembly
        )
                      
        let trackerCreationFlowCoordinatorAssembly = TrackerCreationFlowCoordinatorAssembly(
            userInputCollector: userInputCollector, 
            chooseTrackerAssembly: chooseTrackerAssembly,
            createTrackerAssembly: createTrackerAssembly,
            chooseScheduleAssembly: chooseScheduleAssembly,
            categoryFlowCoordinatorAssembly: categoryFlowCoordinatorAssembly
        )
        
        let trackersAssembly = TrackersAssembly(
            analyticsService: analyticsService,
            dataProvider: dataProvider, 
            trackerRepository: trackerRepository, 
            categoryRepository: categoryRepository,
            trackerCreationFlowCoordinatorAssembly: trackerCreationFlowCoordinatorAssembly,
            createTrackerAssembly: createTrackerAssembly,
            filtersAssembly: filtersAssembly
        )
        
        let tabBarAssembly = TabBarAssembly(trackersAssembly: trackersAssembly)
        let splash = SplashViewAssembly(tabBarAssembly: tabBarAssembly, authService: authService)
        
        let viewController = splash.assemble(windowFromScene)
        windowFromScene.rootViewController = viewController
        
        self.window = windowFromScene
        windowFromScene.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
