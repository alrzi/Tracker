import Foundation

extension Date {
    /// A date formatter that can be reused to improve performance.
    private static let dateFormatter = DateFormatter()

    var weekDayString: String {
        String(currentWeekDayNumber)
    }

    var dateString: String {
        Date.dateFormatter.dateFormat = "yyyy-MM-dd"
        return Date.dateFormatter.string(from: self)
    }

    var currentWeekDayNumber: Int {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = .current
        let weekday = (calendar.component(.weekday, from: self) + 5) % 7
        return weekday
    }
}
