//
//  TrackerCreationFlowCoordinator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine

struct TrackerCreationFlowCoordinator: ReactiveFlowCoordinator {
    private let router: TrackerCreationFlowCoordinatorRouter
    
    init(router: TrackerCreationFlowCoordinatorRouter) {
        self.router = router
    }
    
    func makeFlow() -> AnyPublisher<(), Never> {
        router.showChooseTracker()
            .flatMap { _ in router.showCreateTracker() }
            .flatMap { destination in
                switch destination {
                case .categoryFlow: router.showCategoryFlow()
                case .schedule: router.showChooseSchedule()
                }
            }
            .eraseToAnyPublisher()
    }
}
