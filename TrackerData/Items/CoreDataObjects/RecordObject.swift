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

extension RecordObject: Entity { }

extension RecordObject: CopyableEntity {
    func copy(from record: TrackerRecord) {
        self.id = record.id
        self.date = record.date
    }
}

extension TrackerRecord: Initable {
    init(object: RecordObject) {
        self.init(
            id: object.id,
            date: object.date
        )
    }
}
