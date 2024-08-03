//
//  DataProviding.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.07.2024.
//

import Foundation
import Combine

protocol DataProviding {
    var categoriesPublisher: any Publisher<[TrackerSection], Never> { get }
    
    func fetch() throws

    // Filtering
    func fetchTrackersFor(weekDay: String) throws
    func fetchCompletedTrackersFor(date: Date) throws
    func fetchTrackersWith(name: String, forWeekDay weekDay: String) throws
    func fetchCompletedTrackersWith(name: String, forDate date: Date) throws
    func fetchUncompletedTrackersFor(weekDay: String, andForDate date: String) throws
    func fetchUncompletedTrackersWith(name: String, forWeekDay weekDay: String, andForDate date: String) throws
}
