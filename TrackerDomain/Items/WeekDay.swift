import Foundation

public typealias WeekDays = Set<WeekDay>

@frozen
public enum WeekDay: Int, CaseIterable {
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

extension WeekDay: Sendable { }

extension WeekDay: Identifiable {
    public var id: Self { self }
}
