import CoreData

protocol Entity {
    static var entityName: String { get }
}

protocol CopyableEntity<CopyableValue> {
    associatedtype CopyableValue
    
    func copy(from: CopyableValue)
}

protocol Initable<Object> {
    associatedtype Object
    
    init(object: Object)
}
