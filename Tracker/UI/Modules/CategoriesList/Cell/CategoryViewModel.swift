import Foundation

struct CategoryViewModel: Hashable {
    static func == (lhs: CategoryViewModel, rhs: CategoryViewModel) -> Bool {
        lhs.trackerCategory == rhs.trackerCategory
    }
    
    // MARK: - Model
    let trackerCategory: TrackerSection
    
    init(trackerCategory: TrackerSection) {
        self.trackerCategory = trackerCategory
    }
    
    var id: UUID {
        trackerCategory.id
    }
    
    var header: String {
        trackerCategory.title.capitalized
    }
}
