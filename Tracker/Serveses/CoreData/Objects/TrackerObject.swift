//
//  TrackerObject.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.07.2024.
//

import CoreData

@objc(TrackerObject)
public class TrackerObject: NSManagedObject, Identifiable {
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
        self.kind = tracker.kind        
    }
}

extension Tracker {
    init(object: TrackerObject) {
        self.id = object.id
        self.name = object.name
        self.emoji = object.emoji
        self.color = object.color
        self.isPinned = object.isPinned
        self.kind = object.kind
        self.weekDays = Set.fromString(object.weekDays) ?? .init()
        self.trackedDays = .zero
    }
}
