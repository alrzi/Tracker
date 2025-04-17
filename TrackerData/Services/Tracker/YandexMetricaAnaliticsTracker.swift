//
//  YandexMetricaAnaliticsTracker.swift
//  TrackerData
//
//  Created by Александр Зиновьев on 17.04.2025.
//

import Foundation
import TrackerDomain
import AppMetricaCore

final class YandexMetricaAnaliticsTracker: AnalyticsProtocol {
    init(configuration: YandexMetricaAnaliticsTrackerCredentials = .current) {
        guard let configuration = AppMetricaConfiguration(apiKey: configuration.apiKey) else {
            return
        }

        AppMetrica.activate(with: configuration)
    }
    
    func track(type: TrackType) {
        AppMetrica.reportEvent(name: type.name, parameters: type.properties)
    }
}

private extension YandexMetricaAnaliticsTrackerCredentials {
    static let current = Self(apiKey: "0ef77cda-6876-40ae-a73f-cf2c0962996e")
}
