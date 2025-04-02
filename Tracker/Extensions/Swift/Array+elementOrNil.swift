import Foundation

extension Array {
    func elementOrNil(at index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        
        return self[index]
    }
}
