import Foundation

struct TwoWayDictionary<S, T>: ExpressibleByDictionaryLiteral where S: Hashable, T: Hashable {
    // Literal convertible
    typealias Key = S
    typealias Value = T
    
    // Real storage
    private(set) var st = [S : T]()
    private(set) var ts = [T : S]()
    
    init(leftRight st: [S : T]) {
        self.st = st
        
        for (key, value) in st {
            ts[value] = key
        }
    }
    
    init(rightLeft ts: [T : S]) {
        self.ts = ts
        
        for (key, value) in ts {
            st[value] = key
        }
    }
    
    init(dictionaryLiteral elements: (Key, Value)...) {
        for (key, value) in elements {
            st[key] = value
            ts[value] = key
        }
    }
    
    init() {}
    
    subscript(key: S) -> T? {
        get { st[key] }
        set {
            guard let newValue else { return }
            
            st[key] = newValue
            ts[newValue] = key
        }
    }
    
    subscript(key: T) -> S? {
        get { ts[key] }
        set {
            guard let newValue else { return }
            
            ts[key] = newValue
            st[newValue] = key
        }
    }
}
