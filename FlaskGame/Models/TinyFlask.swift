import Foundation

struct TinyFlask: Identifiable, Equatable {
    private(set) var color: FlaskColor?
    
    let id: UUID = UUID()
    var index: Int
    
    init(_ color: FlaskColor?, index: Int = 0) {
        self.color = color
        self.index = index
    }
    
    // MARK: - Function
    
    func remainder(afterAdding newColor: FlaskColor?, count: Int = 1) -> Int {
        let avaibleSpace = max(0, color == nil ? 1 : 0)
        let amount = min(avaibleSpace, count)
        
        guard newColor != nil, color == nil else {
            return count
        }
        
        return count - amount
    }
    
    // Mutating
    mutating func addColor(_ newColor: FlaskColor?, count: Int = 1) -> Int {
        guard let newColor = newColor else { return count }
        
        let remainder = remainder(afterAdding: color, count: count)
        if remainder < count {
            color = newColor
        }
        
        return remainder
    }
    
    mutating func removeTop(_ count: Int = 0) {
        color = nil
    }
    
    static let emptyFlask: TinyFlask = {
        TinyFlask(nil)
    }()
}
