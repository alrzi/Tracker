//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.03.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        let windowFromScene = UIWindow(windowScene: windowScene)
        
        // MARK: - Servises
        
        let context = ManagedObjectContext.shared.context
        
        let categoryStore = TrackerCategoryStore(context: context)
        let trackerStore = TrackerStore(context: context)
        let trackerRecordStore = TrackerRecordStore(context: context)
        
        let trackerManager = TrackerManagerImpl(
            trackerCategoryStore: categoryStore,
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore
        )
        
        let dataProvider = DataProvider(context: context)
        
        let authService = AuthService()
        let analyticsService = AnalyticsService()
        
        // MARK: - Assembly
        
        let filtersAssembly = FiltersAssembly()
        let chooseScheduleAssembly = ChooseScheduleAssembly()
        let createNewCategoryAssembly = CreateNewCategoryAssembly(categoryStore: categoryStore)
        let categoryListAssembly = CategoryListAssembly(categoryStore: categoryStore)
        
        let categoryFlowCoordinatorAssembly = CategoryFlowCoordinatorAssembly(
            categoryListAssembly: categoryListAssembly,
            createCategory: createNewCategoryAssembly
        )
        
        let createTrackerAssembly = CreateTrackerAssembly(
            trackerManager: trackerManager,
            categoryFlowCoordinatorAssembly: categoryFlowCoordinatorAssembly,
            chooseScheduleAssembly: chooseScheduleAssembly
        )
        
        let chooseTrackerAssembly = ChooseTrackerAssembly(
            createTrackerAssembly: createTrackerAssembly
        )
                      
        let trackerCreationFlowCoordinatorAssembly = TrackerCreationFlowCoordinatorAssembly(
            chooseTrackerAssembly: chooseTrackerAssembly,
            createTrackerAssembly: createTrackerAssembly,
            chooseScheduleAssembly: chooseScheduleAssembly,
            categoryFlowCoordinatorAssembly: categoryFlowCoordinatorAssembly
        )
        
        let trackersAssembly = TrackersAssembly(
            analyticsService: analyticsService,
            dataProvider: dataProvider,
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
