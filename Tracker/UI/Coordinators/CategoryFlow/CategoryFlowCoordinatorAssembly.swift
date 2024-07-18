//
//  CategoryFlowCoordinatorAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine

final class CategoryFlowCoordinatorAssembly {
    private let categoryListAssembly: CategoryListAssembly
    private let createCategory: CreateNewCategoryAssembly
    
    init(
        categoryListAssembly: CategoryListAssembly,
        createCategory: CreateNewCategoryAssembly
    ) {
        self.categoryListAssembly = categoryListAssembly
        self.createCategory = createCategory
    }
    
    func assemble(
        presentationContext: PresentationContextProtocol
    ) -> AnyPublisher<(), Never> {
        let router = CategoryFlowCoordinatorRouter(
            categoryListAssembly: categoryListAssembly,
            createCategory: createCategory,
            presentationContext: presentationContext
        )
        
        return CategoryFlowCoordinator(router: router)
            .makeFlow()
    }
}
