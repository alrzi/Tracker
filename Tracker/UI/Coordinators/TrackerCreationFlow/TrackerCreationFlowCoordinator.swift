//
//  TrackerCreationFlowCoordinator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 03.08.2024.
//

import Foundation
import Combine

struct TrackerCreationFlowCoordinator: ReactiveFlowCoordinator {
    private let router: TrackerCreationFlowCoordinatorRouter
    
    init(router: TrackerCreationFlowCoordinatorRouter) {
        self.router = router
    }
    
    func makeFlow() -> AnyPublisher<(), Never> {
        router.showTrackerTypeSelection()
            .flatMap { router.showTrackerCreation(kind: $0) }
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
