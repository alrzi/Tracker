//
//  NotificationDayObject.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 3/20/26.
//

import TrackerDomain
import CoreData

@objc(NotificationDayObject)
public class NotificationDayObject: NSManagedObject {
    @NSManaged public var weekDay: String
    @NSManaged public var isEnabled: Bool
    @NSManaged public var time: Date
    @NSManaged public var parentTracker: TrackerObject
}

extension NotificationDayObject: Entity { }

extension NotificationDayObject: CopyableEntity {
    func copy(from info: TrackerNotificationInformation.DayNotificationDetails) {
        self.weekDay = info.weekDay.toNumberString()
        self.isEnabled = info.isEnabled
        self.time = info.time        
    }
}
