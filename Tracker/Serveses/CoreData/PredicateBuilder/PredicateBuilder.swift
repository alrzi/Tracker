import Foundation

struct PredicateBuilder {
    private let calendar: Calendar
    
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
}

extension PredicateBuilder {
    func buildPredicateTrackersFor(weekDay: String) -> NSPredicate {
        predicate(weekDay: weekDay)
    }
    
    func buildPredicateTrackersFor(isPinned: Bool) -> NSPredicate {
        predicate(isPinned: isPinned)
    }

    func buildPredicateTrackersWith(name: String, weekDay: String) -> NSPredicate {
        NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                predicate(name: name),
                predicate(weekDay: weekDay)
            ]
        )
    }

    // MARK: - Completed
    
    func buildPredicateCompletedTrackersWith(name: String, date: Date) -> NSPredicate {
        NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                predicate(name: name),
                predicateTrackersFor(date: date)
            ]
        )
    }

    func buildPredicateCompletedTrackersFor(date: Date, weekDay: String) -> NSPredicate {
        NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                predicate(weekDay: weekDay),
                predicateTrackersFor(date: date)
            ]
        )
    }

    // MARK: - Uncompleted
    
    func buildPredicateUncompletedTrackersWith(name: String, date: Date, weekDay: String) -> NSPredicate {
        NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                predicate(name: name),
                predicateUncompletedTrackersFor(date: date),
                predicate(weekDay: weekDay),
            ]
        )
    }

    func buildPredicateUncompletedTrackersFor(date: Date, weekDay: String) -> NSPredicate {
        NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                predicate(weekDay: weekDay),
                predicateUncompletedTrackersFor(date: date)
            ]
        )
    }
}

extension PredicateBuilder {
    func buildPredicateIsCompletedFor(selectedDate date: Date, trackerWithId id: UUID) -> NSPredicate {
        NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                predicate(id: id),
                predicate(date: date)
            ]
        )
    }
}

extension PredicateBuilder {
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
    
    func predicate(isPinned: Bool) -> NSPredicate {
        NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerObject.isPinned),
            NSNumber(value: isPinned)
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

    func predicateUncompletedTrackersFor(date: Date) -> NSPredicate {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        
        return NSPredicate(
            format: "SUBQUERY(%K, $record, $record.%K >= %@ AND $record.%K < %@).@count == 0",
            #keyPath(TrackerObject.trackerRecord),
            #keyPath(RecordObject.date),
            startOfDay as CVarArg,
            #keyPath(RecordObject.date),
            endOfDay as CVarArg
        )
    }

    func predicateTrackersFor(date: Date) -> NSPredicate {
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
