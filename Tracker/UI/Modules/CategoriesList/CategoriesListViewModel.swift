import Combine
import TrackerDomain

@MainActor
final class CategoriesListViewModel: ObservableObject {
    private let categoryRepository: any CategoryRepositoryProtocol
    
    let onAction: (Output) -> Void
    let onCategorySelected: (TrackerSection) -> Void
    
    @Published private(set) var categoryViewModels: [CategoryViewModel] = []
    
    init(
        categoryRepository: some CategoryRepositoryProtocol,
        onAction: @escaping (Output) -> Void,
        onCategorySelected: @escaping (TrackerSection) -> Void
    ) {
        self.categoryRepository = categoryRepository
        self.onAction = onAction
        self.onCategorySelected = onCategorySelected
    }
}

extension CategoriesListViewModel {
    func getAllCategories() async {
        do {
            let categories = try await categoryRepository.getSections(with: "", for: Date.now.weekDayString, fetchLimit: 10, fetchOffset: 0)
            categoryViewModels = categories.map(CategoryViewModel.init)
        }
        catch {
            debugPrint(error)
        }
    }
    
    func categorySelected(at indexPath: IndexPath) {
        let selectedCategory = categoryViewModels[indexPath.row]
                
        onCategorySelected(selectedCategory.trackerCategory)
    }
    
    func onUpdateCategory(at indexPath: IndexPath) {
        let category = categoryViewModels[indexPath.row]
        
        onAction(.onUpdateCategory(category.id))
    }
    
    func deleteCategoryAt(indexPath: IndexPath) async {
        let category = categoryViewModels[indexPath.row]
        
        do {
            try await categoryRepository.deleteCategory(with: category.id)
        }
        catch {
            debugPrint("Can not deleteCategory")
            preconditionFailure()
        }
        
        await getAllCategories()
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
