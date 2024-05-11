import Foundation
import Combine

protocol CreateNewCategoryViewModelDelegate: AnyObject {
    func categoryUpdatedOrCreated()
}

protocol CreateNewCategoryViewModelProtocol {
    func createButtonTapped()
    func categoryNameDidEnted(name: String)
}

final class CreateNewCategoryViewModel {
    // MARK: - Public
    weak var delegate: CreateNewCategoryViewModelDelegate?
    @Published var categoryNameStatus: CategoryNameStatus = .empty
    @Published var trackerCategory: CategoryViewModel?
    
    var canCreateCategory: Bool {
        name != nil
    }
    
    enum CategoryNameStatus {
        case empty
        case available
        case unavailable
    }
    
    // MARK: - Private
    private var name: String?
    
    // MARK: - Dependencies
    private var categoryStore: TrackerCategoryListProtocol?
    
    // MARK: - Init
    init(
        trackerCategory: CategoryViewModel? = nil,
        delegate: CreateNewCategoryViewModelDelegate? = nil,
        categoryStore: TrackerCategoryStore? = nil
    ) {
        self.delegate = delegate
        self.trackerCategory = trackerCategory
        self.categoryStore = try? TrackerCategoryStore()
    }
}

extension CreateNewCategoryViewModel {
    func createButtonTapped() {
        guard let name = name else { return }
        guard let trackerCategory = trackerCategory else {
            categoryStore?.addCategory(name: name)
            delegate?.categoryUpdatedOrCreated()
            return
        }
        
        categoryStore?.update(category: trackerCategory.trackerCategory, withNewName: name)
        delegate?.categoryUpdatedOrCreated()
    }
    
    func categoryNameDidEnted(name: String) {
        guard !name.isEmpty else {
            self.name = nil
            categoryNameStatus = .empty
            return
        }
        if name != Strings.Localizable.Main.pinned && isNameAvailable(name: name) ?? false {
            self.name = name
            categoryNameStatus = .available
        } else {
            self.name = name
            categoryNameStatus = .unavailable
        }
    }
    
    // Private
    private func isNameAvailable(name: String) -> Bool? {
        return try? categoryStore?.isNameAvailable(name: name)
    }
}
