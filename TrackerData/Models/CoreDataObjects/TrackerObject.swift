//
//  TrackerObject.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.07.2024.
//

import TrackerDomain
import CoreData

@objc(TrackerObject)
public class TrackerObject: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var color: String
    @NSManaged public var emoji: String
    @NSManaged public var isPinned: Bool
    @NSManaged public var weekDays: String
    @NSManaged public var kind: TrackerKind
    @NSManaged public var category: CategoryObject
    @NSManaged public var trackerRecord: Set<RecordObject>
}

extension TrackerObject: Entity {
    public static let entityName = String(describing: TrackerObject.self)
}

extension TrackerObject {
    func copy(from tracker: Tracker) {
        self.id = tracker.id
        self.name = tracker.name
        self.color = tracker.color
        self.emoji = tracker.emoji
        self.isPinned = tracker.isPinned
        self.weekDays = tracker.weekDays.toNumbersString()
        self.kind = tracker.kind.toKind()
    }
}

extension Tracker {
    init(object: TrackerObject) {
        self.init(
            id: object.id,
            name: object.name,
            emoji: object.emoji,
            color: object.color,
            schedule: Set.fromString(object.weekDays),
            isPinned: object.isPinned,
            kind: object.kind.toKind(),
            trackedDays: object.trackerRecord.count,
            categoryId: object.category.id
        )
    }
}

extension Tracker.Kind {
    func toKind() -> TrackerKind {
        switch self {
        case .habit: .habit
        case .occasional: .occasional
        @unknown default: .habit
        }
    }
}

extension TrackerKind {
    func toKind() -> Tracker.Kind {
        switch self {
        case .habit: .habit
        case .occasional: .occasional
        }
    }
}
