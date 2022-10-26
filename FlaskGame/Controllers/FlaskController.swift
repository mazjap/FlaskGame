import UIKit.UIColor
import SwiftUI

class FlaskController: ObservableObject {
    private var previousMoves: [FlaskContainer] = []
    private var store: SettingsStore
    
    @Published private(set) var didWinGame: Bool {
        didSet {
            save(false)
        }
    }
    @Published var flasks: FlaskContainer
    @Published var pouringFlasks: [UUID : UUID]
    
    var extraFlask: TinyFlask? {
        flasks.extraFlask
    }
    
    init(store: SettingsStore = UserDefaults.standard, _ difficulty: Difficulty = .hard) {
        self.didWinGame = false
        self.flasks = [:]
        self.pouringFlasks = [:]
        self.store = store
        
        self.newGame(difficulty: difficulty)
        self.fetchGame()
    }
    
    private func addMove() {
        previousMoves.append(flasks)
    }
    
    private func resetMoves(initial: FlaskContainer? = nil) {
        let value: FlaskContainer
        
        if let initial = initial {
            value = initial
        } else if let initial = previousMoves.first {
            value = initial
        } else {
            value = [:]
        }
        
        previousMoves = [value]
        hasWon()
    }
    
    @discardableResult
    private func hasWon() -> Bool {
        var hasWon = true
        
        for flask in flasks.values {
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
        guard let id else { return nil }
        
        return flasks[id]
    }
    
    func undo() {
        if var lastMove = previousMoves.last {
            previousMoves.removeLast()
            
            if lastMove.extraFlask == nil && flasks.extraFlask != nil {
                lastMove.extraFlask = TinyFlask()
            }
            
            flasks = lastMove
            
            hasWon()
        }
    }
    
    func restart() {
        guard var start = previousMoves.first else {
            return
        }
        
        if start.extraFlask == nil && flasks.extraFlask != nil {
            start.extraFlask = TinyFlask()
        }
        
        flasks = start
        resetMoves(initial: start)
        hasWon()
    }
    
    func newGame(difficulty: Difficulty) {
        let flaskCount = difficulty.intValue
        let flaskArr = Self.generateRandom(count: flaskCount - 2)
        
        flasks = FlaskContainer(flasks: (flaskArr + [.emptyFlask, .emptyFlask]).asDictionary)
        
        resetMoves(initial: flasks)
    }
    
    func dumpFlask(_ flaskId: UUID, into otherFlaskId: UUID) -> Bool {
        guard var flask1 = flasks[flaskId],
              var flask2 = flasks[otherFlaskId],
              flask2.remainder(afterAdding: flask1.topColor, count: flask1.topColorCount) < flask1.topColorCount
        else {
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
        
        flasks[flaskId] = flask1
        flasks[otherFlaskId] = flask2
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
                flasks.values.map { $0.stringRepresentation },
                for: Self.gameKey
            )
        } else {
            store.delete(key: Self.gameKey)
        }
    }
    
    func fetchGame() {
        var verifier = [FlaskColor : Int]()

        guard let repArr: [[String]] = store.get(using: Self.gameKey) else { return }

        let (flaskArr, isValid) = repArr.reduce(([Flask](), true)) { result, colorArray in
            let def = ([Flask](), false)

            if !result.1 {
                return def
            }

            var flaskColors = [FlaskColor]()
            
            var colors = colorArray
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
                
                flask = .tiny(.init(color))
            case "n":
                _ = colors.popLast()
                fallthrough
            default:
                for str in colors {
                    guard let color = FlaskColor(rawValue: str) else { return def }

                    verifier[color, default: 0] += 1
                    flaskColors.append(color)
                }
                
                flask = .normal(.init(colors: flaskColors))
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
        
        let container = FlaskContainer(flasks: flaskArr)

        resetMoves(initial: container)
        flasks = container
    }
    
    static func generateRandom(count: Int = 12) -> [NormalFlask] {
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
            .init(
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
    
    private static let gameKey = "cgv-flask_master" // Current Game Value
}

extension FlaskController: AdControllerDelegate {
    func giveReward() {
        let tinyFlask = TinyFlask()
        
        flasks[tinyFlask.id] = .tiny(tinyFlask)
    }
}

extension Sequence where Element: Identifiable {
    var asDictionary: [Element.ID : Element] {
        reduce(into: [Element.ID : Element]()) { $0[$1.id] = $1 }
    }
}

extension Sequence {
    static func + <RHS>(lhs: Self, rhs: RHS) -> [Element] where RHS: Sequence, RHS.Element == Element {
        lhs.map { $0 } + rhs.map { $0 }
    }
    
    func count(where match: @escaping (Element) -> Bool) -> Int {
        var count = 0
        for element in self {
            if match(element) {
                count += 1
            }
        }
        
        return count
    }
    
    var asArray: [Element] {
        self + []
    }
}
