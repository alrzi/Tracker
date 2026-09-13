enum DaySwipeDirection {
    case previous
    case next
}

extension DaySwipeDirection {
    var dayOffset: Int {
        switch self {
        case .previous: -1
        case .next: 1
        }
    }
}
