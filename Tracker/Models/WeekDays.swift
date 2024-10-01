import Foundation

@objc
public enum WeekDay: Int64, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    // create set of ints 0...6
    static let allDaysOfWeek = Set(Self.allCases.map { Int($0.rawValue) })
    
    static var count: Int {
        allDaysOfWeek.count
    }
    
    var abbreviationLong: String {
        switch self {
        case .monday: Strings.Localizable.Schedule.monday
        case .tuesday: Strings.Localizable.Schedule.tuesday
        case .wednesday: Strings.Localizable.Schedule.wednesday
        case .thursday: Strings.Localizable.Schedule.thursday
        case .friday: Strings.Localizable.Schedule.friday
        case .saturday: Strings.Localizable.Schedule.saturday
        case .sunday: Strings.Localizable.Schedule.sunday
        }
    }
    
    var abbreviationShort: String {
        switch self {
        case .monday: Strings.Localizable.Schedule.mon
        case .tuesday: Strings.Localizable.Schedule.tue
        case .wednesday: Strings.Localizable.Schedule.wed
        case .thursday: Strings.Localizable.Schedule.thu
        case .friday: Strings.Localizable.Schedule.fri
        case .saturday: Strings.Localizable.Schedule.sat
        case .sunday: Strings.Localizable.Schedule.sun
        }
    }
}

extension WeekDay: Comparable {
    public static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Set<Int> {
    static func fromString(_ str: String) -> Set<Int>? {
        let maxElement = 6
        let elements = str
            .components(separatedBy: ", ") // turn to array of string numbers
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            .filter { 0...maxElement ~= $0 } // filter to have only numbers from 0..<7
        
        return Set(elements) // turn to set
    }
    
    func weekdayStringShort() -> String {
        if self == WeekDay.allDaysOfWeek {
            return Strings.Localizable.Schedule.everyday
        } 
        else {
            let weekDay = WeekDay
                .allCases // take all cases  from Mon to Sun
                .filter { self.contains(Int($0.rawValue)) } // check if set has any of weekDays
                .map { $0.abbreviationShort } // map(transform) to string
                .joined(separator: ", ") // joing with coma
            return weekDay
        }
    }
    
    func toNumbersString() -> String {
        return self
            .filter { 0..<7 ~= $0 } // take only numbers from 0 to 6
            .sorted() // sort Comparable
            .map { String($0) } // map(transform) to string
            .joined(separator: ", ") // joing with coma
    }
}
