//
//  CategoryFlowCoordinatorRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine

final class CategoryFlowCoordinatorRouter {
    private let categoryListAssembly: CategoryListAssembly
    private let createCategory: CategoryCreationAssembly
                    
    private let presentationContext: PresentationContextProtocol
    
    init(
        categoryListAssembly: CategoryListAssembly,
        createCategory: CategoryCreationAssembly,
        presentationContext: PresentationContextProtocol
    ) {
        self.categoryListAssembly = categoryListAssembly
        self.createCategory = createCategory
        self.presentationContext = presentationContext
    }
    
    func showCategoryList() -> AnyPublisher<CategoryListAssembly.Output, CategoriesListViewModelError> {
        NavigationModuleRouter(
            assembly: categoryListAssembly,
            presentationContext: presentationContext
        )
        .route()
    }
    
    func showCreateCategory(mode: CategoryCreationViewModel.Mode) -> AnyPublisher<(), Never> {
        NavigationModuleRouter(
            assembly: createCategory,
            presentationContext: presentationContext
        )
        .route(configuration: mode)
    }
}
