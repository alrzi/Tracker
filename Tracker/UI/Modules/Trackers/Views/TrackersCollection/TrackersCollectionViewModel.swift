//
//  TrackersCollectionViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import Foundation
import TrackerDomain

@MainActor
protocol TrackersCollectionViewModelProtocol: ObservableObject, Identifiable {
    var id: UUID { get }
    var title: String { get }
    var trackers: [Tracker] { get }
    
    var deleteTrackerConfirmationAlert: ErrorInfo? { get }
    var isDeleteTrackerConfirmationAlertPresented: Bool { get set }
    var isCompletionConfirmationAlertPresented: Bool { get set }
    
    func onToggleCompletion(at index: Int)
    func onTogglePin(at index: Int)
    func onEdit(at index: Int)
    func onDelete(at index: Int)    
}

final class TrackersCollectionViewModel: TrackersCollectionViewModelProtocol {
    private let trackerRepository: any TrackerRepositoryProtocol
    private let recordRepository: any RecordRepositoryProtocol
    private let trackerManager: any TrackerManaging
    private let hapticManager: any VibrationFeedbackManaging
    private let currentDate: Date
    
    private let eventsHandler: (TrackersCollectionOutput) -> Void
        
    @Published private(set) var trackers: [Tracker]
    @Published private(set) var completionState: LoadingState = .idle
    
    @Published private(set) var deleteTrackerConfirmationAlert: ErrorInfo?
    @Published var isDeleteTrackerConfirmationAlertPresented = false
    @Published var isCompletionConfirmationAlertPresented = false
        
    let id: UUID
    let title: String
    
    init(
        trackerRepository: some TrackerRepositoryProtocol,
        recordRepository: some RecordRepositoryProtocol,
        trackerManager: some TrackerManaging,
        hapticManager: some VibrationFeedbackManaging,
        collection: TrackerSection,
        currentDate: Date,
        eventsHandler: @escaping (TrackersCollectionOutput) -> Void
    ) {
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
        self.trackerManager = trackerManager
        self.hapticManager = hapticManager
        self.currentDate = currentDate
        self.id = collection.id
        self.title = collection.title
        self.trackers = collection.trackers
        self.eventsHandler = eventsHandler
        
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
    
    func onTogglePin(at index: Int) {
        guard let tracker = trackers.elementOrNil(at: index) else {
            return
        }
        
        eventsHandler(.togglePin(tracker))
    }
    
    func onEdit(at index: Int) {
        guard let tracker = trackers.elementOrNil(at: index) else {
            return
        }
        
        eventsHandler(.edit(tracker))
    }
    
    func onDelete(at index: Int) {
        guard let tracker = trackers.elementOrNil(at: index) else {
            return
        }
        
        deleteTrackerConfirmationAlert = .deleteTrackerConfirmationAlert { [eventsHandler] in eventsHandler(.delete(tracker)) }
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
            
            trackers[index] = updated
            
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
    
    static func deleteTrackerConfirmationAlert(onConfirm: @escaping () -> Void) -> Self {
        .init(
            message: "Уверены что хотите удалить трекер?",
            cancelButtonText: "Нет",
            confirmationButtonText: "Да",
            onConfirm: onConfirm
        )
    }
}
