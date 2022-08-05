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
    private var store: SettingsStore
    
    @Published private(set) var didWinGame: Bool {
        didSet {
            save(false)
        }
    }
    @Published var flasks: [Flask]
    @Published var pouringFlasks: [UUID : UUID]
    
    init(store: SettingsStore = UserDefaults.standard, _ difficulty: Difficulty = .medium) {
        self.didWinGame = false
        self.flasks = []
        self.pouringFlasks = [:]
        self.store = store
        
        self.newGame(difficulty: difficulty)
        self.fetchGame()
    }
    
    private func addMove() {
        previousMoves.append(flasks)
    }
    
    private func resetMoves(initial: [Flask]? = nil) {
        let value: [Flask]
        
        if let initial = initial {
            value = initial
        } else if let initial = previousMoves.first {
            value = initial
        } else {
            value = []
        }
        
        previousMoves = [value]
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
            resetMoves(initial: start)
            hasWon()
        }
    }
    
    func newGame(difficulty: Difficulty) {
        let flaskCount = difficulty.intValue
        let flaskArr = Self.generateRandom(count: flaskCount - 2)
        
        flasks = (flaskArr + [
            .normal(.emptyFlask(index: flaskArr.count)),
            .normal(.emptyFlask(index: flaskArr.count + 1))
        ])
        
        resetMoves(initial: flasks)
    }
    
    func dumpFlask(_ flaskIndex: Int, into otherFlaskIndex: Int) -> Bool {
        var flask1 = flasks[flaskIndex]
        var flask2 = flasks[otherFlaskIndex]
        
        guard flask2.remainder(afterAdding: flask1.topColor, count: flask1.topColorCount) < flask1.topColorCount else {
            return false
        }
        
        if flasks != previousMoves.last {
            addMove()
        }
        
        withAnimation {
            // Try to dump flask1's top color into flask2, while saving the left-over amount that cannot fit
            let remainder = flask2.addColor(flask1.topColor, count: flask1.topColorCount)
            
            // Remove the top color from flask1 as many times as could fit in flask2
            flask1.removeTop(flask1.topColorCount - remainder)
        
            pouringFlasks[flask1.id] = flask2.id
        }
        
        flasks[flaskIndex] = flask1
        flasks[otherFlaskIndex] = flask2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            withAnimation {
                _ = self?.pouringFlasks.removeValue(forKey: flask1.id)
            }
        }
        
        hasWon()
        
        return true
    }
    
    func save(_ bool: Bool = true) {
        if bool {
            store.set(
                flasks.map { $0.stringRepresentation },
                for: Self.gameKey
            )
        } else {
            store.delete(key: Self.gameKey)
        }
    }
    
    func fetchGame() {
        var verifier = [FlaskColor : Int]()

        guard let repArr: [[String]] = store.get(using: Self.gameKey) else { return }

        let (flaskArr, isValid) = repArr.enumerated().reduce(([Flask](), true)) { result, enumeration in
            let def = ([Flask](), false)

            if !result.1 {
                return def
            }

            var flaskColors = [FlaskColor]()
            let flaskIndex = enumeration.offset
            
            var colors = enumeration.element
            let flask: Flask
            
            switch colors.last {
            case "t":
                _ = colors.popLast()
                
                let color: FlaskColor?
                
                if let rawValue = colors.last,
                   let c = FlaskColor(rawValue: rawValue) {
                    verifier[c, default: 0] += 1
                    color = c
                } else {
                    color = nil
                }
                
                flask = .tiny(.init(color, index: flaskIndex))
            case "n":
                _ = colors.popLast()
                fallthrough
            default:
                for str in colors {
                    guard let color = FlaskColor(rawValue: str) else { return def }

                    verifier[color, default: 0] += 1
                    flaskColors.append(color)
                }
                
                flask = .normal(.init(colors: flaskColors, index: flaskIndex))
            }
            
            return (result.0 + [flask], result.1)
        }

        guard isValid, !verifier.values.reduce(false, { hasBadData, count in
            if hasBadData {
                return true
            } else {
                return count != 4
            }
        }) else {
            return
        }

        resetMoves(initial: flaskArr)
        flasks = flaskArr
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
            .normal(.init(
                colors: [
                    colors[0][$0],
                    colors[1][$0],
                    colors[2][$0],
                    colors[3][$0]
                ],
                index: $0
            ))
        }
    }
    
    
    // Generate n unique colors
    private static func generateColors(count: Int) -> [FlaskColor] {
        guard count > 0 else { return [] }
        
        return Array(FlaskColor.allCases.shuffled().prefix(count))
    }
    
    private static let gameKey = "cgv-flask_master" // Current Game Value
}
