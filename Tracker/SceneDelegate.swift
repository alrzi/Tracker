//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.03.2023.
//

import Swinject
import TrackerData
import TrackerDomain
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let assembler = Assembler()
    private var resolver: Resolver { assembler.resolver }

    private var notificationCenterDelegate: UNUserNotificationCenterDelegate?

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        assembler.apply(
            assemblies: [
                TrackerDataAssembly(),
                TrackerDomainAssembly(),
                ServicesAssembly(),
                FactoriesAssembly(),
                ModulesAssembly(),
            ]
        )

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        notificationCenterDelegate = resolver.resolve(UNUserNotificationCenterDelegate.self)!
        UNUserNotificationCenter.current().delegate = notificationCenterDelegate

        let rootViewController = resolver.resolve(SplashViewAssembly.self)!.assemble(window)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        Task {
            do {
                let manager = resolver.resolve((any AppNotificationManaging).self)!
                try await manager.sync()
            }
            catch {
                print("[SceneDelegate] Notification sync failed: \(error.localizedDescription)")
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {}

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
