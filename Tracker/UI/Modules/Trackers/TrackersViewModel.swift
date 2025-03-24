//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import Foundation
import TrackerDomain
import Combine

@MainActor
protocol TrackersViewModelProtocol: ObservableObject {
    associatedtype TrackersCollectionModel: TrackersCollectionViewModelProtocol
    
    var state: TrackersState<TrackersCollectionModel> { get }
    var queryString: String { get set }
    var currentDate: Date { get set }
    var filter: TrackerFilter { get set }
    var isPaginating: Bool { get }
    var isToday: Bool { get }
    
    func onSectionAppear(at index: Int)
    func onToday()
}

final class TrackersViewModel: TrackersViewModelProtocol {
    private let trackerManager: any TrackerManaging
    private let trackersViewModelsFactory: TrackersViewModelsFactory
    private let hapticManager: any VibrationFeedbackManaging
    private let calendar: Calendar = .autoupdatingCurrent
    
    private var cancellables: Set<AnyCancellable> = []
    private var fetchParameters: FetchParameters = .init(fetchLimit: 4, fetchOffset: 0)
    
    @Published private(set) var state: TrackersState<TrackersCollectionViewModel> = .idle
    @Published private(set) var paginationState: LoadingState = .idle
    @Published private(set) var isPaginating = false
    
    @Published var filter: TrackerFilter = .forCurrentWeekDay
    @Published var queryString = ""
    @Published var currentDate: Date = .now
    
    var isToday: Bool { calendar.isDateInToday(currentDate) }
    
    init(
        trackerManager: some TrackerManaging,
        hapticManager: some VibrationFeedbackManaging,
        trackersViewModelsFactory: TrackersViewModelsFactory
    ) {
        self.trackerManager = trackerManager
        self.hapticManager = hapticManager
        self.trackersViewModelsFactory = trackersViewModelsFactory
        
        $queryString
            .dropFirst()
            .handleEvents(receiveOutput: { [weak self] _ in self?.fetchParameters.reset() })
            .sink { [weak self] _ in self?.onQueryTrigger() }
            .store(in: &cancellables)
        
        $filter
            .removeDuplicates()
            .combineLatest($currentDate.removeDuplicates())
            .handleEvents(receiveOutput: { [hapticManager] _ in hapticManager.makeVibration(for: .selection) })
            .handleEvents(receiveOutput: { [weak self] _ in self?.fetchParameters.reset() })
            .sink { [weak self] _, _ in self?.onFilterOrDateTrigger() }
            .store(in: &cancellables)            
        
        $paginationState
            .map { $0.isLoading }
            .assign(to: &$isPaginating)
        
        //        Task { @MainActor in
        //            let sections = createSectionsWithTrackers(sectionCount: 80, trackerCount: 4)
        //            try await trackerManager.addSections(sections)
        //        }
    }
    
    func onToday() {
        currentDate = .now
    }
    
    func onSectionAppear(at index: Int) {
        Task {
            await paginateMoreSectionsIfNeeded(index: index)
        }
    }
}

// MARK: - Private

private extension TrackersViewModel {
    // MARK: - Triggers
    
    func onQueryTrigger() {
        Task {
            await fetchSections(isSearch: true)
        }
    }
    
    func onFilterOrDateTrigger() {
        Task {
            await fetchSections(isSearch: false)
        }
    }
    
    func handleTrackerItem(events: TrackersCollectionOutput) {
        Task {
            switch events {
            case .togglePin(let tracker):
                await togglePin(for: tracker)
                
            case .delete(let tracker):
                await delete(tracker: tracker)
                
            case .edit(let tracker):
                break
            }
        }
    }
    
    // MARK: - Async
    
    func togglePin(for tracker: Tracker) async {
        do {
            try await trackerManager.update(tracker: tracker.toggleIsPinned())
            
            let sections = try await fetchSections(isPaginating: false, params: amountSensitiveParams)
            
            state = .loaded(createModels(from: sections))
            
            hapticManager.makeVibration(for: .success)
        }
        catch {
            debugPrint(error)
        }
    }
    
