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
    func updatingTrackers(with newTrackers: [Tracker]) -> TrackerSection {
        TrackerSection(id: self.id, title: self.title, trackers: newTrackers)
    }
    
    func addingTracker(_ tracker: Tracker) -> TrackerSection {
        var updatedTrackers = self.trackers
        updatedTrackers.append(tracker)
        return TrackerSection(id: self.id, title: self.title, trackers: updatedTrackers)
    }
    
    func removingTracker(withId id: UUID) -> TrackerSection {
        let updatedTrackers = self.trackers.filter { $0.id != id }
        return TrackerSection(id: self.id, title: self.title, trackers: updatedTrackers)
    }
    
    func removingTracker(at index: Int) -> (TrackerSection, Tracker) {
        var mutableTrackers = trackers
        let removed = mutableTrackers.remove(at: index)
        let section = TrackerSection(id: self.id, title: self.title, trackers: mutableTrackers)
        
        return (section, removed)
    }
        
    func updatingTracker(at index: Int, with newTracker: Tracker) -> TrackerSection {
        var updatedTrackers = self.trackers
                
        guard index >= 0 && index < updatedTrackers.count else {
            // If the index is out of bounds, return the original TrackerSection
            return self
        }
                
        updatedTrackers[index] = newTracker
                
        return TrackerSection(id: self.id, title: self.title, trackers: updatedTrackers)
    }
}

private extension Array {
    func elementOrNil(at index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        
        return self[index]
    }
}
