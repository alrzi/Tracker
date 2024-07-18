import CoreData

protocol TrackerCategoryStoreProtocol {
    func addCategory(with name: String) throws -> CategoryObject?
    func addTracker(toCategoryWithName name: String, tracker: TrackerObject) throws
    func remove(tracker: TrackerObject, fromCategoryWithName name: String)
    func getAllCategories() -> [TrackerCategory]
    func getNameOfLastSelectedCategory() -> String?
}

protocol TrackerCategoryListProtocol {
    func addCategory(with name: String) throws -> CategoryObject?
    func isNameAvailable(name: String) throws -> Bool
    func getAllCategories() -> [TrackerCategory]
    func removeCategoryWith(name: String)
    func update(category: TrackerCategory, withNewName name: String)
    func addCategory(name: String)
}

struct TrackerCategoryStore: Store {
    typealias EntityType = CategoryObject
            
    let context: NSManagedObjectContext
    var predicateBuilder: TrackerCategoryPredicateBuilderProtocol
    
    init(
        context: NSManagedObjectContext,
        predicateBuilder: TrackerCategoryPredicateBuilderProtocol = PredicateBuilder()
    ) {
        self.context = context
        self.predicateBuilder = predicateBuilder
    }

    init() {
        let context = ManagedObjectContext.shared.context
        self.init(context: context)
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func addTracker(toCategoryWithName name: String, tracker: TrackerObject) throws {
        if let category = getCategoryWith(name: name) {
//            category.addToTrackers(tracker)
        } else {
            let category = CategoryObject(context: context)
            category.title = name
//            category.addToTrackers(tracker)
        }
        save()
    }

    func addCategory(name: String) {
        let trackerCategory = TrackerCategory(id: UUID(), header: name, trackers: [])
        CategoryObject(trackerCategory: trackerCategory, context: context)
        save()
    }
    
    func addCategory(with name: String) throws -> CategoryObject? {
        if let category = getCategoryWith(name: name) {
            return category
        } else {
            let category = CategoryObject(context: context)
            category.title = name
            save()
            return category
        }
    }
    
    func remove(tracker: TrackerObject, fromCategoryWithName name: String) {
        if let category = getCategoryWith(name: name) {
//            category.removeFromTrackers(tracker)
            save()
        }
    }
    
    func removeCategoryWith(name: String) {
        if let category = getCategoryWith(name: name) {
            try? delete(category)
        }
    }
    
    func getAllCategories() -> [TrackerCategory] {
        do {
            return try fetchTrackerCategories(context: context).toTrackerCategories()
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func getNameOfLastSelectedCategory() -> String? {
        nil
    }
    
    func putToAttachedCategory(tracker: TrackerObject) {
        tracker.isPinned = true
        try? addTracker(toCategoryWithName: Strings.Localizable.Main.pinned, tracker: tracker)
    }
}

// MARK: - TrackerCategoryListProtocol
extension TrackerCategoryStore: TrackerCategoryListProtocol {
    func isNameAvailable(name: String) throws -> Bool {
        return (getCategoryWith(name: name) != nil) ? false : true
    }
    
    func markCategoryAsLastSelected(categoryName: String) {
        if let category = getCategoryWith(name: categoryName) {
            save()
        }
    }
      
    func update(category: TrackerCategory, withNewName name: String) {
        if let category = getObjectBy(id: category.id)?.first {
            
            save()
        }
    }
}

// MARK: - Private
private extension TrackerCategoryStore {
    func fetchTrackerCategories(
        context: NSManagedObjectContext,
        withPredicate predicateClosure: (() -> NSPredicate)? = nil
    ) throws -> [CategoryObject] {
        let categoryRequest = NSFetchRequest<CategoryObject>(entityName: CategoryObject.entityName)
        if let predicateClosure = predicateClosure {
            categoryRequest.predicate = predicateClosure()
        }
        
        let results = try context.fetch(categoryRequest)
        return results
    }

    func getCategoryWith(name: String) -> CategoryObject? {
        return try? fetchTrackerCategories(context: context) {
            predicateBuilder.buildPredicateCategory(name: name)
        }.first
    }
}

extension CategoryObject {
    convenience init(trackerCategory: TrackerCategory, context: NSManagedObjectContext) {
        self.init(context: context)
        update(with: trackerCategory)
    }

    func update(with trackerCategory: TrackerCategory) {
        self.id = trackerCategory.id
        self.title = trackerCategory.header
        self.trackers = NSOrderedSet(array: trackerCategory.trackers)
    }
}

extension Array where Element == CategoryObject {
    func toTrackerCategories() -> [TrackerCategory] {
        return self.compactMap { category in
            TrackerCategory(coreData: category)
        }
    }
}
