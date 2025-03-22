//
//  TrackersAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import SwiftUI
import Foundation
import Presentation
import TrackerDomain

final class TrackersAssembly: ViewControllerAssembly {
    typealias Context = ()
    
    private let trackerManager: any TrackerManaging
    private let hapticManager: any VibrationFeedbackManaging
    
    private let trackersViewModelsFactory: TrackersViewModelsFactory
   
    init(
        trackerManager: some TrackerManaging,
        hapticManager: some VibrationFeedbackManaging,
        trackersViewModelsFactory: TrackersViewModelsFactory
    ) {
        self.trackerManager = trackerManager
        self.hapticManager = hapticManager
        self.trackersViewModelsFactory = trackersViewModelsFactory
    }
    
    @MainActor
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = TrackersViewModel(
            trackerManager: trackerManager,
            hapticManager: hapticManager,
            trackersViewModelsFactory: trackersViewModelsFactory
        )
        
        let view = TrackersView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
