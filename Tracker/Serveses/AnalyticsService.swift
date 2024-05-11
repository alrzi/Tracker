import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "0ef77cda-6876-40ae-a73f-cf2c0962996e") else { return }
        YMMYandexMetrica.activate(with: configuration)
    }

    func handleAnalitics(event: TrackerEvent) {
        var params: [String: String] = [:]
        func setParamsAndReport(event: String, screen: String, item: String? = nil) {
            params["screen"] = screen
            if let item = item {
                params["item"] = item
            }
            report(event: event, params: params)
        }

        switch event {
        case .screenOpen(let screen):
            setParamsAndReport(event: event.stringValue, screen: screen.rawValue)
        case .screenClose(let screen):
            setParamsAndReport(event: event.stringValue, screen: screen.rawValue)
        case let .trackItemClick(screen, item):
            setParamsAndReport(event: event.stringValue, screen: screen.rawValue, item: item.stringValue)
        case let .filterItemClick(screen, item):
            setParamsAndReport(event: event.stringValue, screen: screen.rawValue, item: item.stringValue)
        case let .editItemClick(screen, item):
            setParamsAndReport(event: event.stringValue, screen: screen.rawValue, item: item.stringValue)
        case let .deleteItemClick(screen, item):
            setParamsAndReport(event: event.stringValue, screen: screen.rawValue, item: item.stringValue)
        case let .addTracker(screen, item):
            setParamsAndReport(event: event.stringValue, screen: screen.rawValue, item: item.stringValue)
        }
    }

    // Private
    private func report(event: String, params: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
}

enum TrackerEvent {
    case screenOpen(Screen)
    case screenClose(Screen)
    case addTracker(Screen, Item)
    case trackItemClick(Screen, Item)
    case filterItemClick(Screen, Item)
    case editItemClick(Screen, Item)
    case deleteItemClick(Screen, Item)

    var stringValue: String {
        switch self {
        case .screenOpen:
            return "open"
        case .screenClose:
            return "close"
        case .addTracker,
            .trackItemClick,
            .filterItemClick,
            .editItemClick,
            .deleteItemClick:
            return "click"
        }
    }

    enum Screen: String {
        case main = "Main"
    }

    enum Item {
        case addTrack
        case track
        case filter
        case edit
        case delete

        var stringValue: String {
            switch self {
            case .addTrack:
                return "add_track"
            case .track:
                return "track"
            case .filter:
                return "filter"
            case .edit:
                return "edit"
            case .delete:
                return "delete"
            }
        }
    }
}
