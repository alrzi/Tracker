import Foundation

public struct TrackerRecord: Identifiable, Sendable {
    public let id: UUID
    public let date: Date
    
    public init(
        id: UUID,
        date: Date
    ) {
        self.id = id
        self.date = date
    }
}
