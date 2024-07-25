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
    private var dataProvider: DataProviderProtocol
    private let trackerRepository: TrackerRepository
    private let categoryRepository: CategoryRepository
    private let router: TrackersViewRouter
    
    private var cancellable: Set<AnyCancellable> = []
    
    private var currentFilter: TrackerFilters = .forToday
    private var currentDay: Date = .now
    private var currentWeekdayString: String { currentDay.weekDayString }
    private var currentDateString: String { currentDay.dateString }
       
    @Published private(set) var trackerCategories: [TrackerCategory] = []
    
    @Published private(set) var trackerCategoriesSnapshot: NSDiffableDataSourceSnapshot<TrackersDataSource.Section, TrackersDataSource.SectionItem> = .init()
    
    init(
        analyticsService: AnalyticsService,
        dataProvider: DataProviderProtocol,
        trackerRepository: TrackerRepository,
        categoryRepository: CategoryRepository,
        router: TrackersViewRouter
    ) {
        self.analyticsService = analyticsService
        self.dataProvider = dataProvider
        self.trackerRepository = trackerRepository
        self.categoryRepository = categoryRepository
        self.router = router
        
        dataProvider.snapshotPublisher
            .sink { [weak self] in self?.trackerCategoriesSnapshot = $0  }
            .store(in: &cancellable)
        
        try? dataProvider.fetch()
        
//        mockCategories.forEach { category in
//            category.trackers.forEach { tracker in
//               try? trackerRepository.addCategory(withId: category.id, toTracker: tracker)
//            }
//        }
    }
    
    func getTracker(for id: NSManagedObjectID) -> Tracker? {
        dataProvider.getTracker(at: id)
    }
    
    func onDateChanged(date: Date) {
        currentDay = date
        
        do {
            if currentFilter == .forToday {
                try dataProvider.fetchTrackersFor(weekDay: currentWeekdayString)
                currentFilter = .all
            } else {
                handle(searchText: nil)
            }
        } catch {
            print("🏹", error)
        }
    }
    
    func onUpdateTracker(at index: IndexPath) {
        analyticsService.handleAnalitics(event: .editItemClick(.main, .edit))
        
        router.showCreateTracker()
            .sink { _ in }
            .store(in: &cancellable)
    }
    
    func onCreateTracker() {
        analyticsService.handleAnalitics(event: .addTracker(.main, .addTrack))
        
        router.showTrackerCreationFlow()
            .sink { _ in }
            .store(in: &cancellable)
    }
    
    func onFilterButton() {
        analyticsService.handleAnalitics(event: .filterItemClick(.main, .filter))
        
        router.showFiltersAssembly(filter: currentFilter)
            .sink { [weak self] in self?.currentFilter = $0 }
            .store(in: &cancellable)
    }
    
    func onPinTracker(at indexPath: IndexPath) {
        dataProvider.pinTrackerAt(indexPath: indexPath)
    }
    
    func onUnPinTracker(at indexPath: IndexPath) {
        dataProvider.unPinTrackerAt(indexPath: indexPath)
    }
    
    func onTrackerMarkCompleted(at indexPath: IndexPath) {
        analyticsService.handleAnalitics(event: .trackItemClick(.main, .track))
        
        do {
            try dataProvider.saveAsCompletedTracker(with: indexPath, for: currentDateString)
        } catch {
            print("⛈️", error)
        }
    }
    
    func onDeleteTracker(at indexPath: IndexPath) {
        analyticsService.handleAnalitics(event: .deleteItemClick(.main, .delete))
        
        do {
            try dataProvider.deleteTracker(at: indexPath)
        } catch {
            print("⛈️", error)
        }
    }
    
    func onAppear() {
        analyticsService.handleAnalitics(event: .screenOpen(.main))
    }
    
    func onDisappear() {
        analyticsService.handleAnalitics(event: .screenClose(.main))
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
                } else {
                    try dataProvider.fetchTrackersFor(weekDay: currentWeekdayString)
                }
            case .forToday:
                currentDay = Date()
                
                if let searchText {
                    try dataProvider.fetchTrackersWith(name: searchText, forWeekDay: Date().weekDayString)
                } else {
                    try dataProvider.fetchTrackersFor(weekDay: currentWeekdayString)
                }
            case .completed:
                if let searchText {
                    try dataProvider.fetchCompletedTrackersWith(
                        name: searchText, forDate: currentDateString)
                } else {
                    try dataProvider.fetchCompletedTrackersFor(date: currentDateString)
                }
            case .uncompleted:
                if let searchText {
                    try dataProvider.fetchUncompletedTrackersWith(name: searchText, forWeekDay: currentWeekdayString, andForDate: currentDateString)
                } else {
                    try dataProvider.fetchUncompletedTrackersFor(weekDay: currentWeekdayString, andForDate: currentDateString)
                }
            }
        } catch {
            print(error)
        }
    }
}
