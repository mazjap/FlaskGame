import SwiftUI

struct FallingConfettiModifier: ViewModifier {
    @State private var confettiCannon = ConfettiCannon(filled: false, confettiPerCycle: 2, confettiDuration: Self.duration)
    @Binding private var didWin: Bool
    @Binding private var score: Int?
    
    private let animate: Bool
    
    init(animate: Bool, didWin: Binding<Bool>, score: Binding<Int?> = .constant(nil)) {
        self.animate = animate
        self._didWin = didWin
        self._score = score
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if didWin {
                Group {
                    TimelineView(.animation) { timeline in
                        Canvas { context, size in
                            let current = timeline.date.timeIntervalSinceReferenceDate
                            confettiCannon.update(using: current)
                            
                            for confetti in confettiCannon.confetti {
                                guard let symbol = context.resolveSymbol(id: confetti.symbolId) else { continue }
                                
                                let dy = (current - confetti.createdAt) / Self.duration * confetti.velocity * size.height
                                
                                context.draw(
                                    symbol,
                                    at: confetti.point
                                        .scaled(dx: size.width)
                                        .translated(dy: dy),
                                    anchor: .center
                                )
                            }
                        } symbols: {
                            ForEach(FlaskColor.subsetCases) { color in
                                ForEach(ConfettiShape.allCases(filled: confettiCannon.filled)) { confettiType in
                                    Group {
                                        if confettiCannon.filled {
                                            confettiType.filled
                                        } else {
                                            confettiType.stroked
                                        }
                                    }
                                    .frame(width: 12, height: 12)
                                    .tag(color.rawValue + confettiType.id)
                                }
                                .foregroundColor(color.color)
                            }
                            .scaledToFit()
                        }
                    }
                    
                    VStack {
                        Text("You Won!")
                            .font(.system(size: 500))
                            .minimumScaleFactor(0.01)
                        
                        if let score = score {
                            Text("Score: \(score)")
                                .font(Font.headline)
                        }
                    }
                    .lineLimit(1)
                    .padding(20)
                    .foregroundColor(.primaryLabel)
                }
                .allowsHitTesting(false)
                .ignoresSafeArea(edges: .all)
                .onDisappear {
                    confettiCannon.confetti = []
                }
            }
        }
    }
    
    static let duration = 4.0
}


#Preview {
    Color.white
        .ignoresSafeArea()
        .modifier(FallingConfettiModifier(animate: true, didWin: .constant(true)))
}
