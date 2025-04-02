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
    
    private let invalidComponentManager: any InvalidComponentManaging<InvalidComponent>
    private let tracker: Tracker?
    private let eventsHandler: (TrackerCreationOutput) -> Void
    
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
        invalidComponentManager: some InvalidComponentManaging<InvalidComponent> = InvalidComponentManager(),
        tracker: Tracker?,
        eventsHandler: @escaping (TrackerCreationOutput) -> Void
    ) {
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
        }
        else {
            title = R.string.localizable.createNewHabit()
        }
        
        invalidComponentManager.invalidComponent.assign(to: &$invalidComponent)
    }
    
    func onSectionSelection() {
        route = .section(tracker?.categoryId, onCompletion: { [weak self] in self?.onSection($0) })
    }
    
    func onWeekSelection() {
        route = .weekDay(weekDays, onCompletion: { [weak self] in self?.onWeekDays($0) })
    }
    
    func onCreate() {
        do {
            let section = try Self.createSectionIfPossible(
                name: tackerTitle,
                sectionTitle: sectionTitle,
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
    func onSection(_ section: TrackerSection) {
        route = nil
        sectionTitle = section.title
    }
    
    func onWeekDays(_ days: WeekDays) {
        route = nil
        weekDays = days
    }
}

private extension TrackerCreationViewModel {
    static func createSectionIfPossible(
        name: String,
        sectionTitle: String?,
        weekDays: WeekDays,
        emoji: String?,
        color: String?
    ) throws(TrackerCreationInvalidComponent) -> TrackerSection {
        guard !name.isEmpty else {
            throw .title
        }
        
        guard let sectionTitle else {
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
        
        let sectionID = UUID()
        
        return .init(
            id: sectionID,
            title: sectionTitle,
            trackers: [
                .init(
                    name: name,
                    emoji: emoji,
                    color: color,
                    schedule: Set(weekDays),
                    categoryId: sectionID
                )
            ]
        )
    }
}
