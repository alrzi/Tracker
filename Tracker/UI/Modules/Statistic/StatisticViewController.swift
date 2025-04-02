import UIKit
import Combine

final class StatisticViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.contentInset.top = 77
        view.backgroundColor = .clear
        view.allowsSelection = false
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.register(cellClass: StatisticTableViewCell.self)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private let viewModel: StatisticViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: StatisticViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        bind(viewModel: viewModel)
    }

    private func bind(viewModel: StatisticViewModel) {
        viewModel.$isAnyTrackers
            .dropFirst()
            .sink { [weak self] isAny in
                if isAny {
                    self?.tableView.reloadData()
                } 
                else {
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        title = "Strings.Localizable.Statistic.title"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),        
        ])
    }
}

// MARK: - UITableViewDataSource

extension StatisticViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.statisticData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StatisticTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: viewModel.statisticData[indexPath.row].title)
        cell.bind(to: viewModel.statisticData[indexPath.row].viewModel)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension StatisticViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}
