//
//  TabBarViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 07.07.2024.
//

import Foundation
import Combine

final class TabBarViewModel {
    private let router: TabBarViewRouter
    
    private let sections: [TabBarSection] = [.trackers, .statistics]
    private let section = CurrentValueSubject<TabBarSection, Never>(.trackers)
    
    @Published private(set) var tabIndex: Int = .zero
    
    init(router: TabBarViewRouter) {
        self.router = router
        
        section
            .map { [sections] in sections.firstIndex(of: $0) }
            .compactMap { $0 }
            .assign(to: &$tabIndex)
    }
    
    @MainActor
    func viewWillAppear() {
        router.setupViewControllers(for: sections)
    }
    
    func viewDidAppear() { }
    
    func onTabIndexSelected(_ index: Int) {
        guard let newSection = sections.elementOrNil(at: index) else {
            return
        }
        
        guard section.value != newSection else {
            return
        }
                
        section.send(newSection)
    }
}
