//
//  TrackersViewModelsFactory.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation
import TrackerDomain

final class TrackersViewModelsFactory {
    private let trackerManager: any TrackerManaging
    private let trackerRepository: any TrackerRepositoryProtocol
    private let recordRepository: any RecordRepositoryProtocol
    private let hapticManager: any VibrationFeedbackManaging
    
    init(
        trackerManager: some TrackerManaging,
        trackerRepository: some TrackerRepositoryProtocol,
        recordRepository: some RecordRepositoryProtocol,
        hapticManager: some VibrationFeedbackManaging
    ) {
        self.trackerManager = trackerManager
        self.trackerRepository = trackerRepository
        self.recordRepository = recordRepository
        self.hapticManager = hapticManager
    }
    
    @MainActor
    func createTrackersCollectionViewModel(
        collection: TrackerSection,
        currentDate: Date,
        eventsHandler: @escaping (TrackersCollectionOutput) -> Void
    ) -> TrackersCollectionViewModel {
        TrackersCollectionViewModel(
            trackerRepository: trackerRepository,
            recordRepository: recordRepository,
            trackerManager: trackerManager,
            hapticManager: hapticManager,
            collection: collection,
            currentDate: currentDate,
            eventsHandler: eventsHandler
        )
    }
}
