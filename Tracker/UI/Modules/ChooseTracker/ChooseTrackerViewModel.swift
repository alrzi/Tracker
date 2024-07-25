//
//  ChooseTrackerViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Combine

final class ChooseTrackerViewModel {
    private let router: ChooseTrackerRouter
    
    private var cancellable: Set<AnyCancellable> = []
    private let resultObserver: PassthroughSubject<TrackerKind, Never>
    
    init(
        router: ChooseTrackerRouter,
        resultObserver: PassthroughSubject<TrackerKind, Never>
    ) {
        self.router = router        
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
