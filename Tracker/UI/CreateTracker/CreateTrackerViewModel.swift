import CoreData
import Combine

protocol CreateTrackerViewModelProtocol {
    var isTrackersAddedToCoreData: Bool { get }
    var updateTrackerViewModel: UpdateTrackerViewModel? { get }
    var shouldUpdateButtonStylePublisher: AnyPublisher<Bool, Never> { get }
    var isShakingButton: Bool { get }
    func updateUI()
    func createOrUpdateTracker()
    func getHeaderName() -> String?
    
    // Data source
    func addCategory(header: String)
    func setSchedule(schedule: Set<Int>)
    func numberOfItemsInSection(_ section: Int) -> Int
    func getSection(_ indexPath: IndexPath) -> CollectionViewData
    var numberOfTableViewRows: Int { get }
    var numberOfCollectionSections: Int { get }
    var dataForTablView: [TableData] { get }
}

final class CreateTrackerViewModelImpl: ObservableObject {
    // Need to dismiss screen or show alert
    @Published var isTrackersAddedToCoreData = false
    
    // Property for updating a screen in eddit mode
    @Published var updateTrackerViewModel: UpdateTrackerViewModel?
    @Published var updateTrackedDaysViewModel: UpdateTrackedDaysViewModel?
    @Published var warningType: WarningType = .animateToHide
    
    // Properties for creating a new tracker
    @Published var name: String?
    @Published var emoji: String?
    @Published var color: String?
    @Published var schedule: Set<Int>?
    @Published var categoryHeader: String?
    
    // MARK: - Dependencies
    private(set) var tracker: Tracker?
    private var dataSource: DataSourceProtocol
    private let trackerKind: Tracker.Kind
    private let trackerManager: TrackerManagerProtocol
    private let date: String?

    enum WarningType {
        case animateToShow
        case animateToHide
    }

    // MARK: - Init
    init(
        trackerKind: Tracker.Kind,
        tracker: Tracker?,
        date: String?,
        dataSource: DataSourceProtocol = DataSourceImpl(),
        trackerManager: TrackerManagerProtocol = TrackerManagerImpl()
    ) {
        self.trackerKind = trackerKind
        self.tracker = tracker
        self.date = date
        self.dataSource = dataSource
        self.trackerManager = trackerManager
        // set schedule for ocasional tracker to all days for button disabling
        trackerKind == .ocasional ? schedule = WeekDay.allDaysOfWeek : nil
        if let categoryHeader = getHeaderName() {
            addCategory(header: categoryHeader)
        }
    }
    
    // MARK: - Public Computed Properties
    var shouldUpdateButtonStylePublisher: AnyPublisher<Bool, Never> {
        let paramsOne = Publishers.CombineLatest3($name, $emoji, $color)
        let paramsTwo = Publishers.CombineLatest($schedule, $categoryHeader)
        return paramsOne.combineLatest(paramsTwo)
            .map { args in
                self.isTrackerValid(args: args)
            }
            .eraseToAnyPublisher()
    }
    
    var isShakingButton: Bool {
        shouldShakeButton()
    }
    
    // MARK: - Public Methods
    func updateUI() {
        if let id = tracker?.id,
            let date = date,
            let name = tracker?.name,
            let emoji = tracker?.emoji,
            let color = tracker?.color,
            let schedule = tracker?.schedule,
            let colorIndexPath = dataSource.indexPath(forColor: color),
            let emojiIndexPath = dataSource.indexPath(forEmoji: emoji),
            let categoryHeader = trackerManager.getCategoryNameFor(trackerID: id),
            let trackedDays = trackerManager.getTrackedDaysNumberFor(id: id),
            let isTrackedTracker = trackerManager.isCompletedFor(date: date, trackerWithId: id) {
            // add data to data source to update tableView
            dataSource.addCategoryHeader(categoryHeader)
            dataSource.addSchedule(schedule.weekdayStringShort())
            
            // Need to set values for button to be up tp date
            setPublisherValues(
                name: name,
                emoji: emoji,
                color: color,
                schedule: schedule,
                categeryHeader: categoryHeader)
            
            updateTrackerViewModel = UpdateTrackerViewModel(
                name: name,
                emoji: emojiIndexPath,
                color: colorIndexPath)
            
            updateTrackedDaysViewModel = UpdateTrackedDaysViewModel(
                trackedDays: Strings.Localizable.daysNumber(trackedDays),
                isTrackedForToday: isTrackedTracker)
        }
    }
    
