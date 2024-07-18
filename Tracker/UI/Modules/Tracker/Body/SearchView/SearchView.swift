import UIKit

final class SearchView: UIView {
    private let searchBar: UISearchBar = {
        let view = UISearchBar()
        view.searchBarStyle = .minimal
        view.placeholder = Strings.Localizable.Main.search
        return view
    }()
    
    let onTextChange: (String) -> Void
    
    // MARK: - Init
    
    init(onTextChange: @escaping (String) -> Void) {
        self.onTextChange = onTextChange
        
        super.init(frame: .zero)
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
        onTextChange(searchText)
    }
}
