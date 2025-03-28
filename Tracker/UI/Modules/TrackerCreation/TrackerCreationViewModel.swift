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
    var weekDaysFormatted: String? { get }
    var emojiViewModel: GridViewModel<TrackerCreationGridItem> { get }
    var colorsViewModel: GridViewModel<TrackerCreationGridItem> { get }
    var invalidComponent: TrackerCreationInvalidComponent? { get }
    
    func onSectionSelection()
    func onWeekSelection()   
    func onCreate()
}

final class TrackerCreationViewModel: TrackerCreationViewModelProtocol {
    private let eventsHandler: (TrackerCreationOutput) -> Void
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var emoji: String?
    private var colorHexString: String?
    
    @Published private(set) var invalidComponent: TrackerCreationInvalidComponent?
    @Published private(set) var sectionName: String?
    @Published private(set) var weekDaysFormatted: String?
    @Published var newTrackerText = ""
    
    @Published var route: TrackerCreationRoute?
    
    let emojiViewModel: GridViewModel<TrackerCreationGridItem>
    let colorsViewModel: GridViewModel<TrackerCreationGridItem>
    
    init(
        tracker: Tracker? = nil,
        eventsHandler: @escaping (TrackerCreationOutput) -> Void
    ) {
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
        
        if let weekDays = tracker?.weekDays {
            weekDaysFormatted = weekDays.map({ $0.localizedString(format: .short) }).joined(separator: ", ")
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
        
    }
    
    func onWeekSelection() {
        route = .weekDay("", onCompletion: { _ in })
    }
    
    func onCreate() {
        do {
            let section = try Self.createSectionIfPossible(
                name: newTrackerText,
                sectionName: sectionName,
                weekDaysFormatted: weekDaysFormatted,
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

extension TrackerCreationViewModel {
    static func createSectionIfPossible(
        name: String,
        sectionName: String?,
        weekDaysFormatted: String?,
        emoji: String?,
        color: String?
    ) throws(TrackerCreationInvalidComponent) -> TrackerSection {
        guard !name.isEmpty else {
            throw .name
        }
        
        guard let sectionName else {
            throw .section
        }
        
        guard let weekDaysFormatted else {
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
                    schedule: [.friday],
                    categoryId: sectionID
                )
            ]
        )
    }
}
