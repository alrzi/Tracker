import Foundation

struct CategoryViewModel: Hashable {
    static func == (lhs: CategoryViewModel, rhs: CategoryViewModel) -> Bool {
        lhs.trackerCategory == rhs.trackerCategory
    }
    
    // MARK: - Model
    let trackerCategory: TrackerCategory
    
    init(trackerCategory: TrackerCategory) {
        self.trackerCategory = trackerCategory
    }
    
    var id: UUID {
        trackerCategory.id
    }
    
    var header: String {
        trackerCategory.header.capitalized
    }
}
