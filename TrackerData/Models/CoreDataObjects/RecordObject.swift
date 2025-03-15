//
//  RecordObject.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.07.2024.
//

import CoreData
import TrackerDomain

@objc(RecordObject)
public class RecordObject: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var tracker: TrackerObject
}

extension RecordObject: Entity {
    public static let entityName = String(describing: RecordObject.self)
}

extension RecordObject: ValueAddable {
    func addValue(_ value: TrackerObject) {
        tracker = value
    }
}

extension RecordObject: CopyableEntity {
    func copy(from record: TrackerRecord) {
        self.id = record.id
        self.date = record.date
    }
}
