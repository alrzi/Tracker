//
//  TrackerFormInvalidComponent.swift
//  Tracker
//
//  Created by Александр Зиновьев on 26.03.2025.
//

import Foundation

enum TrackerFormInvalidComponent: Error {
    case title
    case section
    case weekDays
    case emoji
    case color
}
