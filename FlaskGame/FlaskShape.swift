//
//  FlaskShape.swift
//  FlaskGame
//
//  Created by Jordan Christensen on 12/17/20.
//

import SwiftUI

struct FlaskShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let offset: CGFloat = rect.width / 6
        let width = rect.width
        let height = rect.height
        
        let secondaryLineHeight = height - offset * 2
        
        // Flask - Body
        path.move(to: CGPoint(x: offset, y: 0))
        path.addRect(CGRect(origin: CGPoint(x: offset, y: 0), size: CGSize(width: width - offset * 2, height: secondaryLineHeight)))
        
        // Flask - Top-Right Curve
        path.move(to: CGPoint(x: width - offset, y: 0))
        path.addArc(center: CGPoint(x: width - offset, y: offset), radius: offset, startAngle: Angle(radians: .pi / 2), endAngle: Angle(radians: 3 * .pi / 2), clockwise: true)
        
        // Flask - Top-Left Curve
        path.move(to: CGPoint(x: offset, y: 0))
        path.addArc(center: CGPoint(x: offset, y: offset), radius: offset, startAngle: Angle(radians: .pi / 2), endAngle: Angle(radians: 3 * .pi / 2), clockwise: false)
        
        // Flask - Bottom Curve
        path.move(to: CGPoint(x: offset, y: secondaryLineHeight))
        path.addArc(center: CGPoint(x: width / 2, y: secondaryLineHeight), radius: width / 2 - offset, startAngle: Angle(radians: 0), endAngle: Angle(radians: .pi), clockwise: false)
        
        return path
    }
}


struct FlaskShape_Previews: PreviewProvider {
    static var previews: some View {
        FlaskShape()
            .stroke(style: StrokeStyle(lineWidth: 1))
    }
}
