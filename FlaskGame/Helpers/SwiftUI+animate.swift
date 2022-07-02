import SwiftUI

extension Animation {
    static let customSpring: Self = .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5)
}

func animate(_ body: () throws -> Void) rethrows {
    try withAnimation(.customSpring, body)
}
