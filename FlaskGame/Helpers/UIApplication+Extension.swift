import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .reduce([UIWindow]()) { arr, scene in
                guard scene.activationState == .foregroundActive,
                      let windowScene = scene as? UIWindowScene
                else { return arr }
                
                return arr + windowScene.windows
            }
            .first { $0.isKeyWindow }
    }
    
    var rootViewController: UIViewController? {
        keyWindow?.rootViewController
    }
}
