import SwiftUI

class ConfettiCannon {
    var confetti = Set<Confetti>()
    var point: UnitPoint
    let filled: Bool
    let confettiPerCycle: UInt
    let confettiDuration: Double
    
    init(point: UnitPoint = .top, filled: Bool = false, confettiPerCycle: UInt = 1, confettiDuration: Double = 2) {
        self.point = point
        self.filled = filled
        self.confettiPerCycle = confettiPerCycle
        self.confettiDuration = confettiDuration
    }
    
    func update(using date: TimeInterval) {
        let r = 0.5
        let range = -r...r
        
        confetti = confetti.filter { confettiDuration - (date - $0.createdAt) >= 0 }
        
        for _ in 0..<confettiPerCycle {
            confetti.insert(Confetti(
                x: point.x + Double.random(in: range),
                y: point.y + Double.random(in: range),
                type: .random(filled: filled)
            ))
        }
    }
}
