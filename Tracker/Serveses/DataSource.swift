import Foundation

protocol DataSourceProtocol {
    mutating func addCategoryHeader(_ header: String)
    mutating func addSchedule(_ schedule: String)
    func numberOfTableViewRows(ofKind kind: TrackerKind) -> Int
    func dataForTablView(ofKind kind: TrackerKind) -> [TableData]
    func numberOfItemsInSection(_ section: Int) -> Int
    func numberOfCollectionSections() -> Int
    func getSection(_ indexPath: IndexPath) -> CollectionViewData
    func indexPath(forEmoji item: String) -> IndexPath?
    func indexPath(forColor item: String) -> IndexPath?
}

struct DataSourceImpl {
    private var category = TableData(
        title: Strings.Localizable.Create.category,
        subtitle: ""
    )
    private var schedule = TableData(
        title: Strings.Localizable.Create.schedule,
        subtitle: ""
    )
    
    // Public data
    private let collectionViewData: [CollectionViewData] = [
        .emojiSection(items: [
            "🙂", "😻", "🌺", "🐶", "❤️",
            "😱", "😇", "😡", "🥶", "🤔",
            "🙌", "🍔", "🥦", "🏓", "🥇",
            "🎸", "🏝️", "😪"
        ]),
        .colorSection(items: CollectionViewColors.allCases)
    ]
    
    private var firstRowData: [TableData] {
        [category]
    }
    
    private var secondRowData: [TableData] {
        [category, schedule]
    }
}

extension DataSourceImpl: DataSourceProtocol {
    func getSection(_ indexPath: IndexPath) -> CollectionViewData {
        collectionViewData[indexPath.section]
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        switch collectionViewData[section] {
        case .emojiSection(let items):
            return items.count
        
        case .colorSection(let items):
            return items.count
        }
    }
    
    func numberOfCollectionSections() -> Int {
        collectionViewData.count
    }
        
    func dataForTablView(ofKind kind: TrackerKind) -> [TableData] {
        switch kind {
        case .occasional:
            return firstRowData
        
        case .habit:
            return secondRowData
        }
    }
    
    func numberOfTableViewRows(ofKind kind: TrackerKind) -> Int {
        switch kind {
        case .occasional:
            return firstRowData.count
        
        case .habit:
            return secondRowData.count
        }
    }
    
    func indexPath(forEmoji item: String) -> IndexPath? {
        for (sectionIndex, section) in collectionViewData.enumerated() {
            if case .emojiSection(let items) = section,
                let itemIndex = items.firstIndex(of: item) {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    func indexPath(forColor item: String) -> IndexPath? {
        for (sectionIndex, section) in collectionViewData.enumerated() {
            if case .colorSection(let items) = section,
                let itemIndex = items.firstIndex(where: { $0.rawValue == item.uppercased() }) {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    mutating func addCategoryHeader(_ header: String) {
        self.category.subtitle = header
    }
    
    mutating func addSchedule(_ schedule: String) {
        self.schedule.subtitle = schedule
    }
}

struct TableData {
    let title: String
    var subtitle: String
}

enum CollectionViewData {
    case emojiSection(items: [String])
    case colorSection(items: [CollectionViewColors])
    
    var title: String {
        switch self {
        case .emojiSection:
            return Strings.Localizable.Create.emoji
        
        case .colorSection:
            return Strings.Localizable.Create.color
        }
    }
}

enum CollectionViewColors: String, CaseIterable {
    case color0 = "#FD4C49"
    case color1 = "#FF881E"
    case color2 = "#007BFA"
    case color3 = "#6E44FE"
    case color4 = "#33CF69"
    case color5 = "#E66DD4"
    case color6 = "#F9D4D4"
    case color7 = "#34A7FE"
    case color8 = "#46E69D"
    case color9 = "#35347C"
    case color10 = "#FF674D"
    case color11 = "#FF99CC"
    case color12 = "#F6C48B"
    case color13 = "#7994F5"
    case color14 = "#832CF1"
    case color15 = "#AD56DA"
    case color16 = "#8D72E6"
    case color17 = "#2FD058"
}
