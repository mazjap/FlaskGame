import SwiftUI

struct Waves: Shape {
    enum Function {
        case sine(peaksTroughsCount: CGFloat = 5, verticalTranslation: CGFloat = 0, scale: CGFloat = 0.5)
        case custom((CGFloat) -> CGFloat)
        
        /// Performs some transformation to a value (0...1).
        /// - Returns: CGFloat ranged 0...1.
        func y(for x: CGFloat, offset horizontalTranslation: CGFloat = 0) -> CGFloat {
            switch self {
            case let .sine(peaksTroughsCount, verticalTranslation, scale):
                return (
                    sin(
                        (x + horizontalTranslation) * .pi * peaksTroughsCount
                    ) + verticalTranslation
                ) * scale
            case let .custom(f):
                return f(x + horizontalTranslation)
            }
        }
    }
    
    var offset: Double
    let numberOfPoints: Int
    let function: Function
    
    var animatableData: Double {
        get { offset }
        set { offset = newValue }
    }
    
    /// - Parameters:
    ///   - offset: stuff
    init(offset: Double = 0, numberOfPoints: Int = 30, function: Function = .sine()) {
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
                    y: function.y(for: animatableData)
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
                        y: function.y(for: x, offset: animatableData)
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

#Preview {
    struct Test: View {
        @State var value: Double = 0
        
        var body: some View {
            VStack {
                HStack {
                    Waves(offset: value)
                        .stroke(Color.red)
                
                    Waves(offset: value)
                        .fill(Color.red)
                        .background(Color.gray.clipShape(Rectangle()))
                }
                
                Slider(value: $value, in: 0...5)
            }
        }
    }
    
    return Test()
}
