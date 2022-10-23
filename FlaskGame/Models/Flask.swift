import Foundation
import UIKit.UIColor

enum Flask: Identifiable, Equatable {
    case normal(NormalFlask)
    case tiny(TinyFlask)
    
    var colors: [FlaskColor] {
        switch self {
        case let .normal(flask):
            return flask.colors
        case let .tiny(flask):
            guard let color = flask.color else { return [] }
            return [color]
        }
    }
    
    var topColor: FlaskColor? {
        colors.last
    }
    
    var topColorCount: Int {
        switch self {
        case let .normal(flask):
            return flask.topColorCount
        case let .tiny(flask):
            return flask.color == nil ? 0 : 1
        }
    }
    
    var isComplete: Bool {
        let colors = colors
        
        guard !colors.isEmpty else { return true }
        guard colors.count >= 4 else { return false }
        
        if let test = colors.first {
            for color in colors {
                guard color == test else { return false }
            }
        }
        
        return true
    }
    
    var colorsAccessibilityLabel: String {
        if isComplete {
            return colors.isEmpty
                ? "Empty"
                : "Complete \(topColor?.rawValue ?? "")"
        }
        
        return colors.reversed().reduce("", { "\($0), \($1)" })
    }
    
    var stringRepresentation: [String] {
        switch self {
        case let .normal(flask):
            return flask.colors.map { $0.rawValue } + ["n"]
        case let .tiny(flask):
            return (flask.color == nil ? [] : [flask.color!.rawValue]) + ["t"]
        }
    }
    
    var id: UUID {
        switch self {
        case let .normal(flask):
            return flask.id
        case let .tiny(flask):
            return flask.id
        }
    }
    
    // MARK: - Function
    
    func remainder(afterAdding color: FlaskColor?, count: Int = 1) -> Int {
        switch self {
        case let .normal(flask):
            return flask.remainder(afterAdding: color, count: count)
        case let .tiny(flask):
            return flask.remainder(afterAdding: color, count: count)
        }
    }
    
    // Mutating
    mutating func addColor(_ color: FlaskColor?, count: Int = 1) -> Int {
        let ret: Int
        
        switch self {
        case var .normal(flask):
            ret = flask.addColor(color, count: count)
            self = .normal(flask)
        case var .tiny(flask):
            ret = flask.addColor(color, count: count)
            self = .tiny(flask)
        }
        
        return ret
    }
    
    mutating func removeTop(_ count: Int = 0) {
        switch self {
        case var .normal(flask):
            flask.removeTop(count)
            self = .normal(flask)
        case var .tiny(flask):
            flask.removeTop(count)
            self = .tiny(flask)
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case let .normal(lhsFlask):
            guard case let .normal(rhsFlask) = rhs,
                  lhsFlask == rhsFlask
            else { return false }
            return true
        case let .tiny(lhsFlask):
            guard case let .tiny(rhsFlask) = rhs,
                  lhsFlask == rhsFlask
            else { return false }
            return true
        }
    }
}

enum FlaskOrder: String {
    case normal = "3"
    case end = "2"
    case extra = "1"
    
    func uuid() -> UUID {
        var characters = UUID().uuidString.map { String($0) }
        
        characters[0] = rawValue
        
        return UUID(uuidString: characters.joined()) ?? UUID()
    }
}
