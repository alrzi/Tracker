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
    var habitScheduleViewModel: TrackerFormHabitScheduleViewModel { get }
    var emojiViewModel: GridViewModel<TrackerFormGridItem> { get }
    var colorsViewModel: GridViewModel<TrackerFormGridItem> { get }
    var invalidComponent: TrackerFormInvalidComponent? { get }
    var completeFormButtonTitle: String { get }
    
    func onSectionSelection()
    func onCompleteFrom() async
}

final class TrackerFormViewModel: TrackerFormViewModelProtocol {
    typealias InvalidComponent = TrackerFormInvalidComponent
    
    private let trackerManager: any TrackerManaging
    private let notificationManager: any AppNotificationManaging
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
    let habitScheduleViewModel: TrackerFormHabitScheduleViewModel
    let emojiViewModel: GridViewModel<TrackerFormGridItem>
    let colorsViewModel: GridViewModel<TrackerFormGridItem>
    let completeFormButtonTitle: String
    
    init(
        trackerManager: any TrackerManaging,
        notificationManager: some AppNotificationManaging,
        sectionRepository: SectionRepositoryProtocol,
        invalidComponentManager: some InvalidComponentManaging<InvalidComponent> = InvalidComponentManager(),
        mode: TrackerFormMode,
        eventsHandler: @escaping (TrackerFormOutput) -> Void
    ) {
        self.trackerManager = trackerManager
        self.notificationManager = notificationManager
        self.sectionRepository = sectionRepository
        self.invalidComponentManager = invalidComponentManager
        self.mode = mode
        self.eventsHandler = eventsHandler
        
        title = mode.screenTitle
        completeFormButtonTitle = mode.completeFormButtonTitle
        emojiViewModel = .init(items: Self.emojiItems)
        colorsViewModel = .init(items: Self.colorItems)

        switch mode {
        case .createTracker:
            habitScheduleViewModel = .init(selectedDays: [], info: nil)

        case .editTracker(let tracker):
            habitScheduleViewModel = .init(
                selectedDays: tracker.weekDays,
                info: tracker.notificationInformation
            )
            fillForm(with: tracker)
        }

        invalidComponentManager.invalidComponent.assign(to: &$invalidComponent)
    }
    
    func onSectionSelection() {
        route = .section(section?.id, onCompletion: { [weak self] in self?.onSection($0) })
    }
    
    func onCompleteFrom() async {
        do {
            let configs = habitScheduleViewModel.configs.filter({ $0.isSelected })
            let weekDays = Set(configs.map({ $0.day }))
            let (tracker, section) = try Self.validate(
                name: tackerTitle,
                section: section,
                weekDays: weekDays,
                emoji: emojiViewModel.selectedItem?.value,
                color: colorsViewModel.selectedItem?.value,
                mode: mode,
                notificationInfo: configs.extractSchedule()
            )
            
            switch mode {
            case .createTracker:
                try await trackerManager.createTrackerAndAddToSection(with: section.id, tracker: tracker)
                
            case .editTracker:
                try await trackerManager.update(tracker: tracker)
            }

            eventsHandler(.init(tracker: tracker, section: section))
            syncNotifications()
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
    func syncNotifications() {
        Task { [notificationManager] in
            do {
                try await notificationManager.sync(only: .trackers)
            }
            catch {
                debugPrint(error)
            }
        }
    }

    func onSection(_ updatedSection: TrackerSection) {
        route = nil
        section = updatedSection
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
            await updateSection(with: tracker.sectionId)
        }
    }
    
    func updateSection(with id: UUID) async {
        do {
            let selectedSection = try await sectionRepository.getSection(by: id)
            section = selectedSection
        } catch {
            debugPrint(error)
        }
    }
}

private extension TrackerFormViewModelProtocol {
    // MARK: - Static properties

    static var emojiItems: [TrackerFormGridItem] {
        TrackerFormGridOptions.emojiItems
    }

    static var colorItems: [TrackerFormGridItem] {
        TrackerFormGridOptions.colorItems
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
        mode: TrackerFormMode,
        notificationInfo: [WeekDay: Date],
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

        var scheduleDict: [WeekDay: TrackerNotificationInformation.DayNotificationDetails] = [:]

        for info in notificationInfo {
            scheduleDict[info.key] = .init(weekDay: info.key, isEnabled: true, time: info.value)
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
            isCompleted: mode.isCompleted,
            notificationInformation: .init(
                trackerId: mode.trackerId,
                isGlobalEnabled: !notificationInfo.isEmpty,
                schedule: scheduleDict
            )
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

    var weekDays: Set<WeekDay> {
        switch self {
        case .createTracker: []
        case .editTracker(let tracker): tracker.weekDays
        }
    }

    var color: String? {
        switch self {
        case .createTracker: nil
        case .editTracker(let tracker): tracker.color
        }
    }

    var emoji: String? {
        switch self {
        case .createTracker: nil
        case .editTracker(let tracker): tracker.emoji
        }
    }

    var isCompleted: Bool {
        switch self {
        case .createTracker: false
        case .editTracker(let tracker): tracker.isCompleted
        }
    }
}
