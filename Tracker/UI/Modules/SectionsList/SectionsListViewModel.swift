//
//  SectionsListViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.03.2025.
//

import Foundation
import TrackerDomain

@MainActor
protocol SectionsListViewModelProtocol: ObservableObject {
    var state: SectionsListState { get }
    var selectedSection: TrackerSection? { get }
    
    func onSection(_ section: TrackerSection)
    func onSectionDelete(_ section: TrackerSection)
    func onAppear()
}

final class SectionsListViewModel: SectionsListViewModelProtocol {
    private let sectionRepository: any SectionRepositoryProtocol
    private let initialSectionID: UUID?
    @Published private(set) var state: SectionsListState = .loading
    @Published private(set) var selectedSection: TrackerSection?
    
    init(
        sectionRepository: some SectionRepositoryProtocol,
        sectionID: UUID?
    ) {
        self.sectionRepository = sectionRepository
        self.initialSectionID = sectionID
    }

    func onAppear() {
        Task {
            await loadSections()

            if let selectedSection {
                await loadSection(selectedSection.id)
            } else if let initialSectionID {
                await loadSection(initialSectionID)
            } else {
                selectedSection = state.models.first
            }
        }
    }
    
    func onSection(_ section: TrackerSection) {
        selectedSection = section
        
    }
    
    func onSectionDelete(_ section: TrackerSection) {
        Task {
            await deleteSection(section.id)
            await loadSections()
        }
    }
}

private extension SectionsListViewModel {
    func deleteSection(_ sectionID: UUID) async {
        do {
            try await sectionRepository.deleteSection(with: sectionID)
        }
        catch {
            debugPrint(error)
        }
    }
    
    func loadSections() async {
        do {
            let sections = try await sectionRepository.getSections(fetchLimit: 200, fetchOffset: 0)
            
            state = .loaded(sections)
        }
        catch {
            state = .error
        }
    }
    
    func loadSection(_ sectionID: UUID) async {
        do {
            let section = try await sectionRepository.getSection(by: sectionID)
            
            selectedSection = section
        }
        catch {
            selectedSection = state.models.first
        }
    }
}
