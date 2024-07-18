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
    private let resultObserver: PassthroughSubject<Destination, Never>
    
    private var destination: Destination =  .createTracker
    
    enum Destination {
        case createTracker
    }
    
    init(
        router: ChooseTrackerRouter,
        resultObserver: PassthroughSubject<Destination, Never>
    ) {
        self.router = router        
        self.resultObserver = resultObserver
    }
    
    func onCreateTracker() {
        resultObserver.send(destination)
    }
    
    deinit {
        print(String(describing: self))
    }
}
