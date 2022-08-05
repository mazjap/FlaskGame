import Foundation

struct NormalFlask: Equatable, Identifiable {
    
    // MARK: - Variables
    
    // Private
    private(set) var colors: [FlaskColor]
    
    
    // Public
    let id: UUID = UUID()
    var index: Int
    
    var topColor: FlaskColor? {
        colors.last
    }
    
    var colorsAccessibilityLabel: String {
        if isComplete {
            return colors.isEmpty
                ? "Empty"
                : "Complete \(topColor?.rawValue ?? "")"
        }
        
        return colors.reversed().reduce("", { "\($0), \($1)" })
    }
    
    var topColorCount: Int {
        var count = 0
        for color in colors.reversed() {
            if color != topColor {
                break
            }
            
            count += 1
        }
        
        return count
    }
    
    var isComplete: Bool {
        guard !colors.isEmpty else { return true }
        guard colors.count >= 4 else { return false }
        
        if let test = colors.first {
            for color in colors {
                guard color == test else { return false }
            }
        }
        
        return true
    }
    
    // MARK: - Init
    
    init(colors: [FlaskColor], index: Int = 0) {
        if colors.count > 4 {
            self.colors = Array(colors[colors.startIndex...colors.startIndex.advanced(by: 3)])
        } else {
            self.colors = colors
        }
        
        self.index = index
    }
    
    init(_ color: FlaskColor, index: Int = 0) {
        self.colors = [FlaskColor](repeating: color, count: 4)
        self.index = index
    }
    
    // MARK: - Functions
    
    func remainder(afterAdding color: FlaskColor?, count: Int = 1) -> Int {
        let avaibleSpace = max(0, 4 - colors.count)
        let amount = min(avaibleSpace, count)
        guard let color = color, (topColor == nil || color == topColor) else {
            return count
        }
        
        return count - amount
    }
    
    // Mutating
    mutating func addColor(_ color: FlaskColor?, count: Int = 1) -> Int {
        guard let color = color else { return count }
        
        let remainder = remainder(afterAdding: color, count: count)
        colors += [FlaskColor](repeating: color, count: count - remainder)
        return remainder
    }
    
    mutating func removeTop(_ count: Int = 0) {
        let from = min(count, colors.count - count)
        for _ in from..<(from + count) {
            colors.removeLast()
        }
    }
    
    // MARK: - Static
    
    // Variables
    static var emptyFlask: NormalFlask {
        NormalFlask(colors: [])
    }
    
    // Functions
    static func emptyFlask(index: Int) -> Self {
        var flask = emptyFlask
        flask.index = index
        
        return flask
    }
    
    static func == (lhs: NormalFlask, rhs: NormalFlask) -> Bool {
        return lhs.id == rhs.id &&
            lhs.index == rhs.index &&
            lhs.colors == rhs.colors
    }
}
