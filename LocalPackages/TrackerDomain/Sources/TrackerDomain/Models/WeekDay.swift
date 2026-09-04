import Foundation

public typealias WeekDays = Set<WeekDay>

@frozen
public enum WeekDay: Int, CaseIterable, Codable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    public static func getWeekDay(from date: Date) -> Self {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = .autoupdatingCurrent
        let weekday = (calendar.component(.weekday, from: date) + 5) % 7
        
        return Self(rawValue: weekday) ?? .monday
    }
    
    public func toNumberString() -> String {
        String(rawValue)
    }
}

public extension Set where Element == WeekDay {
    func toNumbersString() -> String {
        let string = self
            .map { String($0.rawValue) }
            .joined(separator: ", ")
        
        return string
    }
}

public extension WeekDay {
    static func fromNumberString(_ string: String) -> WeekDays {
        let elements: [WeekDay] = string
            .components(separatedBy: ", ")
            .compactMap { numberString in
                guard let rawValue = Int(numberString) else {
                    return nil
                }
                
                return WeekDay(rawValue: rawValue)
            }
        
        return Set(elements)
    }
}

public extension WeekDay {
    /// Возвращает все дни недели, отсортированные согласно календарю пользователя
    static var allSortedBySystem: [WeekDay] {
        let calendar = Calendar.current
        let firstDay = calendar.firstWeekday

        return WeekDay.allCases.sorted { day1, day2 in
            let d1 = (day1.systemRawValue - firstDay + 7) % 7
            let d2 = (day2.systemRawValue - firstDay + 7) % 7
            return d1 < d2
        }
    }
}

public extension WeekDay {
    /// Системное значение дня недели для Calendar и DateComponents
    /// 1 - Воскресенье, 2 - Понедельник, ..., 7 - Суббота
    var systemRawValue: Int {
        switch self {
        case .sunday: 1
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        }
    }
}

extension WeekDay: Sendable { }

extension WeekDay: Identifiable {
    public var id: Self { self }
}
