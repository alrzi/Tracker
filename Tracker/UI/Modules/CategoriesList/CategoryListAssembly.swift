//
//  CategoryListAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import UIKit

final class CategoryListAssembly: ViewControllerAssembly {
    typealias Context =  LifecycleManagingContext<(), Never, ()>
    
    private let categoryStore: TrackerCategoryStore
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
    }
    
    func assemble(_ context: Context) -> UIViewController {
        let presentationContext = NavigationPresentationContext()
        
        let viewModel = CategoriesListViewModel(categoryStore: categoryStore)
        let viewController = CategoriesListViewController(viewModel: viewModel)
        
        return viewController
    }
}
