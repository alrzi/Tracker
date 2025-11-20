import CoreData

protocol Entity {
    static var entityName: String { get }
}

extension Entity {
    public static var entityName: String { String(describing: Self.self) }
}

protocol CopyableEntity<CopyableValue> {
    associatedtype CopyableValue
    
    func copy(from: CopyableValue)
}

protocol Initable<Object> {
    associatedtype Object
    
    init(object: Object)
}
