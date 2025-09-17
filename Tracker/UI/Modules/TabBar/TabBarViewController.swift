import UIKit
import Combine

final class TabBarController: UITabBarController {
    private let viewModel: TabBarViewModel
        
    private var indexCancelable: Cancellable?
    
    init(
        viewModel: TabBarViewModel
    ) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTabBar()
        
        indexCancelable = viewModel.$tabIndex
            .receive(on: DispatchQueue.main)
            .filter { [weak self] in self?.selectedIndex != $0 }
            .sink { [weak self] in self?.selectedIndex = $0 }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidAppear()
    }
}

private extension TabBarController {
    func updateTabBar() {
        let appearance = tabBar.standardAppearance
        let layoutAppearance = appearance.stackedLayoutAppearance
        
        layoutAppearance.normal.iconColor = .gray
        layoutAppearance.normal.titleTextAttributes = [
            .paragraphStyle: NSParagraphStyle.default,
            .foregroundColor: UIColor.gray
        ]
        
        layoutAppearance.selected.iconColor = UIColor(resource: .cBlue)
        layoutAppearance.selected.titleTextAttributes = [
            .paragraphStyle: NSParagraphStyle.default,
            .foregroundColor: UIColor(resource: .cBlue)
        ]
        
        appearance.stackedLayoutAppearance = layoutAppearance
        appearance.stackedItemPositioning = .automatic
        appearance.inlineLayoutAppearance = layoutAppearance
        appearance.compactInlineLayoutAppearance = layoutAppearance
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        view.tintColor = UIColor(resource: .cBlue)
    }
}

// MARK: - Делегат

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        viewModel.onTabIndexSelected(tabBarController.selectedIndex)
    }
}
