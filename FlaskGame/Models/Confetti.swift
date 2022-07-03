import Foundation
import CoreGraphics

struct Confetti: Hashable {
    let createdAt = Date.now.timeIntervalSinceReferenceDate
    
    var point: CGPoint
    let type: ConfettiShape
    let color = FlaskColor.subsetRandom
    let velocity = Double.random(in: 1...1.5)
    
    var symbolId: String {
        color.rawValue + type.id
    }
    
    var x: Double {
        get { point.x }
        set { point.x = newValue }
    }
    
    var y: Double {
        get { point.y }
        set { point.y = newValue }
    }
    
    init(point: CGPoint, type: ConfettiShape, color: FlaskColor = .subsetRandom) {
        self.point = point
        self.type = type
    }
    
    init(x: Double, y: Double, type: ConfettiShape, color: FlaskColor = .subsetRandom) {
        self.init(point: CGPoint(x: x, y: y), type: type, color: color)
    }
}