    func createOrUpdateTracker() {
        if let tracker = self.tracker {
            // Update existing tracker
            do {
                try trackerManager.updateTracker(kind: trackerKind, id: tracker.id, name: name, emoji: emoji, color: color, schedule: schedule, categoryHeader: categoryHeader, isAttached: tracker.isAttached)
                isTrackersAddedToCoreData = true
            } catch {
                isTrackersAddedToCoreData = false
            }
        } else {
            // Create new tracker
            do {
                try trackerManager.createTracker(kind: trackerKind, name: name, emoji: emoji, color: color, schedule: schedule, categoryHeader: categoryHeader)
                isTrackersAddedToCoreData = true
            } catch {
                isTrackersAddedToCoreData = false
            }
        }
    }
    
    func incrementButtonTapped() {
        do {
            try trackerManager.markAsTrackedFor(date: date, trackerWithId: tracker?.id)
            self.updateTrackedDaysViewModel = getDataForUpdateTrackedDaysViewModel()
        } catch {
            print(error)
        }
    }
    
    func decrementButtonTapped() {
        do {
            try trackerManager.markAsTrackedFor(date: date, trackerWithId: tracker?.id)
            self.updateTrackedDaysViewModel = getDataForUpdateTrackedDaysViewModel()
        } catch {
            print(error)
        }
    }

    func handleNameLogic(name: String, newNameLength: Int) {
        updateName(name)
        let isTextLong = isTextTooLong(newNameLength)
        setEnterTextAnimationWarningType(isTextLong)
    }

    func isTextTooLong(_ newLength: Int) -> Bool {
        let maxLength = 38
        return newLength > maxLength
    }
}

// MARK: - Public DataSource
extension CreateTrackerViewModelImpl {
    var numberOfTableViewRows: Int {
        dataSource.numberOfTableViewRows(ofKind: trackerKind)
    }
    
    var dataForTablView: [TableData] {
        dataSource.dataForTablView(ofKind: trackerKind)
    }
    
    var numberOfCollectionSections: Int {
        dataSource.numberOfCollectionSections()
    }
    
    func addCategory(header: String) {
        dataSource.addCategoryHeader(header)
        self.categoryHeader = header
    }
    
    func setSchedule(schedule: Set<Int>) {
        dataSource.addSchedule(schedule.weekdayStringShort())
        self.schedule = schedule
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        dataSource.numberOfItemsInSection(section)
    }
    
    func getSection(_ indexPath: IndexPath) -> CollectionViewData {
        dataSource.getSection(indexPath)
    }
    
    func getHeaderName() -> String? {
        trackerManager.getHeaderName()
    }
}

// MARK: - Private methods
private extension CreateTrackerViewModelImpl {
    func shouldShakeButton() -> Bool {
        (name?.isEmpty == false)
        && (emoji?.isEmpty == false)
        && (color?.isEmpty == false)
        && (categoryHeader?.isEmpty == false)
        && (schedule?.isEmpty == false)
    }
    
    func isTrackerValid(args: Args) -> Bool {
        guard let name = args.0.0,
            let emoji = args.0.1,
            let color = args.0.2,
            let schedule = args.1.0,
            let categeryHeader = args.1.1
        else {
            return false
        }
        
        return !name.isEmpty &&
        !emoji.isEmpty &&
        !color.isEmpty &&
        !schedule.isEmpty &&
        !categeryHeader.isEmpty
    }
    
    func setPublisherValues(name: String, emoji: String, color: String, schedule: Set<Int>, categeryHeader: String) {
        self.name = name
        self.schedule = schedule
        self.color = color
        self.emoji = emoji
        self.categoryHeader = categeryHeader
    }
    
    func getDataForUpdateTrackedDaysViewModel() -> UpdateTrackedDaysViewModel {
        if let tracker = tracker,
            let date = date,
            let trackedDays = trackerManager.getTrackedDaysNumberFor(id: tracker.id),
            let isCompleted = trackerManager.isCompletedFor(date: date, trackerWithId: tracker.id) {
            return UpdateTrackedDaysViewModel(
                trackedDays: Strings.Localizable.daysNumber(trackedDays),
                isTrackedForToday: isCompleted
            )
        } else {
            return UpdateTrackedDaysViewModel(trackedDays: "", isTrackedForToday: false)
        }
    }

    func setEnterTextAnimationWarningType(_ isTextTooLong: Bool) {
        if isTextTooLong {
            warningType = .animateToShow
        } else {
            warningType = .animateToHide
        }
    }

    func updateName(_ name: String) {
        if name.isEmpty {
            self.name = nil
        } else {
            self.name = name
        }
    }
}

struct UpdateTrackerViewModel {
    let name: String
    let emoji: IndexPath
    let color: IndexPath
}

struct UpdateTrackedDaysViewModel {
    let trackedDays: String
    let isTrackedForToday: Bool
}

typealias Args = (
    Publishers.CombineLatest3<Published<String?>.Publisher,
    Published<String?>.Publisher,
    Published<String?>.Publisher>.Output,
    Publishers.CombineLatest<Published<Set<Int>?>.Publisher,
    Published<String?>.Publisher>.Output
)
