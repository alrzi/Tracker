import CoreData
import Combine

final class CategoriesListViewModel: ObservableObject {
    private let categoryRepository: CategoryRepository
    
    let onAction: (Output) -> Void
    let onCategorySelected: (TrackerSection) -> Void
    
    @Published private(set) var categoryViewModels: [CategoryViewModel] = []
    
    init(
        categoryRepository: CategoryRepository,
        onAction: @escaping (Output) -> Void,
        onCategorySelected: @escaping (TrackerSection) -> Void
    ) {
        self.categoryRepository = categoryRepository
        self.onAction = onAction
        self.onCategorySelected = onCategorySelected
    }
}

extension CategoriesListViewModel {
    func getAllCategories() {
        let categories = categoryRepository.getAllCategories()
        
        categoryViewModels = categories.map(CategoryViewModel.init)
    }
    
    func categorySelected(at indexPath: IndexPath) {
        let selectedCategory = categoryViewModels[indexPath.row]
                
        onCategorySelected(selectedCategory.trackerCategory)
    }
    
    func onUpdateCategory(at indexPath: IndexPath) {
        let category = categoryViewModels[indexPath.row]
        
        onAction(.onUpdateCategory(category.id))
    }
    
    func deleteCategoryAt(indexPath: IndexPath) {
        let category = categoryViewModels[indexPath.row]
        
        do {
            try categoryRepository.deleteCategory(with: category.id)
        }
        catch {
            debugPrint("Can not deleteCategory")
            preconditionFailure()
        }
        
        getAllCategories()
    }
    
    func getCategoryAt(indexPath: IndexPath) -> CategoryViewModel {
        categoryViewModels[indexPath.row]
    }
    
    func onPrimary() {
        onAction(.onPrimary)
    }
}

extension CategoriesListViewModel {
    enum Output {
        case onUpdateCategory(UUID)
        case onPrimary
    }
}
