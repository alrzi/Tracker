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
protocol TrackersViewModelProtocol: ObservableObject, TrackersNavigationState {
    associatedtype TrackersCollectionModel: TrackersCollectionViewModelProtocol
    
    var state: TrackersState<TrackersCollectionModel> { get }
    var queryString: String { get set }
    var currentDate: Date { get set }
    var filter: TrackerFilter { get set }
    var isToday: Bool { get }
    
    func onSectionAppear(at index: Int) async
    func onToday()
    func onAdd()
}

final class TrackersViewModel: TrackersViewModelProtocol {
    private let trackerManager: any TrackerManaging
    private let trackersViewModelsFactory: TrackersViewModelsFactory
    private let hapticManager: any VibrationFeedbackManaging
    private let calendar: Calendar = .autoupdatingCurrent
    
    private var observationTask: Task<(), Never>?
    private var cancellables: Set<AnyCancellable> = []
    private var fetchParameters: FetchParameters = .init(fetchLimit: 5, fetchOffset: 0)
    private let pinnedSectionID: UUID = .init()
    private var paginationState: LoadingState = .idle
    
    @Published private(set) var state: TrackersState<TrackersCollectionViewModel> = .idle
    
    @Published var filter: TrackerFilter = .forCurrentWeekDay
    @Published var queryString = ""
    @Published var currentDate: Date = .now
    
    @Published var route: TrackersRoute?
    
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
        
//        Task { @MainActor in
//            try await trackerManager.addSections(createSectionsWithTrackers())
//        }
        
        observationTask = Task { @MainActor in
            for await _ in trackerManager.observe(changes: [.deleted, .inserted, .updated]) {
                do {
                    let sections = try await fetchSections(isPaginating: false, params: updateParams)
                    
                    hapticManager.makeVibration(for: .success)
                    
                    if !sections.isEmpty {
                        state = .loaded(createModels(from: sections))
                    }
                    else {
                        state = .empty(.empty)
                    }
                }
                catch {
                    debugPrint(error)
                    state = .error
                }
            }
        }
    }
    
    func onToday() {
        currentDate = .now
    }
    
    func onAdd() {
        hapticManager.makeVibration(for: .selection)
        route = .create(onCompletion: { [weak self] _ in self?.route = nil })
    }
    
    func onSectionAppear(at index: Int) async {
        await paginateMoreSectionsIfNeeded(index: index)
    }
    
    deinit {
        observationTask?.cancel()
        observationTask = nil
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
                route = .update(tracker, onCompletion: { [weak self] _ in self?.route = nil })
            }
        }
    }
    
    // MARK: - Async
    
    func togglePin(for tracker: Tracker) async {
        do {
            try await trackerManager.update(tracker: tracker.toggleIsPinned())
        }
        catch {
            debugPrint(error)
        }
    }
    
    func delete(tracker: Tracker) async {
        do {
            try await trackerManager.delete(tracker: tracker)
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
            state = .error
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
            
            if !sections.isEmpty {
                state = .loaded(currentModels + createModels(from: sections))
                fetchParameters.nextPage()
            }
            
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
        trackers.isEmpty ? nil : .init(id: pinnedSectionID, title: R.string.localizable.mainPinned(), trackers: trackers)
    }
}

private extension TrackersViewModel {
    var commonParams: RequestParameters {
        .init(
            currentDate: currentDate,
            weekDay: .getWeekDay(from: currentDate),
            fetchLimit: fetchParameters.fetchLimit,
            fetchOffset: fetchParameters.fetchOffset,
            query: queryString
        )
    }
    
    var updateParams: RequestParameters {
        .init(
            currentDate: currentDate,
            weekDay: .getWeekDay(from: currentDate),
            fetchLimit: fetchParameters.fetchOffset,
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
