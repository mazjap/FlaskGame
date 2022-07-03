import CoreGraphics

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
    
    func scaled(dx: Double = 1, dy: Double = 1) -> CGPoint {
        CGPoint(x: x * dx, y: y * dy)
    }
    
    func scaled(by scale: Double) -> CGPoint {
        scaled(dx: scale, dy: scale)
    }
    
    func translated(dx: Double = 0, dy: Double = 0) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }
}
