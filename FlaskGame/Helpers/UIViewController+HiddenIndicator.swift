import UIKit

extension UIViewController {
    @objc var swizzle_prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    class func swizzleIndicator() {
        do {
            try swizzle(#selector(getter: UIViewController.prefersHomeIndicatorAutoHidden), with: #selector(getter: UIViewController.swizzle_prefersHomeIndicatorAutoHidden))
        } catch {
            nserror(error)
        }
    }
}
