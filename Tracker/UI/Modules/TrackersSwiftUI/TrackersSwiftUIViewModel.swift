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
            .combineLatest($currentDate)
            .sink { [weak self, fetchParameters] query, date in
                Task {
                    await self?.fetchSection(with: query, for: date.weekDayString, params: fetchParameters)
                }
            }
            .store(in: &cancellables)
        
        $filter
            .combineLatest($currentDate.map(\.weekDayString))
            .handleEvents(receiveOutput: { _ in self.fetchParameters.reset() })
            .sink { [weak self, fetchParameters] filter, weekDay in
                Task {
                    await self?.fetchSection(with: "", for: weekDay, params: fetchParameters)
                }
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
    func createModel(from sections: [TrackerSection]) -> [TrackerCollectionViewModel] {
        sections.map {
            TrackerCollectionViewModel(
                trackerRepository: trackerRepository,
                recordRepository: recordRepository,
                trackerManager: trackerManager,
                collection: $0,
                currentDate: currentDate,
                eventsHandler: { [weak self] tracker in
                    Task {
                        await self?.togglePin(for: tracker)
                    }
                }
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
    
    func togglePin(for tracker: Tracker) async {
        do {
            try await trackerManager.update(tracker: tracker.toggleIsPinned())
            
            await fetchSection(
                with: "",
                for: currentDate.weekDayString,
                params: .init(fetchLimit: state.lastElementIndex, fetchOffset: .zero)
            )
        }
        catch {
            debugPrint(error)
        }
    }
    
    func fetchSection(with query: String, for weekDay: String, params: FetchParameters) async {
        do {
            var (sections, pinnedTrackers) = try await trackerManager.fetchSections(
                with: query,
                for: weekDay,
                fetchLimit: params.fetchLimit,
                fetchOffset: params.fetchOffset,
                currentDate: currentDate
            )
            
            if let pinned = createPinnedModel(from: pinnedTrackers) {
                sections.insert(pinned, at: 0)
            }
            
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
            let sections = try await trackerManager.fetchSectionsNextPage(
                for: queryString,
                for: currentDate.weekDayString,
                fetchLimit: fetchParameters.fetchLimit,
                fetchOffset: fetchParameters.fetchOffset,
                currentDate: currentDate
            )
            
            if sections.isEmpty {
                updateState = .idle
                
                return
            }
            
            fetchParameters.nextPage()
            
            updateState = .idle
            state = .loaded(currentModels + createModel(from: sections))
        }
        catch {
            updateState = .error(.paginationError)
            debugPrint(error)
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

struct RequestParameters {
    let weekDay: String
    let filter: TrackerFilter
    let params: FetchParameters
}

enum FetchType {
    case basic(RequestParameters)
    case withQuery(RequestParameters, query: String)
}
