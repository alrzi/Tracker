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
    @Published private(set) var collection: TrackerSection
    
    init(
        trackerManager: some TrackerManaging,
        collection: TrackerSection
    ) {
        self.collection = collection
    }
}
