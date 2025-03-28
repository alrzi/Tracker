//
//  SectionsListState.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.03.2025.
//

import Foundation
import TrackerDomain

enum SectionsListState {
    case loading
    case loaded([TrackerSection])
    case error(Error)

    var models: [TrackerSection] {
        if case .loaded(let model) = self {
            model
        }
        else {
            []
        }
    }
}
