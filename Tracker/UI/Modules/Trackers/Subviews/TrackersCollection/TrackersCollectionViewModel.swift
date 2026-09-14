//
//  TrackersCollectionViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import Foundation
import TrackerDomain
import HapticFeedback

@MainActor
protocol TrackersCollectionViewModelProtocol: ObservableObject, Identifiable {
    var title: String { get }
    var trackers: [Tracker] { get }
    var allowsTrackerDrop: Bool { get }
    
    var deleteTrackerConfirmationAlert: ErrorInfo? { get }
    var isDeleteTrackerConfirmationAlertPresented: Bool { get set }
    var isCompletionConfirmationAlertPresented: Bool { get set }
    
    func onToggleCompletion(at index: Int)
    func tracker(at index: Int) -> Tracker?
    func onDelete(at index: Int)
    func confirmDelete() -> Tracker?
    func moveOutput(trackerID: UUID) -> TrackersCollectionOutput?
}

final class TrackersCollectionViewModel: TrackersCollectionViewModelProtocol {
    private let trackerRepository: any TrackerRepositoryProtocol
    private let recordRepository: any RecordRepositoryProtocol
    private let trackerManager: any TrackerManaging
    private let hapticManager: any VibrationFeedbackManaging
    private let currentDate: Date
    
    private var trackerPendingDeletion: Tracker?
    
    @Published private(set) var trackers: [Tracker]
    @Published private(set) var completionState: LoadingState = .idle
    
    @Published private(set) var deleteTrackerConfirmationAlert: ErrorInfo?
    @Published var isDeleteTrackerConfirmationAlertPresented = false
    @Published var isCompletionConfirmationAlertPresented = false
    
    nonisolated let id: UUID
    let title: String
    let allowsTrackerDrop: Bool
    
    init(
        trackerRepository: some TrackerRepositoryProtocol,
        recordRepository: some RecordRepositoryProtocol,
        trackerManager: some TrackerManaging,
        hapticManager: some VibrationFeedbackManaging,
        collection: TrackerSection,
        allowsTrackerDrop: Bool,
        currentDate: Date
    ) {
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
        self.trackerManager = trackerManager
        self.hapticManager = hapticManager
        self.currentDate = currentDate
        self.id = collection.id
        self.title = collection.title
        self.allowsTrackerDrop = allowsTrackerDrop
        self.trackers = collection.trackers
        
        $deleteTrackerConfirmationAlert
            .map { $0 != nil }
            .assign(to: &$isDeleteTrackerConfirmationAlertPresented)
        
        $completionState
            .map { $0.isError }
            .assign(to: &$isCompletionConfirmationAlertPresented)
    }
    
    func onToggleCompletion(at index: Int) {
        Task {
            await updateTrackerCompletion(at: index)
        }
    }
    
    func tracker(at index: Int) -> Tracker? {
        trackers.elementOrNil(at: index)
    }
    
    func onDelete(at index: Int) {
        guard let tracker = trackers.elementOrNil(at: index) else {
            return
        }
        
        trackerPendingDeletion = tracker
        deleteTrackerConfirmationAlert = .deleteTrackerConfirmationAlert
    }

    func confirmDelete() -> Tracker? {
        defer { trackerPendingDeletion = nil }
        return trackerPendingDeletion
    }

    func moveOutput(trackerID: UUID) -> TrackersCollectionOutput? {
        guard allowsTrackerDrop else {
            return nil
        }

        return .move(trackerID: trackerID, toSectionID: id)
    }
}

private extension TrackersCollectionViewModel {
    func updateTrackerCompletion(at index: Int) async {
        guard let tracker = trackers.elementOrNil(at: index) else {
            return
        }
        
        guard !completionState.isLoading else {
            return
        }
        
        completionState = .loading
        
        do {
            try await recordRepository.createOrDeleteIfPresent(record: .init(id: tracker.id, date: currentDate))
            
            let trackedDays = try await recordRepository.getTrackedDaysFor(id: tracker.id)
            let isCompleted = try await recordRepository.isCompletedFor(selectedDay: currentDate, trackerWithId: tracker.id)
            
            let updated = tracker.with(isCompleted: isCompleted, trackedDays: trackedDays)
            
            try await trackerRepository.updateTracker(updated)
            
            hapticManager.makeVibration(for: .selection)
            
            completionState = .idle
        }
        catch {
            debugPrint(error)
            completionState = .error(.completionError)
        }
    }
}

private extension ErrorInfo {
    static var completionError: Self {
        .init(
            message: "Мы проверим что случилось, отдохните чуть-чуть и попробуйте еще раз",
            cancelButtonText: "",
            confirmationButtonText: "Ок",
            onConfirm: { }
        )
    }
    
    static var deleteTrackerConfirmationAlert: Self {
        .init(
            message: String(localized: .alertConfirmationTracker),
            cancelButtonText: String(localized: .alertCancel),
            confirmationButtonText: String(localized: .alertDelete),
            onConfirm: { }
        )
    }
}
