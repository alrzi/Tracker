//
//  SectionsListViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 28.03.2025.
//

import Foundation
import TrackerDomain

@MainActor
protocol SectionsListViewModelProtocol: ObservableObject, SectionListNavigationState {
    var state: SectionsListState { get }
    var selectedSection: TrackerSection? { get }
    
    func onSection(_ section: TrackerSection)
    func onSectionCreation()
    func onSectionUpdate(_ section: TrackerSection)
    func onSectionDelete(_ section: TrackerSection)
}

final class SectionsListViewModel: SectionsListViewModelProtocol {
    private let sectionRepository: any CategoryRepositoryProtocol
    private let eventsHandler: (TrackerSection) -> Void
    
    @Published private(set) var state: SectionsListState = .loading
    private(set) var selectedSection: TrackerSection?
    
    @Published var route: SectionListRoute?
    
    init(
        sectionRepository: some CategoryRepositoryProtocol,
        sectionID: UUID?,
        eventsHandler: @escaping (TrackerSection) -> Void
    ) {
        self.sectionRepository = sectionRepository
        self.eventsHandler = eventsHandler
        
        Task {
            await loadSections()
            
            guard let sectionID else {
                return
            }
            
            await loadSection(sectionID)
        }
    }
    
    func onSection(_ section: TrackerSection) {
        selectedSection = section
        
        eventsHandler(section)
    }
    
    func onSectionCreation() {
        route = .createSection(onCompletion: { [weak self] in self?.onSectionCreated($0) })
    }
    
    func onSectionUpdate(_ section: TrackerSection) {
        route = .updateSection(title: section.title, onCompletion: { [weak self] in self?.onSectionUpdated($0) })
    }
    
    func onSectionDelete(_ section: TrackerSection) {
        
    }
}

// MARK: - Private

private extension SectionsListViewModel {
    func onSectionUpdated(_ title: String) {
        route = nil
    }
    
    func onSectionCreated(_ title: String) {
        route = nil
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
            let section = try await sectionRepository.getCategory(by: sectionID)
            
            selectedSection = section
        }
        catch {
            selectedSection = state.models.first
        }
    }
}
