import Foundation

struct TinyFlask: Identifiable, Equatable {
    private(set) var color: FlaskColor?
    
    let id: UUID = FlaskOrder.extra.uuid()
    
    init(_ color: FlaskColor? = nil) {
        self.color = color
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
        
        let remainder = remainder(afterAdding: newColor, count: count)
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
