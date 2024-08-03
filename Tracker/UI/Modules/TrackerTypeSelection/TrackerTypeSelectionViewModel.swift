//
//  TrackerTypeSelectionViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Combine

final class TrackerTypeSelectionViewModel {
    private let resultObserver: PassthroughSubject<TrackerKind, Never>
    
    init(
        resultObserver: PassthroughSubject<TrackerKind, Never>
    ) {
        self.resultObserver = resultObserver
    }
    
    func onCreateTracker(of kind: TrackerKind) {
        resultObserver.send(kind)
    }
    
    deinit {
        print(String(describing: self))
        resultObserver.send(completion: .finished)
    }
}
