import Foundation

protocol TrackerPredicateBuilderProtocol {
    func buildPredicateTrackersFor(weekDay: String) -> NSPredicate
    func buildPredicateTrackersWith(name: String, forWeekDay weekDay: String) -> NSPredicate
    func buildPredicateCompletedTrackersWith(name: String, forDate date: Date) -> NSPredicate
    func buildPredicateCompletedTrackersFor(date: Date) -> NSPredicate
    func buildPredicateUncompletedTrackersWith(name: String, forWeekDay weekDay: String, andForDate date: String) -> NSPredicate
    func buildPredicateUncompletedTrackers(forWeekDay weekDay: String, andForDate date: String) -> NSPredicate
}

protocol TrackerRecordPredicateBuilderProtocol {
    func buildPredicateIsCompletedFor(selectedDate date: Date, trackerWithId id: UUID) -> NSPredicate
}

protocol TrackerCategoryPredicateBuilderProtocol {
    func buildPredicateCategory(name: String) -> NSPredicate
}

final class PredicateBuilder {
    private let calendar: Calendar
    
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
}

extension PredicateBuilder: TrackerPredicateBuilderProtocol {
    func buildPredicateTrackersFor(weekDay: String) -> NSPredicate {
        predicate(weekDay: weekDay)
    }

    func buildPredicateTrackersWith(name: String, forWeekDay weekDay: String) -> NSPredicate {
        let namePredicate = predicate(name: name)
        let weekDayPredicate = predicate(weekDay: weekDay)

        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            namePredicate, weekDayPredicate
        ])
    }

    func buildPredicateCompletedTrackersWith(name: String, forDate date: Date) -> NSPredicate {
        let namePredicate = predicate(name: name)
        let completedForDatePredicate = predicateCompletedTrackersFor(date: date)

        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            namePredicate, completedForDatePredicate
        ])
    }

    func buildPredicateCompletedTrackersFor(date: Date) -> NSPredicate {
        predicateCompletedTrackersFor(date: date)
    }

    func buildPredicateUncompletedTrackersWith(name: String, forWeekDay weekDay: String, andForDate date: String) -> NSPredicate {
        let weekDayPredicate = predicate(weekDay: weekDay)
        let uncompletedForDatePredicate = predicateUncompletedTrackersFor(date: date)
        let neverTrackedPredicate = predicateNeverTrackedTracker()
        let namePredicate = predicate(name: name)

        let dontTrackedAndForDayOfWeek = NSCompoundPredicate(andPredicateWithSubpredicates: [
            neverTrackedPredicate, weekDayPredicate, namePredicate
        ])

        let uncompletedAndForDayOfWeek = NSCompoundPredicate(andPredicateWithSubpredicates: [
            uncompletedForDatePredicate, weekDayPredicate, namePredicate
        ])

        return NSCompoundPredicate(orPredicateWithSubpredicates: [
            dontTrackedAndForDayOfWeek, uncompletedForDatePredicate
        ])
    }

    func buildPredicateUncompletedTrackers(forWeekDay weekDay: String, andForDate date: String) -> NSPredicate {
        let weekDayPredicate = predicate(weekDay: weekDay)
        let uncompletedForDatePredicate = predicateUncompletedTrackersFor(date: date)
        let neverTrackedPredicate = predicateNeverTrackedTracker()

        let dontTrackedAndForDayOfWeek = NSCompoundPredicate(andPredicateWithSubpredicates: [
            neverTrackedPredicate, weekDayPredicate
        ])

        let uncompletedAndForDayOfWeek = NSCompoundPredicate(andPredicateWithSubpredicates: [
            uncompletedForDatePredicate, weekDayPredicate
        ])

        return NSCompoundPredicate(orPredicateWithSubpredicates: [
            dontTrackedAndForDayOfWeek, uncompletedForDatePredicate
        ])
    }
}

extension PredicateBuilder: TrackerRecordPredicateBuilderProtocol {
    func buildPredicateIsCompletedFor(selectedDate date: Date, trackerWithId id: UUID) -> NSPredicate {
        let idPredicate = predicate(id: id)
        let datePredicate = predicate(date: date)

        return NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                idPredicate,
                datePredicate
            ]
        )
    }
}

extension PredicateBuilder: TrackerCategoryPredicateBuilderProtocol {
    func buildPredicateCategory(name: String) -> NSPredicate {
        NSPredicate(
            format: "%K == %@",
            #keyPath(CategoryObject.title),
            name
        )
    }
}

private extension PredicateBuilder {
    // MARK: - TrackerObject
    func predicate(weekDay: String) -> NSPredicate {
        NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerObject.weekDays),
            weekDay
        )
    }

    func predicate(name: String) -> NSPredicate {
        NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerObject.name),
            name
        )
    }

    func predicateNeverTrackedTracker() -> NSPredicate {
        NSPredicate(
            format: "%K.@count == 0",
            #keyPath(TrackerObject.trackerRecord)
        )
    }

    func predicateUncompletedTrackersFor(date: String) -> NSPredicate {
        NSPredicate(
            format: "SUBQUERY(%K, $record, $record.%K == %@).@count == 0",
            #keyPath(TrackerObject.trackerRecord),
            #keyPath(RecordObject.date),
            date
        )
    }

    func predicateCompletedTrackersFor(date: Date) -> NSPredicate {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        
        return NSPredicate(
            format: "ANY %K.%K >= %@ AND ANY %K.%K < %@",
            #keyPath(TrackerObject.trackerRecord),
            #keyPath(RecordObject.date),
            startOfDay as CVarArg,
            #keyPath(TrackerObject.trackerRecord),
            #keyPath(RecordObject.date),
            endOfDay as CVarArg
        )
    }

    // MARK: - RecordObject
    func predicate(id: UUID) -> NSPredicate {
        NSPredicate(
            format: "%K == %@",
            #keyPath(RecordObject.id),
            id as CVarArg
        )
    }
    
    func predicate(date: Date) -> NSPredicate {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        
        return NSPredicate(
            format: "%K >= %@ AND %K < %@",
            #keyPath(RecordObject.date),           
            startOfDay as CVarArg,
            #keyPath(RecordObject.date),
            endOfDay as CVarArg
        )
    }
}
