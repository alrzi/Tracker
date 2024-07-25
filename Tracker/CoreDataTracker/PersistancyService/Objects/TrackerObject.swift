//
//  TrackerObject.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.07.2024.
//

import CoreData

@objc(TrackerObject)
public class TrackerObject: NSManagedObject, Entity, Identifiable {
    static public let entityName = String(describing: TrackerObject.self)

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var color: String
    @NSManaged public var emoji: String
    @NSManaged public var isPinned: Bool
    @NSManaged public var weekDays: String
    @NSManaged public var kind: TrackerKind
    @NSManaged public var category: CategoryObject?
    @NSManaged public var trackerRecord: NSSet?
}

extension TrackerObject {
    func copy(from tracker: Tracker) {
        self.id = tracker.id
        self.name = tracker.name
        self.color = tracker.color
        self.emoji = tracker.emoji
        self.isPinned = tracker.isAttached
        self.weekDays = tracker.schedule.toNumbersString()
        self.kind = tracker.kind        
    }
}

extension Tracker {
    init(object: TrackerObject) {
        self.id = object.id
        self.name = object.name
        self.emoji = object.emoji
        self.color = object.color
        self.isAttached = object.isPinned
        self.kind = object.kind
        self.schedule = Set.fromString(object.weekDays) ?? .init()
    }
}
