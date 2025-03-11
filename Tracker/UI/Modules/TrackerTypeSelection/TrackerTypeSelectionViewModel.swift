//
//  TrackerTypeSelectionViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Combine
import TrackerDomain

final class TrackerTypeSelectionViewModel {
    private let resultObserver: PassthroughSubject<Tracker.Kind, Never>
    
    init(
        resultObserver: PassthroughSubject<Tracker.Kind, Never>
    ) {
        self.resultObserver = resultObserver
    }
    
    func onCreateTracker(of kind: Tracker.Kind) {
        resultObserver.send(kind)
    }
    
    deinit {
        print(String(describing: self))
        resultObserver.send(completion: .finished)
    }
}
