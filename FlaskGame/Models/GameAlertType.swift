import SwiftUI

enum GameAlertType {
    case newGame
    case restart
    case error(Error)
    
    var localizedTitle: LocalizedStringKey {
        switch self {
        case .newGame:
            "Select Difficulty"
        case .restart:
            "Are you sure you want to restart?"
        case .error(let error):
            LocalizedStringKey(error.localizedDescription)
        }
    }
    
    var isError: Bool {
        switch self {
        case .error: true
        default: false
        }
    }
}

extension Optional<GameAlertType> {
    var isPresented: Bool {
        get { self != nil }
        set {
            if !newValue {
                self = nil
            }
        }
    }
    
    var localizedTitle: LocalizedStringKey {
        switch self {
        case let .some(thing):
            return thing.localizedTitle
        case .none:
            return "Error State"
        }
    }
    
    var isError: Bool {
        switch self {
        case let .some(thing): thing.isError
        case .none: false
        }
    }
}
