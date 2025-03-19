//
//  TrackerCollectionViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import Foundation
import TrackerDomain

@MainActor
protocol VideoCollectionViewModelProtocol: ObservableObject, Identifiable {
    var id: UUID { get }
    var title: String { get }
    var trackers: [Tracker] { get }    
    
    func onToggleCompletion(at index: Int)
    func onTogglePin(at index: Int)
    func onEdit(at index: Int)
    func onDelete(at index: Int)    
}

final class TrackerCollectionViewModel: VideoCollectionViewModelProtocol {
    private let trackerRepository: any TrackerRepositoryProtocol
    private let recordRepository: any RecordRepositoryProtocol
    private let trackerManager: any TrackerManaging
    
    private let eventsHandler: (Tracker) -> Void
        
    @Published var trackers: [Tracker]
        
    let id: UUID
    let title: String
    
    init(
        trackerRepository: some TrackerRepositoryProtocol,
        recordRepository: some RecordRepositoryProtocol,
        trackerManager: some TrackerManaging,
        collection: TrackerSection,
        currentDate: Date,
        eventsHandler: @escaping (Tracker) -> Void
    ) {
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
        self.trackerManager = trackerManager
        self.id = collection.id
        self.title = collection.title
        self.trackers = collection.trackers
        self.eventsHandler = eventsHandler
    }
    
    func onToggleCompletion(at index: Int) {
        Task {
            await updateTrackerCompletion(at: index)
        }
    }
    
    func onTogglePin(at index: Int) {
        guard let tracker = trackers.elementOrNil(at: index) else {
            return
        }
        
        eventsHandler(tracker)
    }
    
    func onEdit(at index: Int) {
        
    }
    
    func onDelete(at index: Int) {
        
    }
    
    deinit {
        print("deinit")
    }
}

private extension TrackerCollectionViewModel {
    func updateTrackerCompletion(at index: Int) async {
        guard let tracker = trackers.elementOrNil(at: index) else {
            return
        }
        
        do {
            try await recordRepository.createOrDeleteIfPresent(record: .init(id: tracker.id, date: .now))
            
            let trackedDays = try await recordRepository.getTrackedDaysFor(id: tracker.id)
            let isCompleted = try await recordRepository.isCompletedFor(selectedDay: .now, trackerWithId: tracker.id)
            
            let updated = tracker.with(isCompleted: isCompleted, trackedDays: trackedDays)
            
            try await trackerRepository.updateTracker(updated)
            
            trackers[index] = updated
        }
        catch {
            debugPrint(error)
        }
    }
}
