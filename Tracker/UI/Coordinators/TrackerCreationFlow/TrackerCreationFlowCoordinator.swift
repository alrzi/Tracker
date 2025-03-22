//
//  TrackerCreationFlowCoordinator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 03.08.2024.
//

import Foundation
import Combine
import Presentation

struct TrackerCreationFlowCoordinator: ReactiveFlowCoordinator {
    private let router: TrackerCreationFlowCoordinatorRouter
    
    init(router: TrackerCreationFlowCoordinatorRouter) {
        self.router = router
    }
    
    func makeFlow() -> AnyPublisher<(), Never> {
        router.showTrackerCreation(kind: .habit)
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
