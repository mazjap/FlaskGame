//
//  FlaskView.swift
//  FlaskGame
//
//  Created by Jordan Christensen on 12/16/20.
//

import SwiftUI

struct FlaskView: View {
    private let flask: Flask
    
    init(flask: Flask) {
        self.flask = flask
    }
    
    var body: some View {
        FlaskShape()
            .stroke(style: StrokeStyle(lineWidth: 3))
            .background(
                VStack {
                    ForEach(0..<flask.viewColors.count) { i in
                        Color(flask.viewColors[i])
                    }
                }
                .clipShape(FlaskShape())
            )
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
    
    init(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) {
        self.init(p1: CGPoint(x: x1, y: y1), p2: CGPoint(x: x2, y: y2))
    }
}
