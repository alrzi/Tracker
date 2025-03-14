import Foundation
import Combine
import TrackerDomain

final class CategoryCreationViewModel {
    private let categoryRepository: CategoryRepositoryProtocol
    
    private let onCreateCategory: () -> Void
    private let onDeinit: () -> Void
    
    private let mode: Mode
    
    @Published private(set) var categoryNameStatus: CategoryNameStatus = .empty
    @Published private(set) var canCreate = false
 
    init(
        categoryRepository: CategoryRepositoryProtocol,
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

extension CategoryCreationViewModel {
    func createButtonTapped() async {
        if case .available(let name) = categoryNameStatus {
            switch mode {
            case .create:
                await categoryRepository.createSection(.init(title: name, trackers: []))
                
            case .update(let id):
                do {
                    try await categoryRepository.updateCategory(.init(id: id, title: name, trackers: []))
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

extension CategoryCreationViewModel {
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
