//
//  SectionCreationViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 02.04.2025.
//

import Foundation
import TrackerDomain

@MainActor
protocol SectionCreationViewModelProtocol: ObservableObject {
    var sectionTitle: String { get set }
    var invalidComponent: SectionCreationInvalidComponent? { get }
    
    func onPrimary()
}

final class SectionCreationViewModel: SectionCreationViewModelProtocol {
    typealias InvalidComponent = SectionCreationInvalidComponent
    
    private let invalidComponentManager: any InvalidComponentManaging<InvalidComponent>
    private let eventsHandler: (TrackerSection) -> Void
    private let section: TrackerSection?
    
    @Published private(set) var invalidComponent: InvalidComponent?
    @Published var sectionTitle: String = ""
    
    init(
        invalidComponentManager: some InvalidComponentManaging<InvalidComponent> = InvalidComponentManager(),
        section: TrackerSection?,
        eventsHandler: @escaping (TrackerSection) -> Void
    ) {
        self.invalidComponentManager = invalidComponentManager
        self.eventsHandler = eventsHandler
        self.section = section
        
        if let section {
            self.sectionTitle = section.title
        }
        
        invalidComponentManager.invalidComponent.assign(to: &$invalidComponent)
    }
    
    func onPrimary() {
        do {
            let sectionTitle = try Self.validate(sectionTitle: sectionTitle)
            
            if let section {
                eventsHandler(.init(id: section.id, title: sectionTitle, trackers: []))
            }
            else {
                eventsHandler(.init(title: sectionTitle, trackers: []))
            }
        }
        catch {
            invalidComponentManager.markComponentInvalid(error)
        }
    }
}

private extension SectionCreationViewModel {
    static func validate(sectionTitle: String) throws(InvalidComponent) -> String {
        guard !sectionTitle.isEmpty && sectionTitle.count < 39 else {
            throw .title
        }
        
        return sectionTitle
    }
}
