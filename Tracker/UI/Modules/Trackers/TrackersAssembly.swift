//
//  TrackersAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

final class TrackersAssembly {
    private let trackerManager: any TrackerManaging
    private let hapticManager: any VibrationFeedbackManaging
    private let notificationDeepLinkService: any NotificationDeepLinkServiceProtocol
    
    private let trackersViewModelsFactory: TrackersViewModelsFactory
    
    private let trackerFormAssembly: TrackerFormAssembly
   
    init(
        trackerManager: any TrackerManaging,
        hapticManager: any VibrationFeedbackManaging,
        notificationDeepLinkService: any NotificationDeepLinkServiceProtocol,
        trackersViewModelsFactory: TrackersViewModelsFactory,
        trackerFormAssembly: TrackerFormAssembly
    ) {
        self.trackerManager = trackerManager
        self.hapticManager = hapticManager
        self.notificationDeepLinkService = notificationDeepLinkService
        self.trackersViewModelsFactory = trackersViewModelsFactory
        self.trackerFormAssembly = trackerFormAssembly
    }
    
    @MainActor
    func assemble() -> UIViewController {
        let viewModel = TrackersViewModel(
            trackerManager: trackerManager,
            hapticManager: hapticManager,
            notificationDeepLinkService: notificationDeepLinkService,
            trackersViewModelsFactory: trackersViewModelsFactory
        )
        
        let view = TrackersNavigator(
            trackerFormAssembly: trackerFormAssembly,
            navigationState: viewModel
        ) {
            TrackersView(viewModel: viewModel)
        }
        
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
