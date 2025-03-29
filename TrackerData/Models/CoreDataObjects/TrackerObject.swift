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
    @NSManaged public var category: CategoryObject
    @NSManaged public var trackerRecord: Set<RecordObject>
}

extension TrackerObject: Entity {
    public static let entityName = String(describing: TrackerObject.self)
}

extension TrackerObject: ValueAddable {
    func addValue(_ value: CategoryObject) {
        category = value
    }
}

extension TrackerObject: CopyableEntity {
    func copy(from tracker: Tracker) {
        self.id = tracker.id
        self.name = tracker.name
        self.color = tracker.color
        self.emoji = tracker.emoji
        self.isPinned = tracker.isPinned
        self.weekDays = tracker.weekDays.toNumbersString()
        self.category = category
        self.trackerRecord = trackerRecord
    }
}

extension Tracker: Initable {
    init(object: TrackerObject) {
        self.init(
            id: object.id,
            name: object.name,
            emoji: object.emoji,
            color: object.color,
            schedule: WeekDay.fromNumberString(object.weekDays),
            isPinned: object.isPinned,
            trackedDays: object.trackerRecord.count,
            categoryId: object.category.id
        )
    }
}
