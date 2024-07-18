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
    private let categoryStore: TrackerCategoryListProtocol
    
    var categoryHeader: ((String) -> Void)?
    
    @Published var categories: [CategoryViewModel] = []
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
    }
}

extension CategoriesListViewModel: CategoriesListViewModelProtocol {
    func getAllCategories() {
        let categories = categoryStore.getAllCategories().filter({ $0.header != Strings.Localizable.Main.pinned })
        self.categories = categories.map { CategoryViewModel(trackerCategory: $0) }
    }
    
    func categorySelected(at indexPath: IndexPath) {
        let categoryName = categories[indexPath.row].header
        categoryHeader?(categoryName)       
    }
    
    func deleteCategoryAt(indexPath: IndexPath) {
        let header = categories[indexPath.row].header
        categoryStore.removeCategoryWith(name: header)
        getAllCategories()
    }
    
    func getCategoryAt(indexPath: IndexPath) -> CategoryViewModel {
        categories[indexPath.row]
    }
}
