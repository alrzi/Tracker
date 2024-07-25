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
    func onCategoryFlow()
    func onSchedule()
    func onCancel()
    
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
    private let userInputCollector: UserInputCollector
    private var dataSource: DataSourceProtocol
    private let trackerManager: TrackerManaging
    
    private let resultObserver: PassthroughSubject<Action, Never>
    private var cancellable: Set<AnyCancellable> = []
    
    private let mode: Mode
    
    private var categoryId: UUID?
    private var date: Date?
            
    @Published var updateTrackerViewModel: UpdateTrackerViewModel?
    @Published var updateTrackedDaysViewModel: UpdateTrackedDaysViewModel?
    @Published var tracker: Tracker?
    @Published var warningType: WarningType = .animateToHide
    @Published var categoryHeader: String?
    @Published var schedule: Set<Int> = []
    
    init(
        userInputCollector: UserInputCollector,
        dataSource: DataSourceProtocol = DataSourceImpl(),
        trackerManager: TrackerManaging,
        resultObserver: PassthroughSubject<Action, Never>,
        mode: Mode
    ) {
        
        self.dataSource = dataSource
        self.userInputCollector = userInputCollector
        self.trackerManager = trackerManager
        self.resultObserver = resultObserver
        self.mode = mode
        self.tracker = mode.tracker
        self.date = mode.date
        
        userInputCollector.trackerPublisher           
            .sink { [weak self] in self?.tracker = $0 }
            .store(in: &cancellable)
        
        userInputCollector.weekDaysPublisher
            .sink { [weak self] in
                self?.dataSource.addSchedule($0.weekdayStringShort())
                self?.schedule = $0
            }
            .store(in: &cancellable)
        
        userInputCollector.categoryPublisher
            .sink { [weak self] in
                self?.dataSource.addCategoryHeader($0.header)
                self?.categoryHeader = $0.header
                self?.categoryId = $0.id
            }
            .store(in: &cancellable)
        
        guard let tracker else {
            return
        }
        
        userInputCollector.setTracker(tracker)
    }
    
    func setValue(_ value: UserInputValue) {
        userInputCollector.insert(value)
    }
        
    func updateUI() {
        guard 
            let tracker,
            let date = date,
            let category = categoryHeader,
            let colorIndexPath = dataSource.indexPath(forColor: tracker.color),
            let emojiIndexPath = dataSource.indexPath(forEmoji: tracker.emoji)
        else {
            return
        }
              
        updateTrackerViewModel = UpdateTrackerViewModel(
            name: tracker.name,
            emoji: emojiIndexPath,
            color: colorIndexPath
        )
        
        updateTrackedDaysViewModel = UpdateTrackedDaysViewModel(
            trackedDays: Strings.Localizable.daysNumber(3),
            isTrackedForToday: false
        )
        
        // add data to data source to update tableView
        dataSource.addCategoryHeader(category)
//        dataSource.addSchedulxe(tracker.schedule.weekdayStringShort())
        
        userInputCollector.setTracker(tracker)
        userInputCollector.insert(.category(.init(header: category, trackers: [])))
    }
    
    func createOrUpdateTracker() {
        guard let tracker, let categoryId else {
            return
        }
        
        switch mode {
        case .create:
            do {
                try trackerManager.addCategory(withId: categoryId, toTracker: tracker)
                
                resultObserver.send(.onCreateTracker)
            }
            catch {
                debugPrint(error.localizedDescription)
            }
            
        case .update:
            break
        }
    }
    
    func incrementButtonTapped() {
        do {
//            try trackerManager.markAsTrackedFor(date: date, trackerWithId: tracker?.id)
//            self.updateTrackedDaysViewModel = getDataForUpdateTrackedDaysViewModel()
        } catch {
            print(error)
        }
    }
    
    func decrementButtonTapped() {
        do {
//            try trackerManager.markAsTrackedFor(date: date, trackerWithId: tracker?.id)
//            self.updateTrackedDaysViewModel = getDataForUpdateTrackedDaysViewModel()
        } catch {
            print(error)
        }
    }

    func handleNameLogic(name: String, newNameLength: Int) {
        setValue(.name(name))
        
        let isTextLong = isTextTooLong(newNameLength)
        setEnterTextAnimationWarningType(isTextLong)
    }
    
    func isTextTooLong(_ newLength: Int) -> Bool {
        let maxLength = 38
        return newLength > maxLength
    }
    
    func onCategoryFlow() {
        resultObserver.send(.onCategoryFlow)
    }
    
    func onSchedule() {
        resultObserver.send(.onSchedule)
    }
    
    func onCancel() {
        resultObserver.send(.onCancel)
    }
    
    deinit {
        resultObserver.send(completion: .finished)
    }
}

// MARK: - Public DataSource
extension CreateTrackerViewModelImpl {
    var numberOfTableViewRows: Int {
        dataSource.numberOfTableViewRows(ofKind: .habit)
    }
    
    var dataForTablView: [TableData] {
        dataSource.dataForTablView(ofKind: .habit)
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
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        dataSource.numberOfItemsInSection(section)
    }
    
    func getSection(_ indexPath: IndexPath) -> CollectionViewData {
        dataSource.getSection(indexPath)
    }
    
    func getHeaderName() -> String? {
//        trackerManager.getHeaderName()
        nil
    }
}

// MARK: - Private methods
private extension CreateTrackerViewModelImpl {
//    func getDataForUpdateTrackedDaysViewModel() -> UpdateTrackedDaysViewModel {
//        if let tracker = tracker,
//            let date = date,
//            let trackedDays = trackerManager.getTrackedDaysNumberFor(id: tracker.id)
//        {
//            return UpdateTrackedDaysViewModel(
//                trackedDays: Strings.Localizable.daysNumber(trackedDays),
//                isTrackedForToday: trackerManager.isCompletedFor(date: date, trackerWithId: tracker.id)
//            )
//        } 
//        else {
//            return UpdateTrackedDaysViewModel(trackedDays: "", isTrackedForToday: false)
//        }
//    }

    func setEnterTextAnimationWarningType(_ isTextTooLong: Bool) {
        if isTextTooLong {
            warningType = .animateToShow
        } else {
            warningType = .animateToHide
        }
    }
}

extension CreateTrackerViewModelImpl {
    enum Action {
        case onSchedule
        case onCategoryFlow
        case onCreateTracker
        case onCancel
    }
    
    enum Mode {
        case create(TrackerKind)
        case update(Tracker, Date)
        
        var tracker: Tracker? {
            switch self {
            case .create: nil
            case .update(let tracker, _): tracker
            }
        }
        
        var date: Date? {
            switch self {
            case .create: nil
            case .update(_, let date): date
            }
        }
    }
    
    enum WarningType {
        case animateToShow
        case animateToHide
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
