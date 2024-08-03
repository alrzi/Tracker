//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Combine
import Foundation
import CoreData.NSManagedObjectID
import UIKit

final class TrackersViewModel {    
    private let analyticsService: AnalyticsService
    private let dataProvider: DataProviding
    private let trackerManager: TrackerManaging
    private let router: TrackersViewRouter
    
    private var cancellable: Set<AnyCancellable> = []
    
    private var currentFilter: TrackerFilters = .forToday
    private var currentDay: Date = .now
    private var currentWeekdayString: String { currentDay.weekDayString }
    private var currentDateString: String { currentDay.dateString }
    
    @Published private(set) var state: TrackersCollectionCellState = .empty
    
    init(
        analyticsService: AnalyticsService,
        dataProvider: DataProviding,
        trackerManager: TrackerManaging,
        router: TrackersViewRouter
    ) {
        self.analyticsService = analyticsService
        self.dataProvider = dataProvider
        self.trackerManager = trackerManager
        self.router = router
        
        dataProvider.categoriesPublisher
            .sink { [weak self] sections in
                var pinnedTrackers: [Tracker] = []
                var sectionsWithUnpinnedTrackers: [TrackerSection] = []

                for section in sections {
                    var unpinned: [Tracker] = []
                    
                    for tracker in section.trackers {
                        if tracker.isPinned {
                            pinnedTrackers.append(tracker)
                        } 
                        else {
                            unpinned.append(tracker)
                        }
                    }
                    
                    if !unpinned.isEmpty {
                        sectionsWithUnpinnedTrackers.append(
                            TrackerSection(
                                id: section.id,
                                title: section.title,
                                trackers: unpinned
                            )
                        )
                    }
                }

                self?.state.pinnedSection = !pinnedTrackers.isEmpty ? .init(title: "Pinned", trackers: pinnedTrackers) : nil
                self?.state.notPinnedSections = sectionsWithUnpinnedTrackers
            }
            .store(in: &cancellable)
        
        do {
            try dataProvider.fetch()
        }
        catch {
            preconditionFailure("\(String(describing: self)) dataProvider.fetch")
        }
    }
    
    func onAppear() {
        analyticsService.handleAnalitics(event: .screenOpen(.main))
    }
    
    func onDisappear() {
        analyticsService.handleAnalitics(event: .screenClose(.main))
    }
    
    func onPinTracker(at indexPath: IndexPath) {
        guard let tracker = state.item(at: indexPath) else {
            return
        }
        
        do {
            try trackerManager.pin(tracker: tracker)
        }
        catch {
            preconditionFailure("\(String(describing: self)) onPinTracker(at indexPath: \(indexPath)")
        }
    }
    
    func onUnPinTracker(at indexPath: IndexPath) {
        guard let tracker = state.item(at: indexPath) else {
            return
        }
        
        do {
            try trackerManager.unPin(tracker: tracker)
        }
        catch {
            preconditionFailure("\(String(describing: self)) onUnPinTracker(at indexPath: \(indexPath)")
        }
    }
    
    func onTrackerMarkCompleted(at indexPath: IndexPath) {
        guard let tracker = state.item(at: indexPath) else {
            return
        }
        
        analyticsService.handleAnalitics(event: .trackItemClick(.main, .track))
        
        trackerManager.saveAsCompleted(tracker: tracker, for: currentDay)
    }
    
    func onDeleteTracker(at indexPath: IndexPath) {
        guard let tracker = state.item(at: indexPath) else {
            return
        }
        
        analyticsService.handleAnalitics(event: .deleteItemClick(.main, .delete))
        
        do {
            try trackerManager.deleteTrackerBy(id: tracker.id)
        }
        catch {
            preconditionFailure("\(String(describing: self)) onDeleteTracker(at indexPath: \(indexPath)")
        }
    }
    
    func onDateChanged(date: Date) {
        currentDay = date
        
        do {
            try dataProvider.fetchTrackersFor(weekDay: currentWeekdayString)
        }
        catch {
            print("🏹", error)
        }
    }
    
    func onSearchTextChange(text: String) {
        handle(searchText: text)
    }
    
    func handle(searchText: String?) {
        do {
            switch currentFilter {
            case .all:
                if let searchText {
                    try dataProvider.fetchTrackersWith(name: searchText, forWeekDay: currentWeekdayString)
                }
                else {
                    try dataProvider.fetchTrackersFor(weekDay: currentWeekdayString)
                }
                
            case .forToday:
                currentDay = Date()
                
                if let searchText {
                    try dataProvider.fetchTrackersWith(name: searchText, forWeekDay: Date().weekDayString)
                } 
                else {
                    try dataProvider.fetchTrackersFor(weekDay: currentWeekdayString)
                }
                
            case .completed:
                if let searchText {
                    try dataProvider.fetchCompletedTrackersWith(name: searchText, forDate: currentDay)
                }
                else {
                    try dataProvider.fetchCompletedTrackersFor(date: currentDay)
                }
                
            case .uncompleted:
                if let searchText {
                    try dataProvider.fetchUncompletedTrackersWith(
                        name: searchText,
                        forWeekDay: currentWeekdayString,
                        andForDate: currentDateString
                    )
                } 
                else {
                    try dataProvider.fetchUncompletedTrackersFor(weekDay: currentWeekdayString, andForDate: currentDateString)
                }
            }
        }
        catch {
            print(error)
        }
    }
}

// MARK: - Routing

extension TrackersViewModel {
    func onFilterButton() {
        analyticsService.handleAnalitics(event: .filterItemClick(.main, .filter))
        
        router.showFiltersAssembly(filter: currentFilter)
            .sink { [weak self] in self?.currentFilter = $0 }
            .store(in: &cancellable)
    }
            
    func onCreateTracker() {
        analyticsService.handleAnalitics(event: .addTracker(.main, .addTrack))
        
        router.showTrackerUpdatingFlow()
            .print(String(describing: TrackersViewModel.self))
            .sink { _ in }
            .store(in: &cancellable)
    }
    
    func onUpdateTracker(at index: IndexPath) {
        guard let tracker = state.item(at: index) else {
            return
        }
        
        analyticsService.handleAnalitics(event: .editItemClick(.main, .edit))
        
        router.showTrackerUpdatingFlow(tracker: tracker, date: currentDay)
            .print(String(describing: TrackersViewModel.self))
            .sink { _ in }
            .store(in: &cancellable)
    }
}
