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

    @NSManaged public var title: String
    @NSManaged public var id: UUID
    @NSManaged public var trackers: NSOrderedSet?
}
