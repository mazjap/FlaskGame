//
//  FlaskController.swift
//  FlaskGame
//
//  Created by Jordan Christensen on 12/16/20.
//

import Foundation
import UIKit.UIColor

class FlaskController: ObservableObject {
    @Published var flasks: [Flask]
    
    init(flasks: [Flask]) {
        self.flasks = flasks
    }
    
    func dumpFlask(_ flaskIndex: Int, into otherFlaskIndex: Int) {
        var flask1 = flasks[flaskIndex]
        var flask2 = flasks[otherFlaskIndex]
        
        if let info = flask1.topColorAndCount {
            let remainder = flask2.addColor(info.color, count: info.count)
            flask1.remo
        }
    }
}
