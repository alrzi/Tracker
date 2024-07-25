//
//  CategoryObject.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.07.2024.
//

import CoreData

@objc(CategoryObject)
public class CategoryObject: NSManagedObject, Identifiable, Entity {
    static public let entityName = String(describing: CategoryObject.self)
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var trackers: NSSet
}

extension CategoryObject {
    func copy(from category: TrackerCategory) {
        self.id = category.id
        self.title = category.header        
    }
}

extension TrackerCategory {
    init(object: CategoryObject) {
        self.id = object.id
        self.header = object.title
        self.trackers = object.trackers.allObjects.compactMap { $0 as? TrackerObject }.map(Tracker.init)
    }
}

extension CategoryObject {

    @objc(addTrackersObject:)
    @NSManaged public func addToTrackers(_ value: TrackerObject)

    @objc(removeTrackersObject:)
    @NSManaged public func removeFromTrackers(_ value: TrackerObject)

    @objc(addTrackers:)
    @NSManaged public func addToTrackers(_ values: NSSet)

    @objc(removeTrackers:)
    @NSManaged public func removeFromTrackers(_ values: NSSet)

}
