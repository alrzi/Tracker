//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Combine
import Foundation
import TrackerDomain

@MainActor
final class TrackersViewModel {
    private let trackerFiltersDataStorage: TrackerFiltersDataStorage
    private let analyticsTracker: AnalyticsTracking
    private let trackerManager: any TrackerManaging
    private let router: TrackersViewRouter
    
    private var cancellable: Set<AnyCancellable> = []
    
    private var currentFilter: CurrentValueSubject<TrackerFilters, Never>
    private var date: Date = .now
    private var weekDay: String { date.weekDayString }
    
    @Published private(set) var state: TrackersCollectionCellState = .empty
    
    private var stateUpdateTask: Task<Void, Error>?
    private var stateUpdateSectionsTask: Task<Void, Error>?
    
    init(
        trackerFiltersDataStorage: TrackerFiltersDataStorage,
        analyticsTracker: AnalyticsTracking,
        trackerManager: some TrackerManaging,
        router: TrackersViewRouter
    ) {
        self.trackerFiltersDataStorage = trackerFiltersDataStorage
        self.analyticsTracker = analyticsTracker
        self.trackerManager = trackerManager
        self.router = router
        self.currentFilter = .init(trackerFiltersDataStorage.trackerFilters)
        
        currentFilter
            .sink { [weak self] _ in self?.handle(searchText: nil) }
            .store(in: &cancellable)
        
        stateUpdateTask = Task {
            try await trackerManager.fetchAllSectionedTrackers()
            
            for try await section in trackerManager.sections {
                state.trackerSections = section
            }
        }
        
//        Task {
//            await trackerManager.addSections(mockTrackerSections)
//            
//            for i in createMockTrackerRecords() {
//                try await trackerManager.toggleIsCompleted(for: i.id, for: i.date)
//            }
//        }
    }
    
    func onAppear() {
        analyticsTracker.track(event: TrackType.trackers(event: .onAppear))
//        analyticsTracker.track(event: .trackers(event: .onAppear))
    }
    
    deinit {
        stateUpdateTask?.cancel()
        stateUpdateSectionsTask?.cancel()
    }
}

// MARK: - Нажатия

extension TrackersViewModel {
    func onPinTracker(at indexPath: IndexPath) async {
        guard let tracker = state.item(at: indexPath) else {
            return
        }
        
        analyticsTracker.track(event: TrackType.trackers(event: .action(.onTrackerPin)))
        
        do {
            try await trackerManager.togglePin(for: tracker)
        }
        catch {
            preconditionFailure("\(String(describing: self)) onPinTracker(at indexPath: \(indexPath)")
        }
    }
    
    func onUnPinTracker(at indexPath: IndexPath) async {
        guard let tracker = state.item(at: indexPath) else {
            return
        }
        
        analyticsTracker.track(event: TrackType.trackers(event: .action(.onTrackerPin)))
        
        do {
            try await trackerManager.togglePin(for: tracker)
        }
        catch {
            preconditionFailure("\(String(describing: self)) onUnPinTracker(at indexPath: \(indexPath)")
        }
    }
    
    func onTrackerMarkCompleted(at indexPath: IndexPath) async {
        guard let tracker = state.item(at: indexPath) else {
            return
        }
        
        do {
            try await trackerManager.toggle(record: .init(id: tracker.id, date: .now))
        }
        catch {
            debugPrint(error)
        }
    }
    
    func onDeleteTracker(at indexPath: IndexPath) async {
        guard let tracker = state.item(at: indexPath) else {
            return
        }
        
        analyticsTracker.track(event: TrackType.trackers(event: .action(.onTrackerDelete)))
        
        do {
            try await trackerManager.delete(tracker: tracker)
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
//        do {
//            switch currentFilter.value {
//            case .forCurrentWeekDay:
//            case .completedForDate:
//            case .uncompletedForDate:
//            }
//        }
//        catch {
//            preconditionFailure("\(String(describing: self)) handle(searchText:)")
//        }
    }
}

// MARK: - Routing

extension TrackersViewModel {
    func onFilterButton() {
        analyticsTracker.track(event: TrackType.trackers(event: .action(.onChooseFilter)))
        
        router.showFiltersAssembly(filter: currentFilter.value)
            .sink { [weak self] in self?.updateCurrentFilter($0) }
            .store(in: &cancellable)
    }
            
    func onCreateTracker() {
        analyticsTracker.track(event: TrackType.trackers(event: .action(.onAddTracker)))
        
        router.showTrackerUpdatingFlow()
            .print(String(describing: TrackersViewModel.self))
            .sink { _ in }
            .store(in: &cancellable)
    }
    
    func onUpdateTracker(at index: IndexPath) {
        guard let tracker = state.item(at: index) else {
            return
        }
        
        analyticsTracker.track(event: TrackType.trackers(event: .action(.onTrackerEdit)))
        
        router.showTrackerUpdatingFlow(tracker: tracker, date: date)
            .print(String(describing: TrackersViewModel.self))
            .sink { _ in }
            .store(in: &cancellable)
    }
    
    private func updateCurrentFilter(_ filter: TrackerFilters) {
        currentFilter.value = filter
        trackerFiltersDataStorage.trackerFilters = filter
    }
}
