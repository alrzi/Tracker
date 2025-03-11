//
//  TrackerUpdatingFlowCoordinator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine
import Presentation
import TrackerDomain

struct TrackerUpdatingFlowCoordinator: ReactiveFlowCoordinator {
    private let userInputCollector: UserInputCollector
    
    private let router: TrackerUpdatingFlowCoordinatorRouter
    
    private let mode: CreateTrackerMode
    
    init(
        userInputCollector: UserInputCollector,
        router: TrackerUpdatingFlowCoordinatorRouter,
        mode: CreateTrackerMode
    ) {
        self.userInputCollector = userInputCollector
        self.router = router
        self.mode = mode
    }
    
    func makeFlow() -> AnyPublisher<(), Never> {
        router.showTrackerCreator(mode: mode)
            .flatMap { action in
                switch action {
                case .onCategoryFlow:
                    router.showCategoryFlow()   
                        .catch { error in
                            switch error {
                            case .onCategorySelected(let trackerSection):
                                userInputCollector.insert(.category(trackerSection))
                                
                                return Empty<Output, Failure>(completeImmediately: false)
                            }
                        }
                        .eraseToAnyPublisher()
                    
                case .onSchedule:
                    router.showChooseSchedule(weekDays: userInputCollector.schedule)
                        .handleEvents(receiveOutput: { userInputCollector.insert(.weekDays($0)) })
                        .flatMap { _ in Empty<Output, Failure>(completeImmediately: false) }
                        .eraseToAnyPublisher()
                    
                case .onCancel, .onCreateTracker:
                    Just(()).eraseToAnyPublisher()
                }
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
