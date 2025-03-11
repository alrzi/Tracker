import Foundation

struct GeometryParams {
    let cellCount: Int
    let cellSize: CGSize
    let leftInset: CGFloat
    let rightInset: CGFloat
    let topInset: CGFloat
    let bottomInset: CGFloat
    let spacing: CGFloat
    let emptySpaceWidth: CGFloat
    let sizeOfElements: CGFloat
    
    init(
        cellCount: Int,
        cellSize: CGSize,
        leftInset: CGFloat,
        rightInset: CGFloat,
        topInset: CGFloat,
        bottomInset: CGFloat,
        spacing: CGFloat
    ) {
        self.cellCount = cellCount
        self.cellSize = cellSize
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.spacing = spacing
        self.emptySpaceWidth = leftInset + rightInset + CGFloat(cellCount - 1) * spacing
        self.sizeOfElements = (leftInset + rightInset) + (cellSize.width * CGFloat(cellCount))
    }
}
