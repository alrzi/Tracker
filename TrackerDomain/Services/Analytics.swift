//
//  Analytics.swift
//  TrackerDomain
//
//  Created by Александр Зиновьев on 16.04.2025.
//

import Foundation

public protocol AnalyticsProtocol {
    func track(type: TrackType)
}
