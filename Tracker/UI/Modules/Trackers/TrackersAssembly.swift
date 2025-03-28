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
    typealias Context = ()
    
    private let trackerManager: any TrackerManaging
    private let hapticManager: any VibrationFeedbackManaging
    
    private let trackersViewModelsFactory: TrackersViewModelsFactory
    
    private let trackerCreationSwiftUIAssembly: TrackerCreationAssembly
   
    init(
        trackerManager: some TrackerManaging,
        hapticManager: some VibrationFeedbackManaging,
        trackersViewModelsFactory: TrackersViewModelsFactory,
        trackerCreationSwiftUIAssembly: TrackerCreationAssembly
    ) {
        self.trackerManager = trackerManager
        self.hapticManager = hapticManager
        self.trackersViewModelsFactory = trackersViewModelsFactory
        self.trackerCreationSwiftUIAssembly = trackerCreationSwiftUIAssembly
    }
    
    @MainActor
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = TrackersViewModel(
            trackerManager: trackerManager,
            hapticManager: hapticManager,
            trackersViewModelsFactory: trackersViewModelsFactory
        )
        
        let viewT = TrackersNavigator(
            trackerCreationSwiftUIAssembly: trackerCreationSwiftUIAssembly,
            navigationState: viewModel
        ) {
            TrackersView(viewModel: viewModel)
        }
        
        let viewController = UIHostingController(rootView: viewT)
        return viewController
    }
}
