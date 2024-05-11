struct CategoryViewModel: Hashable {
    static func == (lhs: CategoryViewModel, rhs: CategoryViewModel) -> Bool {
        lhs.trackerCategory == rhs.trackerCategory
    }
    
    // MARK: - Model
    let trackerCategory: TrackerCategory
    
    init(trackerCategory: TrackerCategory) {
        self.trackerCategory = trackerCategory
    }
    
    var id: String {
        trackerCategory.id
    }
    
    var header: String {
        trackerCategory.header.capitalized
    }
    
    var isLastSelectedCategory: Bool {
        trackerCategory.isLastSelected
    }
}
