import SwiftUI

struct FallingConfettiModifier: ViewModifier {
    @State private var confettiCannon = ConfettiCannon(filled: false, confettiDuration: Self.duration)
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
                
                GeometryReader { geometry in
                    TimelineView(.animation) { timeline in
                        Canvas { context, size in
                            let current = timeline.date.timeIntervalSinceReferenceDate
                            confettiCannon.update(using: current)
                            
                            for confetti in confettiCannon.confetti {
                                guard let symbol = context.resolveSymbol(id: confetti.symbolId) else { continue }
                                
                                let dy = (timeline.date.timeIntervalSinceReferenceDate - confetti.createdAt) / Self.duration * confetti.velocity * size.height
                                
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
                                    .tag(color.rawValue + confettiType.id)
                                }
                                .foregroundColor(color.color)
                            }
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                        }
                    }
                }
                .allowsHitTesting(false)
                .ignoresSafeArea(edges: .all)
                .onDisappear {
                    confettiCannon.confetti = []
                }
            }
        }
    }
    
    static let duration = 3.0
}
