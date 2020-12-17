//
//  FlaskView.swift
//  FlaskGame
//
//  Created by Jordan Christensen on 12/16/20.
//

import SwiftUI

struct FlaskView: View {
    
    var body: some View {
        VStack {
            FlaskView.background
                .foregroundColor(.red)
        }
    }
    
    static var background: Path {
        var path = Path()
        
        let offset: CGFloat = 5
        
        let width: CGFloat = 30
        let height: CGFloat = 80
        
        let secondaryLineHeight = height - offset * 4
        
        // Flask - Top
        path.move(to: CGPoint(x: offset, y: 0))
        path.addLine(to: CGPoint(x: width - offset * 2, y: 0))
        
        // Flask - Top-Left Curve
        path.addArc(center: CGPoint(x: offset, y: offset), radius: offset, startAngle: Angle(radians: .pi / 2), endAngle: Angle(radians: 3 * .pi / 2), clockwise: true)
        
        // Flask - Top-Right Curve
        path.addArc(center: CGPoint(x: width - offset * 2, y: offset), radius: offset, startAngle: Angle(radians: .pi / 2), endAngle: Angle(radians: 3 * .pi / 2), clockwise: false)
        
        // Flask - Left Side
        path.move(to: CGPoint(x: offset, y: offset * 2))
        path.addLine(to: CGPoint(x: offset, y: secondaryLineHeight))
        
        // Flask - Right Side
        path.move(to: CGPoint(x: width - offset * 2, y: offset * 2))
        path.addLine(to: CGPoint(x: width - offset * 2, y: secondaryLineHeight))
        
        // Flask - Bottom Curve
        path.addArc(center: CGPoint(x: width / 2, y: secondaryLineHeight), radius: width / 2 - offset, startAngle: Angle(radians: 0), endAngle: Angle(radians: .pi), clockwise: true)
        
        return path
    }
}

struct FlaskView_Previews: PreviewProvider {
    static var previews: some View {
        FlaskView()
    }
}
