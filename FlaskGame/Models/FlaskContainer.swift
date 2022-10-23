import Foundation

struct FlaskContainer: ExpressibleByDictionaryLiteral {
    var extraFlask: TinyFlask?
    var normalFlasks: [UUID : NormalFlask]
    
    var values: [Flask] {
        var arr = normalFlasks.values.map(Flask.normal)
        
        if let extraFlask {
            arr.append(.tiny(extraFlask))
        }
        
        return arr
    }
    
    init(dictionaryLiteral elements: (UUID, Flask)...) {
        self.init(flasks: elements.map(\.1))
    }
    
    init(flasks: [UUID : NormalFlask] = [:], tinyFlask: TinyFlask? = nil) {
        self.normalFlasks = flasks
        self.extraFlask = tinyFlask
    }
    
    init(flasks: [Flask]) {
        normalFlasks = [:]
        
        for flask in flasks {
            switch flask {
            case let .normal(flask):
                normalFlasks[flask.id] = flask
            case let .tiny(flask):
                extraFlask = flask
            }
        }
    }
    
    subscript(_ key: UUID) -> Flask? {
        get {
            if let extraFlask, extraFlask.id == key {
                return .tiny(extraFlask)
            } else if let flask = normalFlasks[key] {
                return .normal(flask)
            }
            
            return nil
        }
        set {
            switch newValue {
            case let .tiny(flask):
                extraFlask = flask
            case let .normal(flask):
                normalFlasks[key] = flask
                fallthrough
            case .none:
                if extraFlask?.id == key {
                    extraFlask = nil
                }
            }
        }
    }
}
