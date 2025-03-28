//
//  CategoryListAssembly.swift
//  Tracker
//
//  Created by Александр Зиновьев on 06.07.2024.
//

import UIKit
import TrackerDomain

final class CategoryListAssembly {
    private let categoryRepository: CategoryRepositoryProtocol
    
    init(categoryRepository: CategoryRepositoryProtocol) {
        self.categoryRepository = categoryRepository
    }
    
    @MainActor
    func assemble(_ context: ()) -> UIViewController {
        let viewModel = CategoriesListViewModel(
            categoryRepository: categoryRepository,
            onAction: { _ in },
            onCategorySelected: { _ in }
        )
        
        let viewController = CategoriesListViewController(viewModel: viewModel)
        
        return viewController
    }
}
