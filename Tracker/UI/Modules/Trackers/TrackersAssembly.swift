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
   
    init(
        trackerManager: any TrackerManaging,
        trackerRepository: any TrackerRepositoryProtocol,
        recordRepository: any RecordRepositoryProtocol
    ) {
        self.trackerManager = trackerManager
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
    }
    
    @MainActor
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = TrackersViewModel(
            trackerManager: trackerManager,
            trackerRepository: trackerRepository,
            recordRepository: recordRepository
        )
        
        let view = TrackersView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