    func delete(tracker: Tracker) async {
        do {
            try await trackerManager.delete(tracker: tracker)
            
            let sections = try await fetchSections(isPaginating: false, params: amountSensitiveParams)
            
            if !sections.isEmpty {
                state = .loaded(createModels(from: sections))
            }
            else {
                state = .empty(.empty)
            }
        }
        catch {
            debugPrint(error)
        }
    }
    
    func fetchSections(isSearch: Bool) async {
        do {
            let sections = try await fetchSections(isPaginating: false, params: commonParams)
            
            if !sections.isEmpty {
                state = .loaded(createModels(from: sections))
                fetchParameters.nextPage()
            }
            else {
                state = .empty(isSearch || !queryString.isEmpty ? .emptySearch : .empty)
            }
        }
        catch {
            debugPrint(error)
        }
    }
    
    func paginateMoreSectionsIfNeeded(index: Int) async {
        guard index == state.lastElementIndex else {
            return
        }
        
        guard case .loaded(let currentModels) = state, !paginationState.isLoading else {
            return
        }
        
        paginationState = .loading
        
        do {
            let sections = try await fetchSections(isPaginating: true, params: commonParams)
            
            fetchParameters.nextPage()
                        
            state = .loaded(currentModels + createModels(from: sections))
            
            paginationState = .idle
        }
        catch {
            debugPrint(error)
            paginationState = .error(.paginationError)
        }
    }
    
    func fetchSections(isPaginating: Bool, params: RequestParameters) async throws -> [TrackerSection] {
        var (sections, pinnedTrackers): ([TrackerSection], [Tracker]) = ([], [])
        
        switch filter {
        case .forCurrentWeekDay:
            (sections, pinnedTrackers) = try await trackerManager.fetchSections(params: params, isPaginating: isPaginating)
            
        case .completedForDate:
            (sections, pinnedTrackers) = try await trackerManager.fetchCompletedSections(params: params, isPaginating: isPaginating)
            
        case .uncompletedForDate:
            (sections, pinnedTrackers) = try await trackerManager.fetchUnCompletedSections(params: params, isPaginating: isPaginating)
        }
        
        if !isPaginating {
            if let pinned = createPinnedModel(from: pinnedTrackers) {
                sections.insert(pinned, at: 0)
            }
        }
        
        return sections
    }
    
    // MARK: - Sync
    
    func createModels(from sections: [TrackerSection]) -> [TrackersCollectionViewModel] {
        sections.map {
            trackersViewModelsFactory.createTrackersCollectionViewModel(
                collection: $0,
                currentDate: currentDate,
                eventsHandler: { [weak self] in self?.handleTrackerItem(events: $0) }
            )
        }
    }
    
    func createPinnedModel(from trackers: [Tracker]) -> TrackerSection? {
        trackers.isEmpty ? nil : .init(title: R.string.localizable.mainPinned(), trackers: trackers)
    }
}

private extension TrackersViewModel {
    var commonParams: RequestParameters {
        .init(
            currentDate: currentDate,
            weekDay: currentDate.weekDayString,
            fetchLimit: fetchParameters.fetchLimit,
            fetchOffset: fetchParameters.fetchOffset,
            query: queryString
        )
    }
    
    var amountSensitiveParams: RequestParameters {
        .init(
            currentDate: currentDate,
            weekDay: currentDate.weekDayString,
            fetchLimit: state.count + 1,
            fetchOffset: .zero,
            query: queryString
        )
    }
}

private extension ErrorInfo {
    static var paginationError: Self {
        .init(
            message: "Мы проверим что случилось, отдохните чуть-чуть и попробуйте еще раз",
            cancelButtonText: "",
            confirmationButtonText: "Ок",
            onConfirm: { }
        )
    }
}
