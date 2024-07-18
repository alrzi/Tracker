//
//  RecordObject.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.07.2024.
//

import CoreData

@objc(RecordObject)
public class RecordObject: NSManagedObject, Entity {
    static public let entityName = String(describing: RecordObject.self)
    
    @NSManaged public var date: Date
    @NSManaged public var id: UUID
    @NSManaged public var tracker: TrackerObject?
}
