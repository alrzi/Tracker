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
    var completedSection: TrackerSection? { get }
    
    func onPrimary()
}

final class SectionCreationViewModel: SectionCreationViewModelProtocol {
    typealias InvalidComponent = SectionCreationInvalidComponent
    
    private let invalidComponentManager: any InvalidComponentManaging<InvalidComponent>
    private let sectionRepository: any SectionRepositoryProtocol
    private let section: TrackerSection?
    
    @Published private(set) var invalidComponent: InvalidComponent?
    @Published private(set) var completedSection: TrackerSection?
    @Published var sectionTitle: String = ""
    
    init(
        invalidComponentManager: some InvalidComponentManaging<InvalidComponent> = InvalidComponentManager(),
        sectionRepository: some SectionRepositoryProtocol,
        section: TrackerSection?
    ) {
        self.invalidComponentManager = invalidComponentManager
        self.sectionRepository = sectionRepository
        self.section = section
        
        if let section {
            self.sectionTitle = section.title
        }
        
        invalidComponentManager.invalidComponent.assign(to: &$invalidComponent)
    }
    
    func onPrimary() {
        do {
            let sectionTitle = try Self.validate(sectionTitle: sectionTitle)
            let result = if let section {
                TrackerSection(id: section.id, title: sectionTitle, trackers: section.trackers)
            } else {
                TrackerSection(title: sectionTitle, trackers: [])
            }

            Task {
                do {
                    if section == nil {
                        try await sectionRepository.createSection(result)
                    } else {
                        try await sectionRepository.updateSection(result)
                    }
                    completedSection = result
                } catch {
                    debugPrint(error)
                }
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
