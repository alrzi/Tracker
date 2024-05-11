import CoreData
import Combine

protocol CategoriesListViewModelProtocol {
    var categories: [CategoryViewModel] { get }
    func getAllCategories()
    func categorySelected(at indexPath: IndexPath)
    func deleteCategoryAt(indexPath: IndexPath)
    func getCategoryAt(indexPath: IndexPath) -> CategoryViewModel
}

extension CategoriesListViewModel: CreateNewCategoryViewModelDelegate {
    func categoryUpdatedOrCreated() {
        getAllCategories()
    }
}

final class CategoriesListViewModel: ObservableObject {
    var categoryHeader: ((String) -> Void)?
    
    @Published var categories: [CategoryViewModel] = []
   
    // MARK: - Dependencies
    private var categoryStore: TrackerCategoryListProtocol?
    
    // MARK: - Init
    init(categoryStore: TrackerCategoryStore? = nil) {
        self.categoryStore = try? TrackerCategoryStore()
    }
}

// MARK: - Init
extension CategoriesListViewModel: CategoriesListViewModelProtocol {
    func getAllCategories() {
        if let categories = categoryStore?.getAllCategories().filter({ $0.header != Strings.Localizable.Main.pinned }) {
            self.categories = categories.map { CategoryViewModel(trackerCategory: $0) }
        }
    }
    
    func categorySelected(at indexPath: IndexPath) {
        let categoryName = categories[indexPath.row].header
        categoryHeader?(categoryName)
        markCategoryWith(name: categoryName)
    }
    
    func markCategoryWith(name: String) {
        categoryStore?.removeMarkFromLastSelectedCategory()
        categoryStore?.markCategoryAsLastSelected(categoryName: name)
    }
    
    func deleteCategoryAt(indexPath: IndexPath) {
        let header = categories[indexPath.row].header
        categoryStore?.removeCategoryWith(name: header)
        getAllCategories()
    }
    
    func getCategoryAt(indexPath: IndexPath) -> CategoryViewModel {
        categories[indexPath.row]
    }
}
