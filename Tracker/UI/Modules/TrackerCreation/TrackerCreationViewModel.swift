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
    private let eventsHandler: (TrackerCreationOutput) -> Void
    private let tracker: Tracker?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var emoji: String?
    private var colorHexString: String?
    
    @Published private(set) var invalidComponent: TrackerCreationInvalidComponent?
    @Published private(set) var sectionName: String?
    @Published private(set) var weekDays: WeekDays = []
    @Published var newTrackerText = ""
    
    @Published var route: TrackerCreationRoute?
    
    let emojiViewModel: GridViewModel<TrackerCreationGridItem>
    let colorsViewModel: GridViewModel<TrackerCreationGridItem>
    
    init(
        tracker: Tracker? = nil,
        eventsHandler: @escaping (TrackerCreationOutput) -> Void
    ) {
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
        
        if let name = tracker?.name {
            newTrackerText = name
        }
        
        if let weekDaysUnordered = tracker?.weekDays {
            weekDays = weekDaysUnordered
        }
        
        emojiViewModel.$selectedItem
            .compactMap({ $0 })
            .sink { [weak self] item in self?.emoji = item.value }
            .store(in: &cancellables)
        
        colorsViewModel.$selectedItem
            .compactMap({ $0 })
            .sink { [weak self] item in self?.colorHexString = item.value }
            .store(in: &cancellables)
    }
    
    func onSectionSelection() {
        route = .section(
            tracker?.categoryId,
            onCompletion: { [weak self] in
                self?.route = nil
                self?.sectionName = $0.title
            }
        )
    }
    
    func onWeekSelection() {
        route = .weekDay(
            weekDays,
            onCompletion: { [weak self] in
                self?.route = nil
                self?.weekDays = $0
            }
        )
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
            invalidComponent = error
        }
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
