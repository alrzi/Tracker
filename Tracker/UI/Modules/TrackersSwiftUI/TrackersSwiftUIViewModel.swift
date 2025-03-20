//
//  TrackersSwiftUIViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import Foundation
import TrackerDomain
import Combine

@MainActor
protocol TrackersSwiftUIViewModelProtocol: ObservableObject {
    associatedtype TrackerCollectionModel: VideoCollectionViewModelProtocol
       
    var state: TrackersState<TrackerCollectionModel> { get }
    var queryString: String { get set }
    var currentDate: Date { get set }
    var filter: TrackerFilter { get set }
    var isPaginating: Bool { get }
    
    func onSectionAppear(at index: Int)
}

final class TrackersSwiftUIViewModel: TrackersSwiftUIViewModelProtocol {
    private let trackerManager: any TrackerManaging
    private let trackerRepository: any TrackerRepositoryProtocol
    private let recordRepository: any RecordRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    private var stateUpdateTask: Task<Void, Error>?
    
    private var fetchParameters: FetchParameters = .init(fetchLimit: 4, fetchOffset: 0)
    
    @Published private(set) var state: TrackersState<TrackerCollectionViewModel> = .idle
    @Published private(set) var updateState: LoadingState = .idle
    @Published private(set) var isPaginating = false
    
    @Published var filter: TrackerFilter = .forCurrentWeekDay
    @Published var queryString = ""
    @Published var currentDate: Date = .now
    
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
            .handleEvents(receiveOutput: { _ in self.fetchParameters.reset() })
            .sink { [weak self] _ in self?.onQueryTrigger() }
            .store(in: &cancellables)
        
        $filter
            .removeDuplicates()
            .combineLatest($currentDate)
            .handleEvents(receiveOutput: { _ in self.fetchParameters.reset() })
            .sink { [weak self] _, _ in self?.onFilterOrDateTrigger() }
            .store(in: &cancellables)
        
        $updateState
            .map { $0.isLoading }
            .assign(to: &$isPaginating)
        
//        stateUpdateTask = Task { @MainActor in
//            let sections = createSectionsWithTrackers(sectionCount: 80, trackerCount: 4)
//            try await trackerManager.addSections(sections)
//        }
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

private extension TrackersSwiftUIViewModel {
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
            
            await fetchSection()
        }
        catch {
            debugPrint(error)
        }
    }
    
    func fetchSection() async {
        do {
            let sections = try await fetchSections(isPaginating: false)
            
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
            let sections = try await fetchSections(isPaginating: true)
                        
            fetchParameters.nextPage()
            
            updateState = .idle
            state = .loaded(currentModels + createModel(from: sections))
        }
        catch {
            updateState = .error(.paginationError)
            debugPrint(error)
        }
    }
    
    func fetchSections(isPaginating: Bool) async throws -> [TrackerSection] {
        var (sections, pinnedTrackers): ([TrackerSection], [Tracker]) = ([], [])
        
        let params: RequestParameters = .init(
            currentDate: currentDate,
            weekDay: currentDate.weekDayString,
            fetchLimit: fetchParameters.fetchLimit,
            fetchOffset: fetchParameters.fetchOffset,
            query: queryString
        )
        
        switch filter {
        case .forCurrentWeekDay:
            (sections, pinnedTrackers) = try await trackerManager.fetchSections(params: params, isPaginating: isPaginating)
            
        case .completedForDate:
            (sections, pinnedTrackers) = try await trackerManager.fetchCompletedSections(params: params, isPaginating: isPaginating)
        
        case .uncompletedForDate:
            break
        
        case .forToday:
            break
        }
        
        if !isPaginating {
            if let pinned = createPinnedModel(from: pinnedTrackers) {
                sections.insert(pinned, at: 0)
            }
        }
        
        return sections
    }
    
    // MARK: - Sync
    
    func createModel(from sections: [TrackerSection]) -> [TrackerCollectionViewModel] {
        sections.map {
            TrackerCollectionViewModel(
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

private extension TrackerFilter {
    var isCompleted: Bool {
        switch self {
        case
            .forCurrentWeekDay,
            .uncompletedForDate,
            .forToday:
            false
            
        case .completedForDate:
            true
        }
    }
}
