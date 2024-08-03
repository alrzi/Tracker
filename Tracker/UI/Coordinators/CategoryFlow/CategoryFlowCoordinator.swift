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
    
    func makeFlow() -> AnyPublisher<(), CategoriesListViewModelError> {
        router.showCategoryList()
            .flatMap { router.showCreateCategory(mode: $0.toMode()) }
            .eraseToAnyPublisher()
    }
}

private extension CategoryListAssembly.Output {
    func toMode() -> CategoryCreationViewModel.Mode {
        switch self {
        case .onUpdateCategory(let id): .update(id)
        case .onPrimary: .create
        }
    }
}
