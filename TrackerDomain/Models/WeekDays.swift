import Foundation

public typealias WeekDays = Set<WeekDay>

public enum WeekDay: Int {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    public static func allCases(for calendar: Calendar = .autoupdatingCurrent) -> [Self] {
        let firstWeekDay = calendar.firstWeekday
        
        // Create an array to hold the ordered weekdays
        var orderedWeekdays: [Self] = []
        
        // Loop through the days of the week based on the first weekday
        for i in 0..<7 {
            // Calculate the index based on the first weekday
            let index = (firstWeekDay - 1 + i) % 7
            
            // Append the corresponding weekday case
            if let weekday = Self(rawValue: index + 1) {
                orderedWeekdays.append(weekday)
            }
        }
        
        return orderedWeekdays
    }
    
    public static func getWeekDay(from date: Date) -> Self {
        let calendar = Calendar.autoupdatingCurrent
        let weekday = calendar.component(.weekday, from: date)
        
        return Self(rawValue: weekday) ?? .monday
    }
    
    public func localizedString(
        locale: Locale = .autoupdatingCurrent,
        format: Date.FormatStyle.Symbol.Weekday = .wide
    ) -> String {
        let calendar = Calendar.autoupdatingCurrent
        
        if let date = calendar.date(from: DateComponents(weekday: rawValue)) {
            return date.formatted(.dateTime.weekday(format).locale(locale))
        }
        
        return ""
    }
}

extension WeekDay: Identifiable {
    public var id: Self { self }
}

extension WeekDay: Sendable { }

extension WeekDays {
    public func formatted() -> String? {
        guard !self.isEmpty else {
            return nil
        }
        
        return self.sorted(by: { $0.rawValue < $1.rawValue }).map { $0.localizedString(format: .short) }.joined(separator: ", ")
    }
}
