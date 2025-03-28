//
//  TrackerCreationInvalidComponent.swift
//  Tracker
//
//  Created by Александр Зиновьев on 26.03.2025.
//

import Foundation

enum TrackerCreationInvalidComponent: Error {
    case name
    case section
    case weekDays
    case emoji
    case color
}
