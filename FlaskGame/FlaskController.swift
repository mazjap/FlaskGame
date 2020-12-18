//
//  FlaskController.swift
//  FlaskGame
//
//  Created by Jordan Christensen on 12/16/20.
//

import Foundation
import UIKit.UIColor

class FlaskController: ObservableObject {
    
    private var previousMoves: [[Flask]] = []
    
    @Published var flasks: [Flask]
    @Published private(set) var didWinGame: Bool
    
    init(_ flaskArray: [Flask] = FlaskController.generateRandom()) {
        self.didWinGame = false
        self.flasks = flaskArray + [Flask.noFlask(index: flaskArray.count), Flask.noFlask(index: flaskArray.count + 1)]
        addMove()
    }
    
    private func addMove() {
        previousMoves.append(flasks)
    }
    
    private func resetMoves() {
        previousMoves = []
        addMove()
    }
    
    private func checkWon() -> Bool {
        for flask in flasks {
            guard flask.isPure else { return false }
        }
        
        return true
    }
    
    func undo() {
        if let lastMove = previousMoves.last {
            previousMoves.removeLast()
            flasks = lastMove
        }
    }
    
    func restart() {
        if let start = previousMoves.first {
            flasks = start
            resetMoves()
        }
    }
    
    func newGame() {
        let flaskArr = Self.generateRandom()
        flasks = flaskArr + [Flask.noFlask(index: flaskArr.count), Flask.noFlask(index: flaskArr.count + 1)]
        
        resetMoves()
    }
    
    func dumpFlask(_ flaskIndex: Int, into otherFlaskIndex: Int) {
        var flask1 = flasks[flaskIndex]
        var flask2 = flasks[otherFlaskIndex]
        
        // Try to dump flask1's top color into flask2, while saving the left-over amount that cannot fit
        let remainder = flask2.addColor(flask1.topColor, count: flask1.topColorCount)
        
        // Remove the top color from flask1 as many times as could fit in flask2
        flask1.removeTop(flask1.topColorCount - remainder)
        
        flasks[flaskIndex] = flask1
        flasks[otherFlaskIndex] = flask2
        
        addMove()
        
        didWinGame = checkWon()
    }
    
    static func generateRandom(count: Int = 12) -> [Flask] {
        guard count > 2 else { return [.noFlask, .noFlask] }
        
        // Get colors for all flasks except two and make 4 randomized color arrays
        let colorArr = generateColors(count: count - 2)
        let colors = [colorArr.shuffled(), colorArr.shuffled(), colorArr.shuffled(), colorArr.shuffled()]
        
        var flasks = [Flask]()
        
        for i in 0..<colorArr.count {
            // Use color arrays to create and append new flask
            flasks.append(Flask(colors: [colors[0][i], colors[1][i], colors[2][i], colors[3][i]], index: i))
        }
        
        return flasks
    }
    
    
    // Generate n unique colors
    private static func generateColors(count: Int) -> [UIColor] {
        var colors = [UIColor]()
        
        for i in 1...count {
            let color: UIColor
            let value = CGFloat(i) / CGFloat(count)
            
            // i is unique to each color, therefore it can be used to create unique colors
            switch i % 10 {
            case 0: color = UIColor(red: value, green: value, blue: 0, alpha: 1)
            case 1: color = UIColor(red: value, green: 0, blue: value, alpha: 1)
            case 2: color = UIColor(red: 0, green: value, blue: value, alpha: 1)
            case 3: color = UIColor(red: value, green: 1 - value, blue: 0, alpha: 1)
            case 4: color = UIColor(red: value, green: 0, blue: 1 - value, alpha: 1)
            case 5: color = UIColor(red: 0, green: value, blue: 1 - value, alpha: 1)
            case 6: color = UIColor(red: 1 - value, green: value, blue: 0, alpha: 1)
            case 7: color = UIColor(red: 1 - value, green: 0, blue: value, alpha: 1)
            case 8: color = UIColor(red: 0, green: 1 - value, blue: value, alpha: 1)
            default: color = UIColor(red: value, green: value, blue: value, alpha: 1)
            }
            
            
            colors.append(color)
        }
        
        return colors
    }
}
