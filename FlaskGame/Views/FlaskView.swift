import SwiftUI

struct FlaskView: View {
    @State private var anchor: Anchor<CGRect>? = nil
    @Binding private var animationOffset: CGFloat
    
    let flask: Flask
    
    init(flask: Flask, animationOffset: Binding<CGFloat> = .constant(0)) {
        self.flask = flask
        self._animationOffset = animationOffset
    }
    
    private var colors: some View {
        VStack(spacing: 0) {
            ForEach(
                flask.colors
                    .reversed()
                    .enumerated()
                    .map { ($0.offset, $0.element) },
                id: \.0
            ) { (_, color) in
                Color(color)
            }
        }
        .transition(.identity)
        .allowsHitTesting(true)
    }
    
    var body: some View {
        let shape = FlaskShape()
        
        shape
            .stroke(style: StrokeStyle(lineWidth: 0.5))
            .background(
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        let colorsScale = min(1, Double(flask.colors.count) / 4)
                        let spacerScale = 1 - colorsScale
                        
                        Color.kindaClear
                            .frame(height: geometry.size.height * spacerScale)
                        
                        colors
                            .clipShape(Waves(offset: animationOffset))
                            .frame(height: geometry.size.height * colorsScale)
                    }
                }
                .clipShape(shape)
            )
            .contentShape(shape)
    }
}

struct FlaskView_Previews: PreviewProvider {
    static var previews: some View {
        FlaskView(flask: Flask(colors: [.red, .green, .gray, .blue]))
    }
}

extension CGRect {
    init(p1: CGPoint, p2: CGPoint) {
        let startPoint = CGPoint(x: min(p1.x, p2.x), y: min(p1.x, p2.x))
        let width = abs(p1.x - p2.x)
        let height = abs(p1.y - p2.y)
        
        self.init(x: startPoint.x, y: startPoint.y, width: width, height: height)
    }
    
    init<FP: BinaryFloatingPoint>(x1: FP, y1: FP, x2: FP, y2: FP) {
        self.init(
            p1: CGPoint(
                x: CGFloat(x1),
                y: CGFloat(y1)),
            p2: CGPoint(
                x: CGFloat(x2),
                y: CGFloat(y2)
            )
        )
    }
}
