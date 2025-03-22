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
    private let trackerRepository: any TrackerRepositoryProtocol
    private let recordRepository: any RecordRepositoryProtocol
    private let hapticManager: any VibrationFeedbackManaging
   
    init(
        trackerManager: some TrackerManaging,
        trackerRepository: some TrackerRepositoryProtocol,
        recordRepository: some RecordRepositoryProtocol,
        hapticManager: some VibrationFeedbackManaging
    ) {
        self.trackerManager = trackerManager
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
        self.hapticManager = hapticManager
    }
    
    @MainActor
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = TrackersViewModel(
            trackerManager: trackerManager,
            trackerRepository: trackerRepository,
            recordRepository: recordRepository,
            hapticManager: hapticManager
        )
        
        let view = TrackersView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
