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
