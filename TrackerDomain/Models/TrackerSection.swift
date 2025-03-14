import Foundation

public struct TrackerSection: Hashable, Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let trackers: [Tracker]
    
    public init(
        id: UUID = UUID(),
        title: String,
        trackers: [Tracker]
    ) {
        self.id = id
        self.title = title
        self.trackers = trackers
    }
}

public extension TrackerSection {
    func insertingTracker(_ tracker: Tracker, at index: Int) -> TrackerSection {
        var updatedTrackers = trackers
        updatedTrackers.insert(tracker, at: index)
        return TrackerSection(id: id, title: title, trackers: updatedTrackers)
    }
        
    func removingTracker(at index: Int) -> TrackerSection {
        guard index >= 0 && index < trackers.count else {
            return self
        }
        var updatedTrackers = trackers
        updatedTrackers.remove(at: index)
        return TrackerSection(id: id, title: title, trackers: updatedTrackers)
    }
}
