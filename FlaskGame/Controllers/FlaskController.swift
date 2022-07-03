import Foundation
import UIKit.UIColor
import SwiftUI

enum Difficulty: String, CaseIterable {
    case easy
    case medium
    case hard
    
    var intValue: Int {
        switch self {
        case .easy:
            return 8
        case .medium:
            return 12
        case .hard:
            return 16
        }
    }
}

class FlaskController: ObservableObject {
    private var previousMoves: [[Flask]] = []
    
    @Published private(set) var didWinGame: Bool
    @Published var flasks: [Flask]
    @Published var pouringFlasks: [UUID : UUID]
    
    init(_ flaskArray: [Flask] = FlaskController.generateRandom()) {
        self.didWinGame = false
        self.flasks = []
        self.pouringFlasks = [:]
    }
    
    private func addMove() {
        previousMoves.append(flasks)
    }
    
    private func resetMoves() {
        previousMoves = []
        addMove()
        hasWon()
    }
    
    @discardableResult
    private func hasWon() -> Bool {
        var hasWon = true
        
        for flask in flasks {
            guard flask.isComplete else {
                hasWon = false
                break
            }
        }
        
        self.didWinGame = hasWon
        return hasWon
    }
    
    func flask(with id: String?) -> Flask? {
        guard let str = id else { return nil }
        
        return flask(with: UUID(uuidString: str))
    }
    
    func flask(with id: UUID?) -> Flask? {
        flasks.first(where: { $0.id == id })
    }
    
    func flask(at index: Int?) -> Flask? {
        guard let index = index,
              index >= 0,
              index < flasks.count
        else { return nil }
        
        return flasks[index]
    }
    
    func undo() {
        if let lastMove = previousMoves.last {
            previousMoves.removeLast()
            flasks = lastMove
            hasWon()
        }
    }
    
    func restart() {
        if let start = previousMoves.first {
            flasks = start
            resetMoves()
            hasWon()
        }
    }
    
    func newGame(difficulty: Difficulty) {
        let flaskCount = difficulty.intValue
        let flaskArr = Self.generateRandom(count: flaskCount - 2)
        
        flasks = (flaskArr + [
            Flask.emptyFlask(index: flaskArr.count),
            Flask.emptyFlask(index: flaskArr.count + 1)
        ])
        
        resetMoves()
    }
    
    func dumpFlask(_ flaskIndex: Int, into otherFlaskIndex: Int) {
        var flask1 = flasks[flaskIndex]
        var flask2 = flasks[otherFlaskIndex]
        
        // Try to dump flask1's top color into flask2, while saving the left-over amount that cannot fit
        let remainder = flask2.addColor(flask1.topColor, count: flask1.topColorCount)
        
        // Remove the top color from flask1 as many times as could fit in flask2
        flask1.removeTop(flask1.topColorCount - remainder)
        
        withAnimation {
            pouringFlasks[flask1.id] = flask2.id
        }
        
        flasks[flaskIndex] = flask1
        flasks[otherFlaskIndex] = flask2
        
        withAnimation {
            _ = pouringFlasks.removeValue(forKey: flask1.id)
        }
        
        if flasks != previousMoves.last {
            addMove()
            didWinGame = hasWon()
        }
    }
    
    static func generateRandom(count: Int = 12) -> [Flask] {
        // Get colors for all flasks and make 4 randomized color arrays
        let colors: [[FlaskColor]] = {
            var colors = Array(repeating: generateColors(count: count), count: 4)
            
            for i in (0..<colors.count).reversed() {
                for j in (0..<colors[i].count).reversed() {
                    let m = Int.random(in: 0..<i+1)
                    let n = Int.random(in: 0..<j+1)

                    let c = colors[i][j]
                    colors[i][j] = colors[m][n]
                    colors[m][n] = c
                }
            }
            
            return colors
        }()
        
        return (0..<colors[0].count).map {
            Flask(
                colors: [
                    colors[0][$0],
                    colors[1][$0],
                    colors[2][$0],
                    colors[3][$0]
                ],
                index: $0
            )
        }
    }
    
    
    // Generate n unique colors
    private static func generateColors(count: Int) -> [FlaskColor] {
        guard count > 0 else { return [] }
        
        return Array(FlaskColor.allCases.shuffled().prefix(count))
    }
}
