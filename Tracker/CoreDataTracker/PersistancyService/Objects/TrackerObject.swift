//
//  TrackerObject.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.07.2024.
//

import CoreData

@objc(TrackerObject)
public class TrackerObject: NSManagedObject, Entity {
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
