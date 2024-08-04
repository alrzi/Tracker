//
//  DataProviding.swift
//  Tracker
//
//  Created by Александр Зиновьев on 29.07.2024.
//

import Foundation
import Combine
import UIKit.NSDiffableDataSourceSectionSnapshot
import CoreData.NSManagedObjectID

//protocol DataProviding {
//    var categoriesPublisher: any Publisher<[TrackerSection], Never> { get }
//    var snapshotPublisher: any Publisher<NSDiffableDataSourceSnapshot<String, NSManagedObjectID>, Never> { get }
//    
//    func fetch() throws
//
//    // Filtering
//    func fetchTrackersFor(weekDay: String) throws
//    func fetchCompletedTrackersFor(weekDay: String) throws
//    
//    func fetchTrackersWith(name: String, forWeekDay weekDay: String) throws
//    func fetchCompletedTrackersWith(name: String, weekDay: String) throws
//    func fetchUncompletedTrackersFor(weekDay: String, andForDate date: String) throws
//    func fetchUncompletedTrackersWith(name: String, forWeekDay weekDay: String, andForDate date: String) throws
//}
