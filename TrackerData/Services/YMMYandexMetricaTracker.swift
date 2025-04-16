//
//  YMMYandexMetricaTracker.swift
//  Tracker
//
//  Created by Александр Зиновьев on 25.08.2024.
//

import Foundation
import TrackerDomain
//import AppMetricaCore

final class YMMYandexMetricaAnaliticsTracker: AnalyticsTracking {
//    private let tracker: AppMetrica.Type
    
//    init(
//        tracker: AppMetrica.Type = AppMetrica.self,
//        configuration: Credentials = .current
//    ) {
//        self.tracker = tracker
//                
//        guard let configuration = AppMetricaConfiguration(apiKey: configuration.apiKey) else {
//            return
//        }
//        
//        tracker.activate(with: configuration)
//    }
    
    func track(event: TrackableEvent) {
//        tracker.reportEvent(name: event.name, parameters: event.properties)
    }
}

extension YMMYandexMetricaAnaliticsTracker {
    struct Credentials: Hashable {
        let apiKey: String
        
        init(apiKey: String) {
            self.apiKey = apiKey
        }
    }
}

private extension YMMYandexMetricaAnaliticsTracker.Credentials {
    static let current: Self = .init(apiKey: "0ef77cda-6876-40ae-a73f-cf2c0962996e")
}
