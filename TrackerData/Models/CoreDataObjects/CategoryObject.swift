//
//  CategoryObject.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.07.2024.
//

import TrackerDomain
import CoreData

@objc(CategoryObject)
public class CategoryObject: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var trackers: Set<TrackerObject>
}

extension CategoryObject: Entity {
    public static let entityName = String(describing: CategoryObject.self)
}

extension CategoryObject {
    func copy(from category: TrackerSection) {
        self.id = category.id
        self.title = category.title
    }
}

extension TrackerSection {
    init(object: CategoryObject) {
        self.init(
            id: object.id,
            title: object.title,
            trackers: []
        )
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
