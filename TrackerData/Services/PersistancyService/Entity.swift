import CoreData

protocol Entity {
    static var entityName: String { get }
}

protocol CopyableEntity<CopyableValue> {
    associatedtype CopyableValue
    
    func copy(from: CopyableValue)
}

protocol SetAddable<ElementType> {
    associatedtype ElementType: NSManagedObject
    
    func addElement(_ elements: [ElementType])
}

protocol ValueAddable<AddableValue> {
    associatedtype AddableValue: NSManagedObject
    
    func addValue(_ value: AddableValue)
}

protocol Initable<Object> {
    associatedtype Object
    
    init(object: Object)
}
