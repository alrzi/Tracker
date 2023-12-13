import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func testViewController() throws {
        let mockDataProvider = MockDataProvider()
        let sut = TrackersViewController(dataProvider: mockDataProvider)
        mockDataProvider.createMockData()

        assertSnapshot(matching: sut, as: .image(traits: .init(userInterfaceStyle: .light)))

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = .dark
        window.rootViewController = sut
        window.makeKeyAndVisible()

        // Wait for the view to update to dark mode
        RunLoop.current.run(until: Date())

        assertSnapshot(matching: sut, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}

final class MockDataProvider: DataProviderProtocol {
    var delegate: DataProviderDelegate?

    var mockData: TrackerCategory = TrackerCategory(header: "", trackers: [], isLastSelected: false)

    func createMockData() {
        self.mockData = TrackerCategory(
            header: "Tests",
            trackers:
                [
                    Tracker(name: "Test1", emoji: "😀", color: "#FF674D", schedule: [], kind: .habit),
                    Tracker(name: "Test2", emoji: "🥹", color: "#FF684D", schedule: [], kind: .habit),
                    Tracker(name: "Test3", emoji: "😊", color: "#FF694D", schedule: [], kind: .habit),
                    Tracker(name: "Test4", emoji: "😜", color: "#FF704D", schedule: [], kind: .habit),
                ]
            ,
            isLastSelected: false)
    }

    var isEmpty = false

    var numberOfSections = 1

    func numberOfRowsInSection(_ section: Int) -> Int {
        mockData.trackers.count
    }

    func header(for section: Int) -> String {
        mockData.header
    }

    func daysTracked(for indexPath: IndexPath) -> Int {
        .zero
    }

    func getCategories() -> [TrackerCategory] {
        []
    }

    func addTrackerCategory(_ category: TrackerCategory) throws {}

    func getTracker(at indexPath: IndexPath) -> Tracker? {
        mockData.trackers[indexPath.row]
    }

    func deleteTracker(at indexPath: IndexPath) throws {}

    func isTrackerAt(indexPath: IndexPath, completedForDate date: String) -> Bool {
        false
    }

    func saveAsCompletedTracker(with indexPath: IndexPath, for day: String) throws {}

    func fetchTrackersWith(name: String, forWeekDay: String) throws {}

    func fetchTrackersBy(weekDay: String) throws {}

    func pinTrackerAt(indexPath: IndexPath) {}

    func unPinTrackerAt(indexPath: IndexPath) {}

    func fetchCompletedTrackersFor(date: String) throws {}

    func fetchUncompletedTrackersFor(weekDay: String, andForDate date: String) throws {}

    func getTrackersForToday() throws {}

    func fetchTrackersFor(weekDay: String) throws {}

    func fetchUncompletedTrackersWith(name: String, forWeekDay weekDay: String, andForDate: String) throws {}

    func fetchCompletedTrackersWith(name: String, forDate date: String) throws {}
}
