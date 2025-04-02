//
//  TrackerCreationViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation
import Combine
import TrackerDomain

@MainActor
protocol TrackerCreationViewModelProtocol: ObservableObject, TrackerCreationNavigationState {
    var tackerTitle: String { get set }
    var title: String { get }
    var sectionTitle: String? { get }
    var weekDays: WeekDays { get }
    var emojiViewModel: GridViewModel<TrackerCreationGridItem> { get }
    var colorsViewModel: GridViewModel<TrackerCreationGridItem> { get }
    var invalidComponent: TrackerCreationInvalidComponent? { get }
    
    func onSectionSelection()
    func onWeekSelection()   
    func onCreate()
}

final class TrackerCreationViewModel: TrackerCreationViewModelProtocol {
    typealias InvalidComponent = TrackerCreationInvalidComponent
    
    private let sectionRepository: CategoryRepositoryProtocol
    private let invalidComponentManager: any InvalidComponentManaging<InvalidComponent>
    private let eventsHandler: (TrackerCreationOutput) -> Void
    
    private let tracker: Tracker?
    private var section: TrackerSection? {
        didSet { sectionTitle = section?.title }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private(set) var invalidComponent: InvalidComponent?
    @Published private(set) var sectionTitle: String?
    @Published private(set) var weekDays: WeekDays = []
    @Published var tackerTitle = ""
    
    @Published var route: TrackerCreationRoute?
    
    let title: String
    let emojiViewModel: GridViewModel<TrackerCreationGridItem>
    let colorsViewModel: GridViewModel<TrackerCreationGridItem>
    
    init(
        sectionRepository: CategoryRepositoryProtocol,
        invalidComponentManager: some InvalidComponentManaging<InvalidComponent> = InvalidComponentManager(),
        tracker: Tracker?,
        eventsHandler: @escaping (TrackerCreationOutput) -> Void
    ) {
        self.sectionRepository = sectionRepository
        self.invalidComponentManager = invalidComponentManager
        self.tracker = tracker
        self.eventsHandler = eventsHandler
        
        let emojiArray = (0...17).map { _ in TrackerCreationGridItem(value: RandomEmojiService.emoji) }
        let colorsArray = (0...17).map { _ in TrackerCreationGridItem(value: RandomHexColorService.randomHexString) }
        
        emojiViewModel = .init(items: emojiArray)
        colorsViewModel = .init(items: colorsArray)
        
        if let tracker {
            tackerTitle = tracker.name
            weekDays = tracker.weekDays
            title = "Редактировние"
            
            if let emoji = emojiArray.first(where: { $0.value == tracker.emoji }) {
                emojiViewModel.selectItem(emoji)
            }
            
            if let color = colorsArray.first(where: { $0.value == tracker.color }) {
                colorsViewModel.selectItem(color)
            }
            
            Task {
                await fetchSection(id: tracker.categoryId)
            }
        }
        else {
            title = R.string.localizable.createNewHabit()
        }
        
        invalidComponentManager.invalidComponent.assign(to: &$invalidComponent)
    }
    
    func onSectionSelection() {
        route = .section(section?.id, onCompletion: { [weak self] in self?.onSection($0) })
    }
    
    func onWeekSelection() {
        route = .weekDay(weekDays, onCompletion: { [weak self] in self?.onWeekDays($0) })
    }
    
    func onCreate() {
        do {
            let section = try Self.validate(
                name: tackerTitle,
                section: section,
                weekDays: weekDays,
                emoji: emojiViewModel.selectedItem?.value,
                color: colorsViewModel.selectedItem?.value
            )
            
            eventsHandler(.section(section))
        }
        catch {
            invalidComponentManager.markComponentInvalid(error)
        }
    }
}

// MARK: - Private

private extension TrackerCreationViewModel {
    func onSection(_ updatedSection: TrackerSection) {
        route = nil
        section = updatedSection
    }
    
    func onWeekDays(_ days: WeekDays) {
        route = nil
        weekDays = days
    }
    
    func fetchSection(id: UUID) async {
        do {
            let selectedSection = try await sectionRepository.getCategory(by: id)
            
            section = selectedSection
        }
        catch {
            debugPrint(error)
        }
    }
}

private extension TrackerCreationViewModel {
    static func validate(
        name: String,
        section: TrackerSection?,
        weekDays: WeekDays,
        emoji: String?,
        color: String?
    ) throws(TrackerCreationInvalidComponent) -> TrackerSection {
        guard !name.isEmpty else {
            throw .title
        }
        
        guard let section else {
            throw .section
        }
        
        guard !weekDays.isEmpty else {
            throw .weekDays
        }
        
        guard let emoji else {
            throw .emoji
        }
        
        guard let color else {
            throw .color
        }
        
        let tracker = Tracker(
            name: name,
            emoji: emoji,
            color: color,
            schedule: Set(weekDays),
            categoryId: section.id
        )
        
        return section.addingTracker(tracker)
    }
}
