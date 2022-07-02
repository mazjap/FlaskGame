import Foundation
import UIKit.UIColor

struct Flask: Equatable, Identifiable {
    typealias Color = UIColor
    
    // MARK: - Variables
    
    // Private
    private(set) var colors: [Color]
    
    // Public
    let id: UUID = UUID()
    var index: Int
    
    var topColor: Color? {
        colors.last
    }
    
    var topColorCount: Int {
        guard topColor != .kindaClear else { return 0 }
        
        var count = 0
        for color in colors.reversed() {
            if color != topColor {
                break
            }
            
            count += 1
        }
        
        return count
    }
    
    var isPure: Bool {
        if let test = colors.first {
            for color in colors {
                guard color == test else { return false }
            }
        }
        
        return true
    }
    
    // MARK: - Init
    
    init(colors: [Color], index: Int = 0) {
        if colors.count > 4 {
            self.colors = Array(colors[colors.startIndex...colors.startIndex.advanced(by: 3)])
        } else {
            self.colors = colors
        }
        
        self.index = index
    }
    
    init(_ color: Color, index: Int = 0) {
        self.colors = [Color](repeating: color, count: 4)
        self.index = index
    }
    
    // MARK: - Functions
    
    // Mutating
    mutating func addColor(_ color: Color?, count: Int = 1) -> Int {
        let avaibleSpace = max(0, 4 - colors.count)
        let amount = min(avaibleSpace, count)
        
        if let color = color, (topColor == nil || color == topColor) {
            colors += [Color](repeating: color, count: amount)
            return count - amount
        } else {
            return count
        }
    }
    
    mutating func removeTop(_ count: Int = 0) {
        let from = min(count, colors.count - count)
        for _ in from..<(from + count) {
            colors.removeLast()
        }
    }
    
    // MARK: - Static
    
    // Variables
    static var emptyFlask: Self {
        Flask(colors: [])
    }
    
    // Functions
    static func emptyFlask(index: Int) -> Self {
        var flask = emptyFlask
        flask.index = index
        
        return flask
    }
    
    static func == (lhs: Flask, rhs: Flask) -> Bool {
        return lhs.id == rhs.id &&
            lhs.index == rhs.index &&
            lhs.colors == rhs.colors
    }
}
