//
//  TrackerCollectionViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import Foundation
import TrackerDomain

protocol VideoCollectionViewModelProtocol: ObservableObject, Identifiable {
    var collection: TrackerSection { get }
}

final class TrackerCollectionViewModel: VideoCollectionViewModelProtocol {
    private let trackerRepository: TrackerRepositoryProtocol
    
    @Published private(set) var collection: TrackerSection
    
    init(
        trackerRepository: some TrackerRepositoryProtocol,
        collection: TrackerSection
    ) {
        self.trackerRepository = trackerRepository
        self.collection = collection
        
        let weekDay: String = "0, 1, 2, 3, 4, 5, 6"
        
        Task { @MainActor in
            let trackers: [Tracker]
            
            if collection.title == "Pinned" {
                trackers = try await trackerRepository.getAllTrackers(isPinned: true)
            }
            else {
                trackers = try await trackerRepository.getAllTrackersForCategory(category: collection.id, isPinned: false, weekDay: weekDay)
            }
            
            self.collection = collection.updatingTrackers(with: trackers)
        }
    }
}
