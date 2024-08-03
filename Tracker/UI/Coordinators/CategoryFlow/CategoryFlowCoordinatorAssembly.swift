//
//  CategoryFlowCoordinatorAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine

final class CategoryFlowCoordinatorAssembly {
    private let categoryListAssembly: CategoryListAssembly
    private let createCategory: CategoryCreationAssembly
    
    init(
        categoryListAssembly: CategoryListAssembly,
        createCategory: CategoryCreationAssembly
    ) {
        self.categoryListAssembly = categoryListAssembly
        self.createCategory = createCategory
    }
    
    func assemble(
        presentationContext: PresentationContextProtocol
    ) -> AnyPublisher<(), CategoriesListViewModelError> {
        let router = CategoryFlowCoordinatorRouter(
            categoryListAssembly: categoryListAssembly,
            createCategory: createCategory,
            presentationContext: presentationContext
        )
        
        return CategoryFlowCoordinator(router: router)
            .makeFlow()
    }
}
