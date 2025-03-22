//
//  Filter.swift
//  Tracker
//
//  Created by Александр Зиновьев on 13.07.2024.
//

import Foundation

@frozen
public enum TrackerFilter: CaseIterable, Codable {
    case forCurrentWeekDay
    case completedForDate
    case uncompletedForDate   
}
