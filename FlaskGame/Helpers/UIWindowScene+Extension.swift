import UIKit

extension UIWindowScene {
    static var current: UIWindowScene? {
        UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
}
