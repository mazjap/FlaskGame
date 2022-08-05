import Foundation

var inDebug: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
}

// MARK: - Math

func minmax<C>(_ lowerBound: C, _ upperBound: C, _ value: C) -> C where C: Comparable {
    min(upperBound, max(lowerBound, value))
}
