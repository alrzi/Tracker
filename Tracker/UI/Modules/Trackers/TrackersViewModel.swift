//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Combine
import Foundation

final class TrackersViewModel {    
    private let analyticsService: AnalyticsService
    private let pinnedDataProvider: PinnedDataProvider
    private let dataProvider: DataProvider
    private let trackerManager: TrackerManaging
    private let router: TrackersViewRouter
    
    private var cancellable: Set<AnyCancellable> = []
    
    private var currentFilter: CurrentValueSubject<TrackerFilters, Never> = .init(.forCurrentWeekDay)
    private var date: Date = .now
    private var weekDay: String { date.weekDayString }
    
    @Published private(set) var state: TrackersCollectionCellState = .empty
    
    init(
        analyticsService: AnalyticsService,
        pinnedDataProvider: PinnedDataProvider,
        dataProvider: DataProvider,
        trackerManager: TrackerManaging,
        router: TrackersViewRouter
    ) {
        self.analyticsService = analyticsService
        self.pinnedDataProvider = pinnedDataProvider
        self.dataProvider = dataProvider
        self.trackerManager = trackerManager
        self.router = router
        
        currentFilter
            .dropFirst()
            .sink { [weak self] _ in self?.handle(searchText: nil) }
            .store(in: &cancellable)
        
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
                
                if pinnedTrackers.isEmpty {
                    self?.state.pinnedSection = nil
                }
                else {
                    self?.state.pinnedSection = .init(title: "Pinned", trackers: pinnedTrackers)
                }
                              
                self?.state.notPinnedSections = sectionsWithUnpinnedTrackers
            }
            .store(in: &cancellable)
        
        try? dataProvider.fetch()
//        try? pinnedDataProvider.fetch()
        //        pinnedDataProvider.pinnedTrackersPublisher
        //            .sink { [weak self] trackers in
        //                guard let self else {
        //                    return
        //                }
        //
        //                if trackers.isEmpty {
        //                    state.pinnedSection = nil
        //                }
        //                else {
        //                    state.pinnedSection = .init(title: "Pinned", trackers: trackers)
        //                }
        //            }
        //            .store(in: &cancellable)
    }
    
    func onAppear() {
        analyticsService.handleAnalitics(event: .screenOpen(.main))
    }
    
    func onDisappear() {
        analyticsService.handleAnalitics(event: .screenClose(.main))
    }
}

// MARK: - Нажатия

extension TrackersViewModel {
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
        
        trackerManager.saveAsCompleted(tracker: tracker, for: date)
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
}

// MARK: - Поиск по тексту и дате

extension TrackersViewModel {
    func onDateChanged(date: Date) {
        self.date = date
        
        handle(searchText: nil)
    }
    
    func onSearchTextChange(text: String) {
        handle(searchText: text)
    }
    
    private func handle(searchText: String?) {
        do {
            switch currentFilter.value {
            case .forCurrentWeekDay:
                // Work
                if let searchText {
                    try dataProvider.fetchTrackersWith(name: searchText, weekDay: weekDay)
                }
                else {
                    try dataProvider.fetchTrackersFor(weekDay: weekDay)
                }
                
            case .completedForDate:
                // Work
                if let searchText {
                    try dataProvider.fetchCompletedTrackersWith(name: searchText, date: date, weekDay: weekDay)
                }
                else {
                    try dataProvider.fetchCompletedTrackersFor(date: date, weekDay: weekDay)
                }
                
            case .uncompletedForDate:
                // Work
                if let searchText {
                    try dataProvider.fetchUncompletedTrackersWith(name: searchText, date: date, weekDay: weekDay)
                }
                else {
                    try dataProvider.fetchUncompletedTrackersFor(date: date, weekDay: weekDay)
                }
            }
        }
        catch {
            preconditionFailure("\(String(describing: self)) handle(searchText:)")
        }
    }
}

// MARK: - Routing

extension TrackersViewModel {
    func onFilterButton() {
        analyticsService.handleAnalitics(event: .filterItemClick(.main, .filter))
        
        router.showFiltersAssembly(filter: currentFilter.value)
            .sink { [weak self] in self?.currentFilter.value = $0 }
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
        
        router.showTrackerUpdatingFlow(tracker: tracker, date: date)
            .print(String(describing: TrackersViewModel.self))
            .sink { _ in }
            .store(in: &cancellable)
    }
}
