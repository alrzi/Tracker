import UIKit
import Combine

final class StatisticViewController: UIViewController {
    private let placeholder = PlaceholderView(state: .noStatistic)
    // MARK: - Private properties
    private let tableView: UITableView = {
        let view = UITableView()
        view.contentInset.top = 77
        view.backgroundColor = .clear
        view.allowsSelection = false
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.register(cellClass: StatisticTableViewCell.self)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setDelegates()
    }

    private let viewModel: StatisticViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: StatisticViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind()
    }

    func bind() {
        viewModel.$isAnyTrackers
            .dropFirst()
            .sink { [weak self] isAny in
                if isAny {
                    self?.placeholder.state = .invisible(animate: false)
                    self?.tableView.reloadData()
                } else {
                    self?.placeholder.state = .noStatistic
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }

    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupUI() {
        title = Strings.Localizable.Statistic.title
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = Asset.Colors.myWhite.color
        view.addSubviews(placeholder, tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension StatisticViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.statisticData.count
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
        return 102
    }
}
