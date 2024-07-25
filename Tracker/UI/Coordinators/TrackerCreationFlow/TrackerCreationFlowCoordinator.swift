//
//  TrackerCreationFlowCoordinator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine

struct TrackerCreationFlowCoordinator: ReactiveFlowCoordinator {
    private let userInputCollector: UserInputCollector
    
    private let router: TrackerCreationFlowCoordinatorRouter
    
    init(
        userInputCollector: UserInputCollector,
        router: TrackerCreationFlowCoordinatorRouter
    ) {
        self.userInputCollector = userInputCollector
        self.router = router
    }
    
    func makeFlow() -> AnyPublisher<(), Never> {
        router.showChooseTracker()
            .flatMap { _ in router.showCreateTracker() }
            .flatMap { action in
                switch action {
                case .onCategoryFlow:
                    router.showCategoryFlow()                       
                        .handleEvents(receiveCompletion: { completion in
                            
                            guard case .failure(let error) = completion else {
                                return
                            }
                            
                            switch error {
                            case .onCategorySelected(let category):
                                userInputCollector.insert(.category(category))
                            }
                        })
                        .replaceError(with: ())
                        .eraseToAnyPublisher()
                    
                case .onSchedule:
                    router.showChooseSchedule(weekDays: userInputCollector.schedule)
                        .handleEvents(receiveOutput: { userInputCollector.insert(.weekDays($0)) })
                        .map { _ in () }
                        .eraseToAnyPublisher()
                    
                case .onCreateTracker, .onCancel:
                    router.popToRoot()
                }
            }
            .eraseToAnyPublisher()
    }
}
