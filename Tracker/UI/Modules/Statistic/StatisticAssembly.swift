//
//  StatisticAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.07.2024.
//

import Foundation
import UIKit
import TrackerDomain

final class StatisticAssembly {
    typealias Context = ()
    
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
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = StatisticViewModel(
            recordRepository: recordRepository,
            trackerManager: trackerManager
        )
        
        let viewController = StatisticViewController(viewModel: viewModel)
        
        return viewController
    }
}
