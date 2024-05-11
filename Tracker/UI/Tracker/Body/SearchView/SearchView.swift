import UIKit

protocol SearchViewDelegate: AnyObject {
    func searchView(_ searchView: SearchView, textDidChange searchText: String)
    func hideKeyboard()
}

final class SearchView: UIView {
    // MARK: - Public
    weak var delegate: SearchViewDelegate?
    
    // MARK: - Private properties
    private let searchBar: UISearchBar = {
        let view = UISearchBar()
        view.searchBarStyle = .minimal
        view.placeholder = Strings.Localizable.Main.search
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    @objc func hideKeyboard() {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Private methods
private extension SearchView {
    func setupUI() {
        searchBar.delegate = self
    
        addSubviews(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - UISearchBarDelegate
extension SearchView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchView(self, textDidChange: searchText)
    }
}
