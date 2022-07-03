import SwiftUI

struct FlaskView: View {
    @Binding private var offsetWave: Bool
    
    let flask: Flask
    
    init(flask: Flask, offsetWave: Binding<Bool> = .constant(false)) {
        self.flask = flask
        self._offsetWave = offsetWave
    }
    
    private var colors: some View {
        VStack(spacing: 0) {
            ForEach(
                flask.colors
                    .reversed()
                    .enumerated()
                    .map { ($0.offset, $0.element) },
                id: \.0
            ) { (position, color) in
                Label {
                    Text("Color \(color.rawValue) at \(position)")
                } icon: {
                    color.color
                }
            }
        }
        .allowsHitTesting(true)
        .labelStyle(.iconOnly)
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
                            .frame(height: geometry.size.height * colorsScale)
                            .clipShape(Waves(offset: offsetWave ? .pi / 8 : 0))
                    }
                }
                .clipShape(shape)
            )
            .contentShape(shape)
            .transition(.identity)
    }
}

struct FlaskView_Previews: PreviewProvider {
    static var previews: some View {
        FlaskView(flask: Flask(colors: [.red, .green, .grey, .blue]))
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
