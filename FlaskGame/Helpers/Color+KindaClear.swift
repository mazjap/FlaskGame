import SwiftUI

extension UIColor {
    static var kindaClear: UIColor {
        .white.withAlphaComponent(0.01)
    }
}

extension Color {
    static var kindaClear: Color {
        .init(uiColor: .kindaClear)
    }
}
