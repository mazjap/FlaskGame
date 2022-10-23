import SwiftUI

struct FlaskView: View {
    @Binding private var offsetWave: Bool
    
    let flask: Flask
    
    private let defaultBackground: Color
    
    init(flask: Flask, offsetWave: Binding<Bool> = .constant(false), defaultBackground: Color? = nil) {
        self.flask = flask
        self.defaultBackground = defaultBackground ?? .kindaClear
        
        self._offsetWave = offsetWave
    }
    
    private static var numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .ordinal
        return nf
    }()
    
    private static func ordinalPosition(for i: Int) -> String {
        let str = numberFormatter.string(from: NSNumber(value: i)) ?? "N/A"
        print(str)
        
        return str
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
                color.color
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
                    ZStack(alignment: .bottom) {
                        defaultBackground.opacity(0.75)
                        
                        VStack(spacing: 0) {
                            let colorsScale: Double = {
                                if case .normal = flask {
                                    return min(1, Double(flask.colors.count) / 4)
                                } else {
                                    return 0.75
                                }
                            }()
                            
                            colors
                                .frame(height: geometry.size.height * colorsScale)
                                .clipShape(Waves(offset: offsetWave ? .pi / 8 : 0))
                        }
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
        HStack {
            FlaskView(flask: .normal(.init(colors: [.red, .green, .grey, .blue])))
            FlaskView(flask: .tiny(.init(.orange)))
        }
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
