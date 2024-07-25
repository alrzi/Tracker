//
//  CategoryListAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import UIKit

final class CategoryListAssembly: ViewControllerAssembly {
    typealias Output = CategoriesListViewModel.Output
    typealias Context =  LifecycleManagingContext<Output, CategoriesListViewModelError, ()>
    
    private let categoryRepository: CategoryRepository
    
    init(categoryRepository: CategoryRepository) {
        self.categoryRepository = categoryRepository
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let presentationContext = NavigationPresentationContext()
        
        let viewModel = CategoriesListViewModel(
            categoryRepository: categoryRepository,
            onAction: {
                context.resultObserver.send($0)
            },
            onCategorySelected: {
                context.resultObserver.send(completion: .failure(.onCategorySelected($0)))
                context.closingContext.close()
            }
        )
        
        let viewController = CategoriesListViewController(viewModel: viewModel)
        
        return viewController
    }
}
