//
//  TrackersSwiftUIViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.03.2025.
//

import Foundation
import TrackerDomain

protocol TrackersSwiftUIViewModelProtocol: ObservableObject {
    associatedtype TrackerCollectionModel: VideoCollectionViewModelProtocol
    
    var collectionViewModel: [TrackerCollectionModel] { get }
}

final class TrackersSwiftUIViewModel: TrackersSwiftUIViewModelProtocol {
    private let trackerManager: any TrackerManaging
    private let trackerRepository: any TrackerRepositoryProtocol
    
    private var stateUpdateTask: Task<Void, Error>?
    
    @Published private(set) var collectionViewModel: [TrackerCollectionViewModel] = []
    
    init(
        trackerManager: some TrackerManaging,
        trackerRepository: some TrackerRepositoryProtocol
    ) {
        self.trackerRepository = trackerRepository
        self.trackerManager = trackerManager
        
        let (sections, records) = createSectionsWithTrackers(sectionCount: 40, trackerCount: 10)
        
        stateUpdateTask = Task { @MainActor in
//            try await trackerManager.addSections(sections)
//            
//            for record in records {
//                try await trackerManager.toggle(record: record)
//            }
            
            try await trackerManager.fetchAllSectionedTrackers()
            
            for try await sections in trackerManager.sections {
                let models = sections.map { TrackerCollectionViewModel(trackerRepository: trackerRepository, collection: $0) }
                collectionViewModel = models
            }
        }
    }
    
    deinit {
        stateUpdateTask?.cancel()
    }
}
