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
    func addingTracker(_ tracker: Tracker) -> TrackerSection {
        var updatedTrackers = self.trackers
        updatedTrackers.append(tracker)
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
