import HapticFeedback
import Swinject
import TrackerData
import TrackerDomain
import UserNotifications

@MainActor
final class AppCompositionRoot {
    private let assembler = Assembler()
    private let notificationCenterDelegate: UNUserNotificationCenterDelegate

    let notificationManager: any AppNotificationManaging
    let appFlowDependencies: AppFlowContainer.Dependencies

    init() {
        assembler.apply(assemblies: [
            TrackerDataAssembly(),
            TrackerDomainAssembly(),
            ServicesAssembly(),
            FactoriesAssembly(),
        ])

        let resolver = assembler.resolver
        let notificationCenterDelegate = resolver.resolve(UNUserNotificationCenterDelegate.self)!
        self.notificationCenterDelegate = notificationCenterDelegate
        UNUserNotificationCenter.current().delegate = notificationCenterDelegate
        self.notificationManager = resolver.resolve((any AppNotificationManaging).self)!

        let trackerFormModelFactory = TrackerFormFlowModelFactory(
            sectionsListFactory: resolver.resolve(SectionsListFactory.self)!,
            sectionCreationFactory: resolver.resolve(SectionCreationFactory.self)!
        )
        let trackerFormDependencies = TrackerFormFlowContainer.Dependencies(
            trackerFormFactory: resolver.resolve(TrackerFormFactory.self)!,
            modelFactory: trackerFormModelFactory
        )
        let trackersDependencies = TrackersFlowContainer.Dependencies(
            trackersScreenFactory: resolver.resolve(TrackersScreenFactory.self)!,
            trackerForm: trackerFormDependencies
        )
        let mainTabDependencies = MainTabFlowContainer.Dependencies(
            statisticsScreenFactory: resolver.resolve(StatisticsScreenFactory.self)!,
            trackers: trackersDependencies
        )
        self.appFlowDependencies = AppFlowContainer.Dependencies(
            authService: resolver.resolve(AuthServiceProtocol.self)!,
            mainTab: mainTabDependencies
        )
    }
}
