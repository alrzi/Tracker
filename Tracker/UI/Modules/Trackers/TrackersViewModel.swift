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
    private let trackerRepository: any TrackerRepositoryProtocol
    private let recordRepository: any RecordRepositoryProtocol
    private let calendar: Calendar = .autoupdatingCurrent
    
    private var cancellables: Set<AnyCancellable> = []
    private var stateUpdateTask: Task<Void, Error>?
    
    private var fetchParameters: FetchParameters = .init(fetchLimit: 4, fetchOffset: 0)
    
    @Published private(set) var state: TrackersState<TrackersCollectionViewModel> = .idle
    @Published private(set) var updateState: LoadingState = .idle
    @Published private(set) var isPaginating = false
    
    @Published var filter: TrackerFilter = .forCurrentWeekDay
    @Published var queryString = ""
    @Published var currentDate: Date = .now
    
    var isToday: Bool { calendar.isDateInToday(currentDate) }
    
    init(
        trackerManager: some TrackerManaging,
        trackerRepository: some TrackerRepositoryProtocol,
        recordRepository: some RecordRepositoryProtocol
    ) {
        self.trackerRepository = trackerRepository
        self.trackerManager = trackerManager
        self.recordRepository = recordRepository
        
        $queryString            
            .dropFirst()
            .handleEvents(receiveOutput: { [weak self] _ in self?.fetchParameters.reset() })
            .sink { [weak self] _ in self?.onQueryTrigger() }
            .store(in: &cancellables)
        
        $filter
            .removeDuplicates()
            .combineLatest($currentDate.removeDuplicates())
            .handleEvents(receiveOutput: { [weak self] _ in self?.fetchParameters.reset() })
            .sink { [weak self] _, _ in
                self?.onFilterOrDateTrigger()
                print("Called")
            }
            .store(in: &cancellables)
        
        $updateState
            .map { $0.isLoading }
            .assign(to: &$isPaginating)
        
//        stateUpdateTask = Task { @MainActor in
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
    
    deinit {
        stateUpdateTask?.cancel()
    }
}

// MARK: - Private

private extension TrackersViewModel {
    // MARK: - Triggers
    
    func onQueryTrigger() {
        Task {
            await fetchSection()
        }
    }
    
    func onFilterOrDateTrigger() {
        Task {
            await fetchSection()
        }
    }
    
    func onTogglePinTrigger(_ tracker: Tracker) {
        Task {
            await togglePin(for: tracker)
        }
    }
    
    // MARK: - Async
    
    func togglePin(for tracker: Tracker) async {
        do {
            try await trackerManager.update(tracker: tracker.toggleIsPinned())
            
            let sections = try await fetchSections(isPaginating: false, params: togglePinParams)
            
            state = .loaded(createModel(from: sections))
        }
        catch {
            debugPrint(error)
        }
    }
    
    func fetchSection() async {
        do {
            let sections = try await fetchSections(isPaginating: false, params: commonParams)
            
            state = .loaded(createModel(from: sections))
            
            fetchParameters.nextPage()
        }
        catch {
            debugPrint(error)
        }
    }
    
    func paginateMoreSectionsIfNeeded(index: Int) async {
        guard index == state.lastElementIndex else {
            return
        }
        
        guard case .loaded(let currentModels) = state, !updateState.isLoading else {
            return
        }
        
        updateState = .loading
        
        do {
            let sections = try await fetchSections(isPaginating: true, params: commonParams)
                        
            fetchParameters.nextPage()
            
            updateState = .idle
            state = .loaded(currentModels + createModel(from: sections))
        }
        catch {
            updateState = .error(.paginationError)
            debugPrint(error)
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
    
    func createModel(from sections: [TrackerSection]) -> [TrackersCollectionViewModel] {
        sections.map {
            TrackersCollectionViewModel(
                trackerRepository: trackerRepository,
                recordRepository: recordRepository,
                trackerManager: trackerManager,
                collection: $0,
                currentDate: currentDate,
                eventsHandler: { [weak self] in self?.onTogglePinTrigger($0) }
            )
        }
    }
    
    func createPinnedModel(from trackers: [Tracker]) -> TrackerSection? {
        if !trackers.isEmpty {
            .init(id: .init(), title: "Pinned", trackers: trackers)
        }
        else {
            nil
        }
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
    
    var togglePinParams: RequestParameters {
        .init(
            currentDate: currentDate,
            weekDay: currentDate.weekDayString,
            fetchLimit: state.lastElementIndex,
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
