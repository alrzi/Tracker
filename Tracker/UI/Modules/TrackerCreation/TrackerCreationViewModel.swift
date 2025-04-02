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
    var newTrackerText: String { get set }
    var title: String { get }
    var sectionName: String? { get }
    var weekDays: WeekDays { get }
    var emojiViewModel: GridViewModel<TrackerCreationGridItem> { get }
    var colorsViewModel: GridViewModel<TrackerCreationGridItem> { get }
    var invalidComponent: TrackerCreationInvalidComponent? { get }
    
    func onSectionSelection()
    func onWeekSelection()   
    func onCreate()
}

final class TrackerCreationViewModel: TrackerCreationViewModelProtocol {
    typealias Component = TrackerCreationInvalidComponent
    
    private let invalidComponentManager: any InvalidComponentManaging<Component>
    private let tracker: Tracker?
    private let eventsHandler: (TrackerCreationOutput) -> Void
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var emoji: String?
    private var colorHexString: String?
    
    @Published private(set) var invalidComponent: Component?
    @Published private(set) var sectionName: String?
    @Published private(set) var weekDays: WeekDays = []
    @Published var newTrackerText = ""
    
    @Published var route: TrackerCreationRoute?
    
    let title: String
    let emojiViewModel: GridViewModel<TrackerCreationGridItem>
    let colorsViewModel: GridViewModel<TrackerCreationGridItem>
    
    init(
        invalidComponentManager: some InvalidComponentManaging<Component> = InvalidComponentManager(),
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
        
        if let emoji = emojiArray.first(where: { $0.value == tracker?.emoji }) {
            emojiViewModel.selectItem(emoji)
        }
        
        if let color = colorsArray.first(where: { $0.value == tracker?.color }) {
            colorsViewModel.selectItem(color)
        }
        
        if let tracker {
            newTrackerText = tracker.name
            weekDays = tracker.weekDays
            title = "Редактировние"
        }
        else {
            title = R.string.localizable.createNewHabit()
        }
                
        emojiViewModel.$selectedItem
            .compactMap({ $0 })
            .sink { [weak self] item in self?.emoji = item.value }
            .store(in: &cancellables)
        
        colorsViewModel.$selectedItem
            .compactMap({ $0 })
            
            .sink { [weak self] item in self?.colorHexString = item.value }
            .store(in: &cancellables)
        
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
                name: newTrackerText,
                sectionName: sectionName,
                weekDays: weekDays,
                emoji: emoji,
                color: colorHexString
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
        sectionName = section.title
    }
    
    func onWeekDays(_ days: WeekDays) {
        route = nil
        weekDays = days
    }
}

private extension TrackerCreationViewModel {
    static func createSectionIfPossible(
        name: String,
        sectionName: String?,
        weekDays: WeekDays,
        emoji: String?,
        color: String?
    ) throws(TrackerCreationInvalidComponent) -> TrackerSection {
        guard !name.isEmpty else {
            throw .name
        }
        
        guard let sectionName else {
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
            title: sectionName,
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
