//
//  TrackersSwiftUIAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import SwiftUI
import Foundation
import Presentation
import TrackerDomain

final class TrackersSwiftUIAssembly: ViewControllerAssembly {
    typealias Context = ()
    
    private let trackerManager: any TrackerManaging
    private let trackerRepository: TrackerRepositoryProtocol
    
    init(trackerManager: any TrackerManaging, trackerRepository: TrackerRepositoryProtocol) {
        self.trackerManager = trackerManager
        self.trackerRepository = trackerRepository
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = TrackersSwiftUIViewModel(trackerManager: trackerManager, trackerRepository: trackerRepository)
        let view = TrackersSwiftUIView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
