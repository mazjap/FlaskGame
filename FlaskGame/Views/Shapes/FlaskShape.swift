import SwiftUI

struct FlaskShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let offset: CGFloat = rect.width / 6
        let width = rect.width
        let height = rect.height
        
        let secondaryLineHeight = height - offset * 2
        
        let bottomSemicircleRadius = width / 2 - offset
        
        // Flask - Bottom Curve
        path.addArc(
            center: CGPoint(
                x: width / 2,
                y: height - bottomSemicircleRadius
            ),
            radius: bottomSemicircleRadius,
            startAngle: Angle(radians: 0),
            endAngle: Angle(radians: .pi),
            clockwise: false
        )
        
        // Flask - Top-Left Curve
        path.addArc(
            center: CGPoint(
                x: offset,
                y: offset
            ),
            radius: offset,
            startAngle: Angle(radians: .pi / 2),
            endAngle: Angle(radians: 3 * .pi / 2),
            clockwise: false
        )
        
        // Flask - Top-Right Curve
        path.addArc(center: CGPoint(x: width - offset, y: offset), radius: offset, startAngle: Angle(radians: 3 * .pi / 2), endAngle: Angle(radians:.pi / 2), clockwise: false)
        
        // Flask - Right Side
        path.addLine(to: CGPoint(x: width - offset, y: secondaryLineHeight))
        
        return path
    }
}


struct FlaskShape_Previews: PreviewProvider {
    static var previews: some View {
        FlaskShape()
            .stroke(style: StrokeStyle(lineWidth: 1))
    }
}
