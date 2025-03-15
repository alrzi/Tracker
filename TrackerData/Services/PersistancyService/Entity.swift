import CoreData

protocol Entity {
    static var entityName: String { get }
}

protocol CopyableEntity {
    associatedtype CopyableValue
    
    func copy(from: CopyableValue)
}

protocol SetAddable {
    associatedtype ElementType: NSManagedObject
    
    func addElement(_ elements: [ElementType])
}

protocol ValueAddable {
    associatedtype AddableValue: NSManagedObject
    
    func addValue(_ value: AddableValue)
}
