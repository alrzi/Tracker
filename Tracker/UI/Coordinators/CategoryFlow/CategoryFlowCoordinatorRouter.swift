//
//  CategoryFlowCoordinatorRouter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import Combine

final class CategoryFlowCoordinatorRouter {
    private let categoryListAssembly: CategoryListAssembly
    private let createCategory: CreateNewCategoryAssembly
                    
    private let presentationContext: PresentationContextProtocol
    
    init(
        categoryListAssembly: CategoryListAssembly,
        createCategory: CreateNewCategoryAssembly,
        presentationContext: PresentationContextProtocol
    ) {
        self.categoryListAssembly = categoryListAssembly
        self.createCategory = createCategory
        self.presentationContext = presentationContext
    }
    
    func showCategoryList() -> AnyPublisher<CategoryListAssembly.Output, CategoriesListViewModelError> {
        let router = NavigationModuleRouter(
            assembly: categoryListAssembly,
            presentationContext: presentationContext
        )
        
        return router.route()
    }
    
    func showCreateCategory(mode: CreateNewCategoryViewModel.Mode) -> AnyPublisher<(), Never> {
        let router = NavigationModuleRouter(
            assembly: createCategory,
            presentationContext: presentationContext
        )
        
        return router.route(configuration: mode)
    }
    
    func goBackTwoScreen() {
        guard let viewControllers = presentationContext.navigationController?.viewControllers else {
            return
        }
        
        if viewControllers.count >= 2 {
            let viewControllersToKeep = Array(viewControllers.prefix(viewControllers.count - 2))
            presentationContext.navigationController?.setViewControllers(viewControllersToKeep, animated: true)
        }
    }
}
