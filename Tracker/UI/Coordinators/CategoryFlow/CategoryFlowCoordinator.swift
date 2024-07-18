//
//  CategoryFlowCoordinator.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine

struct CategoryFlowCoordinator: ReactiveFlowCoordinator {
    private let router: CategoryFlowCoordinatorRouter
    
    init(router: CategoryFlowCoordinatorRouter) {
        self.router = router
    }
    
    func makeFlow() -> AnyPublisher<(), Never> {
        router.showCategoryList()
            .flatMap { _ in router.showCreateCategory() }
            .eraseToAnyPublisher()
    }
}
