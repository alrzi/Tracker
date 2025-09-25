//
//  TrackerFormViewModel.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation
import Combine
import TrackerDomain

@MainActor
protocol TrackerFormViewModelProtocol: ObservableObject, TrackerFormNavigationState {
    var tackerTitle: String { get set }
    var title: String { get }
    var sectionTitle: String? { get }
    var weekDays: WeekDays { get }
    var emojiViewModel: GridViewModel<TrackerFormGridItem> { get }
    var colorsViewModel: GridViewModel<TrackerFormGridItem> { get }
    var invalidComponent: TrackerFormInvalidComponent? { get }
    var completeFormButtonTitle: String { get }
    
    func onSectionSelection()
    func onWeekSelection()
    func onCompleteFrom() async
}

final class TrackerFormViewModel: TrackerFormViewModelProtocol {
    typealias InvalidComponent = TrackerFormInvalidComponent
    
    private let trackerManager: any TrackerManaging
    private let sectionRepository: SectionRepositoryProtocol
    private let invalidComponentManager: any InvalidComponentManaging<InvalidComponent>
    private let eventsHandler: (TrackerFormOutput) -> Void
    
    private let mode: TrackerFormMode
    
    private var section: TrackerSection? {
        didSet { sectionTitle = section?.title }
    }
        
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private(set) var sectionTitle: String?
    @Published private(set) var weekDays: WeekDays = []
    @Published private(set) var invalidComponent: InvalidComponent?
    
    @Published var tackerTitle = ""
    
    @Published var route: TrackerFormRoute?
    
    let title: String
    let emojiViewModel: GridViewModel<TrackerFormGridItem>
    let colorsViewModel: GridViewModel<TrackerFormGridItem>
    let completeFormButtonTitle: String
    
    init(
        trackerManager: any TrackerManaging,
        sectionRepository: SectionRepositoryProtocol,
        invalidComponentManager: some InvalidComponentManaging<InvalidComponent> = InvalidComponentManager(),
        mode: TrackerFormMode,
        eventsHandler: @escaping (TrackerFormOutput) -> Void
    ) {
        self.trackerManager = trackerManager
        self.sectionRepository = sectionRepository
        self.invalidComponentManager = invalidComponentManager
        self.mode = mode
        self.eventsHandler = eventsHandler
        
        title = mode.screenTitle
        completeFormButtonTitle = mode.completeFormButtonTitle
        emojiViewModel = .init(items: (0...17).map { _ in TrackerFormGridItem(value: RandomEmojiService.emoji) })
        colorsViewModel = .init(items: (0...17).map { _ in TrackerFormGridItem(value: RandomHexColorService.randomHexString) })
        
        if case .editTracker(let tracker) = mode {
            fillForm(with: tracker)
        }
        
        invalidComponentManager.invalidComponent.assign(to: &$invalidComponent)
    }
    
    func onSectionSelection() {
        route = .section(section?.id, onCompletion: { [weak self] in self?.onSection($0) })
    }
    
    func onWeekSelection() {
        route = .weekDay(weekDays, onCompletion: { [weak self] in self?.onWeekDays($0) })
    }
    
    func onCompleteFrom() async {
        do {
            let (tracker, section) = try Self.validate(
                name: tackerTitle,
                section: section,
                weekDays: weekDays,
                emoji: emojiViewModel.selectedItem?.value,
                color: colorsViewModel.selectedItem?.value,
                mode: mode
            )
            
            switch mode {
            case .createTracker:
                try await trackerManager.createTrackerAndAddToSection(with: section.id, tracker: tracker)
                
            case .editTracker:
                try await trackerManager.update(tracker: tracker)
            }
            
            eventsHandler(.init(tracker: tracker, section: section))
        }
        catch let error as TrackerFormInvalidComponent {
            invalidComponentManager.markComponentInvalid(error)
        }
        catch {
            debugPrint(error)
        }
    }
}

// MARK: - Private

private extension TrackerFormViewModel {
    func onSection(_ updatedSection: TrackerSection) {
        route = nil
        section = updatedSection
    }
    
    func onWeekDays(_ days: WeekDays) {
        route = nil
        weekDays = days
    }
    
    func fillForm(with tracker: Tracker) {
        tackerTitle = tracker.name
        weekDays = tracker.weekDays
        
        if let emoji = emojiViewModel.items.first(where: { $0.value == tracker.emoji }) {
            emojiViewModel.selectItem(emoji)
        }
        
        if let color = colorsViewModel.items.first(where: { $0.value == tracker.color }) {
            colorsViewModel.selectItem(color)
        }
        
        Task {
            await fetchSection(id: tracker.sectionId)
        }
    }
    
    func fetchSection(id: UUID) async {
        do {
            let selectedSection = try await sectionRepository.getSection(by: id)
            
            section = selectedSection
        }
        catch {
            debugPrint(error)
        }
    }
}

private extension TrackerFormViewModel {
    typealias ValidationResult = (Tracker, TrackerSection)
    
    static func validate(
        name: String,
        section: TrackerSection?,
        weekDays: WeekDays,
        emoji: String?,
        color: String?,
        mode: TrackerFormMode
    ) throws(TrackerFormInvalidComponent) -> ValidationResult {
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
            id: mode.trackerId,
            name: name,
            emoji: emoji,
            color: color,
            schedule: Set(weekDays),
            isPinned: mode.isPinned,
            trackedDays: mode.trackedDays,
            sectionId: section.id,
            isCompleted: mode.isCompleted
        )
        
        return (tracker, section)
    }
}

private extension TrackerFormMode {
    var screenTitle: String {
        switch self {
        case .createTracker: String(localized: .createNewHabit)
        case .editTracker: "Редактировние"
        }
    }
    
    var completeFormButtonTitle: String {
        switch self {
        case .createTracker: String(localized: .createCreateNew)
        case .editTracker: "Обновить"
        }
    }
    
    var trackerId: UUID {
        switch self {
        case .createTracker: .init()
        case .editTracker(let tracker): tracker.id
        }
    }
    
    var isPinned: Bool {
        switch self {
        case .createTracker: false
        case .editTracker(let tracker): tracker.isPinned
        }
    }
    
    var trackedDays: Int {
        switch self {
        case .createTracker: .zero
        case .editTracker(let tracker): tracker.trackedDays
        }
    }
    
    var isCompleted: Bool {
        switch self {
        case .createTracker: false
        case .editTracker(let tracker): tracker.isCompleted
        }
    }
}
