import Foundation

extension NSObject {
    class func swizzle(_ originalSelector: Selector, with newSelector: Selector) throws {
        #if DEBUG
        guard let originalMethod = class_getInstanceMethod(Self.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(Self.self, newSelector)
        else {
            throw AppError.badDecode("Unable to swizzle")
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
        #endif
    }
}
