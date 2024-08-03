import Foundation

struct TrackerSection: Hashable, Identifiable {
    let id: UUID
    let title: String
    let trackers: [Tracker]
    
    init(
        id: UUID = UUID(),
        title: String,
        trackers: [Tracker]
    ) {
        self.id = id
        self.title = title
        self.trackers = trackers
    }
}
