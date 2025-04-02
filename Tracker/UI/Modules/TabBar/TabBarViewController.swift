import UIKit

final class TabBarViewController: UITabBarController {
    private let trackersAssembly: TrackersAssembly
    private let statisticAssembly: StatisticsAssembly
    
    private let viewModel: TabBarViewModel
    
    init(
        trackersAssembly: TrackersAssembly,
        statisticAssembly: StatisticsAssembly,
        viewModel: TabBarViewModel
    ) {
        self.viewModel = viewModel
        self.trackersAssembly = trackersAssembly
        self.statisticAssembly = statisticAssembly
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [
            trackersAssembly.assemble(()),
            statisticAssembly.assemble()
        ]
        
        TabItem.allCases.enumerated().forEach { index, item in
            viewControllers?.elementOrNil(at: index)?.tabBarItem = .init(tabItem: item)
        }
        
        let standardAppearance = UITabBarAppearance()
        
        UITabBar.appearance().standardAppearance = standardAppearance
        UITabBar.appearance().scrollEdgeAppearance = standardAppearance
    }
}

private extension UITabBarItem {
    convenience init(tabItem: TabItem) {
        self.init(title: tabItem.title, image: tabItem.image, selectedImage: tabItem.selectedImage)
        
        tag = tabItem.rawValue
        imageInsets = .zero
        accessibilityIdentifier = "Tab_\(tabItem)"
    }
}
