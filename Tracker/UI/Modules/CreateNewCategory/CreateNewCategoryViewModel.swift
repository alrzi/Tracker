import Foundation
import Combine

final class CreateNewCategoryViewModel {
    private let categoryRepository: CategoryRepository
    
    private let onCreateCategory: () -> Void
    private let onDeinit: () -> Void
    
    private let mode: Mode
    
    @Published private(set) var categoryNameStatus: CategoryNameStatus = .empty
    @Published private(set) var canCreate = false
 
    init(
        categoryRepository: CategoryRepository,
        mode: Mode,
        onCreateCategory: @escaping () -> Void,
        onDeinit: @escaping () -> Void
    ) {
        self.categoryRepository = categoryRepository
        self.mode = mode
        self.onCreateCategory = onCreateCategory
        self.onDeinit = onDeinit
    }
    
    deinit {
        onDeinit()
    }
}

extension CreateNewCategoryViewModel {
    func createButtonTapped() {
        if case .available(let name) = categoryNameStatus {
            switch mode {
            case .create:
                categoryRepository.createCategory(.init(header: name, trackers: []))
                
            case .update(let id):
                do {
                    try categoryRepository.updateCategory(.init(id: id, header: name, trackers: []))
                }
                catch {
                    preconditionFailure()
                }
            }
            
            onCreateCategory()
        }
        else {
            canCreate = false
        }
    }
    
    func categoryNameDidEntered(name: String) {
        if name.isEmpty {
            categoryNameStatus = .empty
        }
        else if name.count > 4 {
            categoryNameStatus = .available(name)
        }
        else {
            categoryNameStatus = .unavailable
        }
    }
}

extension CreateNewCategoryViewModel {
    enum Mode {
        case create
        case update(UUID)
    }
    
    enum CategoryNameStatus {
        case empty
        case available(String)
        case preInstalled(String)
        case unavailable
                
        var preinstalled: String? {
            switch self {
            case .empty, .unavailable, .available: nil
            case .preInstalled(let name): name
            }
        }
    }
}
