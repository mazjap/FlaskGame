import SwiftUI

struct Waves: Shape {
    enum Function {
        case sine
        case custom((CGFloat) -> CGFloat)
        
        /// Performs some transformation to a value (0...1).
        /// - Returns: CGFloat ranged 0...1.
        func y(for x: CGFloat, offset: CGFloat = 0) -> CGFloat {
            switch self {
            case .sine:
                return (
                    sin((x + offset) * .pi * 5) + 1) / 2
            case let .custom(f):
                return f(x + offset)
            }
        }
    }
    
    let offset: Double
    let numberOfPoints: Int
    let function: Function
    
    init(offset: Double = 0, numberOfPoints: Int = 30, function: Function = .sine) {
        self.offset = offset
        self.numberOfPoints = numberOfPoints
        self.function = function
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let start = CGPoint(x: rect.minX, y: rect.maxY)
        path.move(to: start)
        
        let waveRect = CGRect(
            origin: rect.origin,
            size: CGSize(
                width: rect.width,
                height: rect.width * 0.1
            )
        )
        
        path.addLine(
            to: convertedPoint(
                CGPoint(
                    x: 0,
                    y: function.y(for: offset)
                ),
                in: waveRect
            )
        )
        
        let limit = numberOfPoints - 1
        
        for i in 1...limit {
            let x = CGFloat(i) / CGFloat(limit)
            path.addLine(
                to: convertedPoint(
                    CGPoint(
                        x: x,
                        y: function.y(for: x, offset: offset)
                    ),
                    in: waveRect
                )
            )
        }
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: start)
        
        return path
    }
    
    private func convertedPoint(_ point: CGPoint, in rect: CGRect) -> CGPoint {
        return CGPoint(
            x: rect.origin.x + point.x * rect.size.width,
            y: rect.origin.y + rect.size.height - point.y * rect.size.height
        )
    }
}

struct Waves_Previews: PreviewProvider {
    struct Test: View {
        @State var value: Double = 1
        
        var body: some View {
            VStack {
                Waves(offset: value)
                    .stroke(Color.red)
                    .scaleEffect(0.95)
                
                Slider(value: $value, in: 0...5)
            }
        }
    }
    
    static var previews: some View {
        HStack {
            Test()
            
            Color.red
                .clipShape(Waves())
//                .stroke(Color.red)
                .background(Color.gray.clipShape(Rectangle()))
        }
    }
}
