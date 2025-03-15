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
    
    init(trackerManager: some TrackerManaging) {
        self.trackerManager = trackerManager
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = TrackersSwiftUIViewModel(trackerManager: trackerManager)
        let view = TrackersSwiftUIView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        return viewController
    }
}
