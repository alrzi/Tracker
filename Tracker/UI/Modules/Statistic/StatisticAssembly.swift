//
//  StatisticAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 27.07.2024.
//

import Foundation
import UIKit

final class StatisticAssembly: ViewControllerAssembly {
    typealias Context = ()
    
    private let recordRepository: RecordRepository
    private let trackerManager: TrackerManaging
    
    init(
        recordRepository: RecordRepository,
        trackerManager: TrackerManaging
    ) {
        self.recordRepository = recordRepository
        self.trackerManager = trackerManager
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let viewModel = StatisticViewModel(
            recordRepository: recordRepository,
            trackerManager: trackerManager
        )
        
        let viewController = StatisticViewController(viewModel: viewModel)
        
        return viewController
    }
}
