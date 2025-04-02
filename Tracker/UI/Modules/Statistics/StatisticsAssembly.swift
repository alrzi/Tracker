//
//  StatisticsAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2025.
//

import SwiftUI
import Foundation
import TrackerDomain

final class StatisticsAssembly {
    private let recordRepository: any RecordRepositoryProtocol
    private let trackerManager: any TrackerManaging
    
    init(
        recordRepository: some RecordRepositoryProtocol,
        trackerManager: some TrackerManaging
    ) {
        self.recordRepository = recordRepository
        self.trackerManager = trackerManager
    }
    
    @MainActor
    func assemble() -> UIViewController {
        let viewModel = StatisticsViewModel(
            recordRepository: recordRepository,
            trackerManager: trackerManager
        )
        
        let view = StatisticsView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        
        return viewController
    }
}
